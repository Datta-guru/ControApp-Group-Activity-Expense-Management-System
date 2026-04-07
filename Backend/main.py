import mysql.connector 
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from passlib.context import CryptContext
import uvicorn
import urllib.parse
import os
from twilio.rest import Client
from typing import List

app = FastAPI()

# --------------------------------
# PASSWORD HASH
# --------------------------------

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password):
    password = password[:72]
    return pwd_context.hash(password)

def verify_password(password, hashed):
    password = password[:72]
    return pwd_context.verify(password, hashed)

# --------------------------------
# CORS
# --------------------------------

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# --------------------------------
# DATABASE CONNECTION
# --------------------------------

def get_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="220928",
        database="contro_app"
    )

# --------------------------------
# TWILIO CONFIG
# --------------------------------

ACCOUNT_SID = ""
AUTH_TOKEN = ""


client = Client(ACCOUNT_SID, AUTH_TOKEN)

TWILIO_WHATSAPP_NUMBER = "whatsapp:+14155238886"

# --------------------------------
# MODELS
# --------------------------------

class Signup(BaseModel):
    username:str
    email:str
    password:str

class Login(BaseModel):
    email:str
    password:str

class CreateContro(BaseModel):
    user_id:int
    contro_name:str
    amount:int
    members:list[int]
    category:str

class AddMember(BaseModel):
    user_id:int
    name:str
    phone:str

class AddUPI(BaseModel):
    user_id:int
    upi_id:str
    upi_name:str

class MarkPaid(BaseModel):
    contro_member_id:int

class SendMessage(BaseModel):
    phone:str
    message:str

class UpdateStatus(BaseModel):
    contro_member_id:int
    status:str

class SendWhatsApp(BaseModel):
    numbers: list[str]
    message: str


# =================================================
# SIGNUP
# =================================================

@app.post("/signup")
def signup(data:Signup):

    conn=get_db()
    cursor=conn.cursor(dictionary=True)

    cursor.execute("SELECT id FROM users WHERE email=%s",(data.email,))
    user=cursor.fetchone()

    if user:
        raise HTTPException(status_code=400,detail="Email already exists")

    hashed=hash_password(data.password)

    cursor.execute("""
    INSERT INTO users(username,email,password_hash)
    VALUES(%s,%s,%s)
    """,(data.username,data.email,hashed))

    conn.commit()

    cursor.close()
    conn.close()

    return {"status":"account_created"}

# =================================================
# LOGIN
# =================================================

@app.post("/login")
def login(data:Login):

    conn=get_db()
    cursor=conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM users WHERE email=%s",(data.email,))
    user=cursor.fetchone()

    cursor.close()
    conn.close()

    if not user:
        raise HTTPException(status_code=401,detail="User not found")

    if not verify_password(data.password,user["password_hash"]):
        raise HTTPException(status_code=401,detail="Wrong password")

    return {
        "status":"success",
        "user_id":user["id"],
        "username":user["username"]
    }

@app.get("/account/{user_id}")
def account(user_id:int):

    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT username,email
        FROM users
        WHERE id=%s
    """,(user_id,))

    user = cursor.fetchone()

    cursor.close()
    conn.close()

    return user

# =================================================
# DASHBOARD
# =================================================

@app.get("/dashboard/{user_id}")
def dashboard(user_id:int):

    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    cursor.execute(
        "SELECT COUNT(*) total FROM contro WHERE user_id=%s",
        (user_id,)
    )
    total_contro = cursor.fetchone()["total"]

    cursor.execute(
        "SELECT COUNT(*) total FROM members WHERE user_id=%s",
        (user_id,)
    )
    total_members = cursor.fetchone()["total"]

    cursor.execute("""
    SELECT SUM(
        CASE 
        WHEN cm.status='Pending'
        THEN c.amount / (
            SELECT COUNT(*) 
            FROM contro_members 
            WHERE contro_id=c.id
        )
        ELSE 0 END
    ) AS pending

    FROM contro_members cm
    JOIN contro c ON cm.contro_id=c.id
    WHERE c.user_id=%s
    """,(user_id,))

    pending = cursor.fetchone()["pending"] or 0

    cursor.close()
    conn.close()

    return {
        "total_contro":total_contro,
        "total_members":total_members,
        "pending_payment":pending
    }
# =================================================
# CREATE CONTRO WITH AUTO SPLIT
# =================================================
@app.post("/create_contro")
def create_contro(data: CreateContro):

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO contro(user_id, contro_name, amount, category)
        VALUES(%s,%s,%s,%s)
    """, (
        data.user_id,
        data.contro_name,
        data.amount,
        data.category
    ))

    contro_id = cursor.lastrowid

    member_count = len(data.members)

    if member_count == 0:
        return {"error": "no members selected"}

    split_amount = data.amount // member_count

    for member in data.members:
        cursor.execute("""
            INSERT INTO contro_members
            (contro_id, member_id, status, pending_amount)
            VALUES(%s,%s,'Pending',%s)
        """, (contro_id, member, split_amount))

    conn.commit()
    cursor.close()
    conn.close()

    return {"status": "contro_created"}

# =================================================
# CONTRO LIST
# =================================================

@app.get("/contro_list/{user_id}")
def contro_list(user_id:int):

    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    query = """
    SELECT
        c.id,
        c.contro_name,
        c.created_at,

        COUNT(cm.member_id) AS total_members,

        SUM(CASE WHEN cm.status='Paid'
            THEN c.amount / (
                SELECT COUNT(*)
                FROM contro_members
                WHERE contro_id=c.id
            )
        ELSE 0 END) AS paid,

        SUM(CASE WHEN cm.status='Pending'
            THEN c.amount / (
                SELECT COUNT(*)
                FROM contro_members
                WHERE contro_id=c.id
            )
        ELSE 0 END) AS pending

    FROM contro c
    JOIN contro_members cm ON cm.contro_id=c.id
    WHERE c.user_id=%s
    GROUP BY c.id
    """

    cursor.execute(query,(user_id,))
    result = cursor.fetchall()

    cursor.close()
    conn.close()

    return result

@app.get("/members/{user_id}")
def members(user_id:int):

    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    query = """
    SELECT
        m.id,
        m.name,
        COUNT(cm.contro_id) AS contro_count
    FROM members m
    LEFT JOIN contro_members cm ON cm.member_id=m.id
    WHERE m.user_id=%s
    GROUP BY m.id
    """

    cursor.execute(query,(user_id,))
    result = cursor.fetchall()

    cursor.close()
    conn.close()

    return result

@app.get("/pending/{user_id}")
def pending(user_id:int):

    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    query = """
    SELECT
        m.name,
        m.phone,
        SUM(c.amount / mc.total_members) AS pending_amount

    FROM contro_members cm
    JOIN members m ON cm.member_id = m.id
    JOIN contro c ON cm.contro_id = c.id

    JOIN (
        SELECT contro_id, COUNT(*) AS total_members
        FROM contro_members
        GROUP BY contro_id
    ) mc ON mc.contro_id = c.id

    WHERE cm.status = 'Pending'
    AND c.user_id = %s

    GROUP BY m.id
    """

    cursor.execute(query,(user_id,))
    result = cursor.fetchall()

    cursor.close()
    conn.close()

    return result

@app.post("/update_status")
def update_status(data:UpdateStatus):

    print(data.contro_member_id,data.status)
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        UPDATE contro_members
        SET status=%s
        WHERE id=%s
    """,(data.status,data.contro_member_id))

    conn.commit()

    cursor.close()
    conn.close()

    return {"status":"updated"}

# =================================================
# CONTRO MEMBERS DETAIL
# =================================================

@app.get("/contro_members/{contro_id}")
def contro_members(contro_id:int):

    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
    SELECT
        cm.id,
        m.name,
        m.phone,
        cm.status,
        cm.pending_amount
    FROM contro_members cm
    JOIN members m ON cm.member_id=m.id
    WHERE cm.contro_id=%s
    """,(contro_id,))

    result = cursor.fetchall()

    cursor.close()
    conn.close()

    return result
    
# =================================================
# MARK PAYMENT
# =================================================

@app.post("/mark_paid")
def mark_paid(data:MarkPaid):

    conn=get_db()
    cursor=conn.cursor()

    cursor.execute("""
    UPDATE contro_members
    SET status='Paid'
    WHERE id=%s
    """,(data.contro_member_id,))

    conn.commit()

    cursor.close()
    conn.close()

    return {"status":"payment_updated"}

# =================================================
# ADD MEMBER
# =================================================

@app.post("/add_member")
def add_member(data:AddMember):

    conn=get_db()
    cursor=conn.cursor()

    cursor.execute("""
    INSERT INTO members(user_id,name,phone)
    VALUES(%s,%s,%s)
    """,(data.user_id,data.name,data.phone))

    conn.commit()

    cursor.close()
    conn.close()

    return {"status":"member_added"}

# =================================================
# MEMBER LIST
# =================================================

@app.get("/members_list/{user_id}")
def members_list(user_id:int):

    conn=get_db()
    cursor=conn.cursor(dictionary=True)

    cursor.execute("""
    SELECT id,name
    FROM members
    WHERE user_id=%s
    """,(user_id,))

    result=cursor.fetchall()

    cursor.close()
    conn.close()

    return result

# =================================================
# UPI MANAGEMENT
# =================================================

@app.post("/add_upi")
def add_upi(data:AddUPI):

    conn=get_db()
    cursor=conn.cursor()

    cursor.execute("""
    INSERT INTO user_upi(user_id,upi_id,upi_name)
    VALUES(%s,%s,%s)
    """,(data.user_id,data.upi_id,data.upi_name))

    conn.commit()

    cursor.close()
    conn.close()

    return {"status":"upi_added"}

@app.get("/upi/{user_id}")
def get_upi(user_id:int):

    conn=get_db()
    cursor=conn.cursor(dictionary=True)

    cursor.execute("""
    SELECT id,upi_name,upi_id
    FROM user_upi
    WHERE user_id=%s
    """,(user_id,))

    result=cursor.fetchall()

    cursor.close()
    conn.close()

    return result

# =================================================
# SEND WHATSAPP USING TWILIO (MULTIPLE)
# =================================================

@app.post("/send_whatsapp")
def send_whatsapp(data: SendWhatsApp):

    results = []

    try:
        for number in data.numbers:

            # ensure +91 format
            if not number.startswith("+"):
                number = "+91" + number

            msg = client.messages.create(
                from_=TWILIO_WHATSAPP_NUMBER,
                to=f"whatsapp:{number}",
                body=data.message
            )

            results.append({
                "phone": number,
                "sid": msg.sid
            })

        return {
            "status": "success",
            "count": len(results),
            "data": results
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# =================================================
# SEND REMINDER BY CONTRO ID (AUTO FETCH MEMBERS)
# =================================================

@app.post("/send_reminder/{contro_id}")
def send_reminder(contro_id:int):

    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    # 1️⃣ Get contro
    cursor.execute("""
    SELECT amount, user_id
    FROM contro
    WHERE id=%s
    """,(contro_id,))
    contro = cursor.fetchone()

    if not contro:
        raise HTTPException(status_code=404, detail="Contro not found")

    total_amount = contro["amount"]

    # 2️⃣ Get total members (ALL members)
    cursor.execute("""
    SELECT COUNT(*) as total
    FROM contro_members
    WHERE contro_id=%s
    """,(contro_id,))
    total_members = cursor.fetchone()["total"]

    if total_members == 0:
        raise HTTPException(status_code=400, detail="No members")

    # ✅ FIXED SPLIT AMOUNT
    split_amount = total_amount // total_members

    # 3️⃣ Get UPI
    cursor.execute("""
    SELECT upi_id, upi_name
    FROM user_upi
    WHERE user_id=%s
    LIMIT 1
    """,(contro["user_id"],))
    upi = cursor.fetchone()

    if not upi:
        raise HTTPException(status_code=400, detail="UPI not found")

    # 4️⃣ Get ONLY pending members
    cursor.execute("""
    SELECT m.phone, m.name
    FROM contro_members cm
    JOIN members m ON cm.member_id = m.id
    WHERE cm.contro_id=%s AND cm.status='Pending'
    """,(contro_id,))
    members = cursor.fetchall()

    if not members:
        raise HTTPException(status_code=400, detail="No pending members")

    results = []

    for m in members:

        number = m["phone"]

        if not number.startswith("+"):
            number = "+91" + number

        # ✅ UPI LINK
        upi_link = (
            f"upi://pay?pa={upi['upi_id']}"
            f"&pn={urllib.parse.quote(upi['upi_name'])}"
            f"&am={split_amount}"
            f"&cu=INR"
        )

        # ✅ SAME MESSAGE FOR ALL
        message = (
            f"Hello {m['name']},\n\n"
            f"Each member needs to pay ₹{split_amount}.\n\n"
            f"Pay using UPI:\n{upi_link}\n\n"
            f"UPI ID: {upi['upi_id']}\n\n"
            f"After payment, please send screenshot."
        )

        try:
            client.messages.create(
                from_=TWILIO_WHATSAPP_NUMBER,
                to=f"whatsapp:{number}",
                body=message
            )

            results.append({"phone": number, "status": "sent"})

        except Exception as e:
            results.append({"phone": number, "status": "failed", "error": str(e)})

    cursor.close()
    conn.close()

    return {
        "status": "completed",
        "amount_per_person": split_amount,
        "count": len(results),
        "data": results
    }

# =================================================
# ROOT
# =================================================

@app.get("/")
def home():
    return {"message":"Contro API Running"}

# =================================================
# RUN SERVER
# =================================================

if __name__ == "__main__":
    uvicorn.run(app,host="0.0.0.0",port=8000)