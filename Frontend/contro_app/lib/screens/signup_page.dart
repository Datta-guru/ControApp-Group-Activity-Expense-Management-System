import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'dashboard_page.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool autoLogin = false;
  bool loading = false;

  signup() async {

    if(name.text.isEmpty || email.text.isEmpty || password.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields"))
      );
      return;
    }

    setState(() {
      loading = true;
    });

    var res = await ApiService.signup(
        name.text,
        email.text,
        password.text
    );

    if(autoLogin){

      var loginRes = await ApiService.login(
          email.text,
          password.text
      );

      int userId = loginRes["user_id"];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt("user_id", userId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(userId),
        ),
      );

    }else{

      Navigator.pop(context);

    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: Text("Create Account")),

      body: Padding(
        padding: EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: name,
              decoration: InputDecoration(labelText:"Name"),
            ),

            SizedBox(height:10),

            TextField(
              controller: email,
              decoration: InputDecoration(labelText:"Email"),
            ),

            SizedBox(height:10),

            TextField(
              controller: password,
              obscureText:true,
              decoration: InputDecoration(labelText:"Password"),
            ),

            SizedBox(height:20),

            Row(
              children:[

                Checkbox(
                  value: autoLogin,
                  onChanged:(v){
                    setState(() {
                      autoLogin = v!;
                    });
                  },
                ),

                Text("Auto Login")

              ],
            ),

            SizedBox(height:20),

            loading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: signup,
                child: Text("Create Account"),
              )

          ],
        ),
      ),
    );
  }
}