import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_page.dart';
import 'screens/dashboard_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  Future<Widget> checkLogin() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt("user_id");

    if(userId != null){
      return DashboardPage(userId);
    }

    return LoginPage();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: checkLogin(),
        builder: (context, snapshot){

          if(!snapshot.hasData){
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return snapshot.data!;
        },
      ),
    );
  }
}