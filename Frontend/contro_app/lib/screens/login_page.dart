import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'dashboard_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool rememberMe = false;

  login() async {

    var res = await ApiService.login(
        email.text,
        password.text
    );

    if(res["status"]=="success"){

      int userId = res["user_id"];

      if(rememberMe){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt("user_id", userId);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => DashboardPage(userId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Text("Login",
                  style: TextStyle(
                      fontSize:28,
                      fontWeight:FontWeight.bold)),

              SizedBox(height:30),

              TextField(
                controller: email,
                decoration: InputDecoration(
                  labelText:"Email",
                  border:OutlineInputBorder(),
                ),
              ),

              SizedBox(height:15),

              TextField(
                controller: password,
                obscureText:true,
                decoration: InputDecoration(
                  labelText:"Password",
                  border:OutlineInputBorder(),
                ),
              ),

              Row(
                children: [

                  Checkbox(
                    value: rememberMe,
                    onChanged:(v){
                      setState(() {
                        rememberMe = v!;
                      });
                    },
                  ),

                  Text("Remember Me")

                ],
              ),

              ElevatedButton(
                  onPressed: login,
                  child: Text("Login")
              ),

              TextButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SignupPage()),
                    );
                  },
                  child: Text("Create Account")
              )

            ],
          ),
        ),
      ),
    );
  }
}