##  SplitContro - Group Expense Management System

SplitContro is a mobile-based group expense management application that allows users to:
- Create expense groups (Contro)
- Add members
- Automatically split expenses
- Track payments (Paid / Pending)
- Send WhatsApp reminders using Twilio

---

##  Tech Stack

Frontend:
- Flutter (Dart)

Backend:
- FastAPI (Python)

Database:
- MySQL

External API:
- Twilio (WhatsApp messaging)


##  Backend Setup

Install Dependencies

```bash
pip install fastapi uvicorn mysql-connector-python passlib[bcrypt] python-multipart twilio
```

## Run Backend Server

python main.py
http://localhost:8000

## Database Setup (MySQL)

Create database:
CREATE DATABASE contro_app;
Update DB config in main.py:
def get_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="YOUR_PASSWORD",
        database="contro_app"
    )

## Flutter Setup
1️ 
Install Flutter dependencies
flutter pub get
2️
Run App
flutter run

## Get Your IP Address

Windows:
ipconfig

Mac/Linux:
ifconfig

Example:
http://192.168.1.10:8000
