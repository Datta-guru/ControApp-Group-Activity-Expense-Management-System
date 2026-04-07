import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const String baseUrl = "http://172.0.31.4:8000";

  // ================= LOGIN =================

  static Future login(String email,String password) async {

    var res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({
        "email":email,
        "password":password
      }),
    );

    if(res.statusCode == 200){
      return jsonDecode(res.body);
    }
    throw Exception("Login failed");
  }

  // ================= SIGNUP =================

  static Future signup(String username,String email,String password) async {

    var res = await http.post(
      Uri.parse("$baseUrl/signup"),
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({
        "username":username,
        "email":email,
        "password":password
      }),
    );

    if(res.statusCode == 200){
      return jsonDecode(res.body);
    }
    throw Exception("Signup failed");
  }

  // ================= DASHBOARD =================

  static Future dashboard(int userId) async {

    var res = await http.get(
      Uri.parse("$baseUrl/dashboard/$userId")
    );

    if(res.statusCode == 200){
      return jsonDecode(res.body);
    }
    throw Exception("Dashboard load failed");
  }

  // ================= ACCOUNT =================

  static Future account(int userId) async {

    var res = await http.get(
      Uri.parse("$baseUrl/account/$userId")
    );

    if(res.statusCode == 200){
      return jsonDecode(res.body);
    }
    throw Exception("Account fetch failed");
  }

  // ================= UPI LIST =================

  static Future upiList(int userId) async {

    var res = await http.get(
      Uri.parse("$baseUrl/upi/$userId")
    );

    if(res.statusCode == 200){
      return jsonDecode(res.body);
    }
    throw Exception("UPI list failed");
  }

  // ================= ADD UPI =================

  static Future addUpi(int userId,String name,String upiId) async {

    var res = await http.post(

      Uri.parse("$baseUrl/add_upi"),

      headers: {"Content-Type":"application/json"},

      body: jsonEncode({
        "user_id":userId,
        "upi_name":name,
        "upi_id":upiId
      }),

    );

    if(res.statusCode == 200){
      return jsonDecode(res.body);
    }
    throw Exception("UPI add failed");
  }

  // ================= CONTRO LIST =================

  static Future controList(int userId) async {

    var res = await http.get(
      Uri.parse("$baseUrl/contro_list/$userId")
    );

    if(res.statusCode == 200){
      return jsonDecode(res.body);
    }
    throw Exception("Contro list failed");
  }

  // ================= CONTRO MEMBERS =================

  static Future controMembers(int controId) async {

    var res = await http.get(
      Uri.parse("$baseUrl/contro_members/$controId")
    );

    if(res.statusCode == 200){
      return jsonDecode(res.body);
    }
    throw Exception("Members fetch failed");
  }

  // ================= UPDATE PAYMENT STATUS =================

  static Future updateStatus(int id,String status) async {

    var res = await http.post(

      Uri.parse("$baseUrl/update_status"),

      headers: {"Content-Type":"application/json"},

      body: jsonEncode({
        "contro_member_id":id,
        "status":status
      }),

    );

    if(res.statusCode == 200){
      return jsonDecode(res.body);
    }
    throw Exception("Status update failed");
  }

  // ================= MEMBER LIST PAGE =================

  static Future members(int userId) async {

    var res = await http.get(
      Uri.parse("$baseUrl/members/$userId")
    );

    if(res.statusCode == 200){
      return jsonDecode(res.body);
    }
    throw Exception("Members load failed");
  }

  // ================= ADD MEMBER =================

  static Future addMember(int userId,String name,String phone) async {

    var res = await http.post(

      Uri.parse("$baseUrl/add_member"),

      headers: {"Content-Type":"application/json"},

      body: jsonEncode({
        "user_id":userId,
        "name":name,
        "phone":phone
      }),

    );

    if(res.statusCode == 200){
      return jsonDecode(res.body);
    }
    throw Exception("Add member failed");
  }

  // ================= MEMBER LIST FOR DROPDOWN =================

  static Future membersList(int userId) async {

    var res = await http.get(
      Uri.parse("$baseUrl/members_list/$userId")
    );

    if(res.statusCode == 200){
      return jsonDecode(res.body);
    }
    throw Exception("Members list failed");
  }

  // ================= CREATE CONTRO =================

static Future createContro(
  int userId,
  String name,
  int amount,
  List members,
  String category,
) async {

  var res = await http.post(
    Uri.parse("$baseUrl/create_contro"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "user_id": userId,
      "contro_name": name,
      "amount": amount,
      "members": members,
      "category": category,
    }),
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  }

  throw Exception("Create contro failed");
}
  // ================= PENDING =================

  static Future pending(int userId) async {

    var res = await http.get(
      Uri.parse("$baseUrl/pending/$userId")
    );

    if(res.statusCode == 200){
      return jsonDecode(res.body);
    }
    throw Exception("Pending fetch failed");
  }
  // ================= SEND WHATSAPP REMINDER =================

// ================= SEND WHATSAPP REMINDER =================

static Future<bool> sendReminder(int controId) async {

  try {
    var res = await http.post(
      Uri.parse("$baseUrl/send_reminder/$controId"),
    );

    return res.statusCode == 200;

  } catch (e) {
    return false;
  }
}

}