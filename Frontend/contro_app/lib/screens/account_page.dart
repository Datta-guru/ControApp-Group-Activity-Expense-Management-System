import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class AccountPage extends StatefulWidget {

  final int userId;

  AccountPage(this.userId);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  var user;
  List upiList = [];
  int? selectedUpi;

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {

    user = await ApiService.account(widget.userId);
    upiList = await ApiService.upiList(widget.userId);

    if(upiList.isNotEmpty){
      selectedUpi = upiList[0]["id"];
    }

    setState(() {});
  }

  // ---------------- LOGOUT ----------------

  logout() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove("user_id");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );

  }

  // ---------------- ADD UPI ----------------

  addUpiPopup(){

    TextEditingController upiName = TextEditingController();
    TextEditingController upiId = TextEditingController();

    showDialog(
      context: context,
      builder: (_){

        return AlertDialog(

          title: Text("Add UPI"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: upiName,
                decoration: InputDecoration(
                  labelText: "UPI Name",
                ),
              ),

              TextField(
                controller: upiId,
                decoration: InputDecoration(
                  labelText: "UPI ID",
                ),
              ),

            ],
          ),

          actions: [

            ElevatedButton(

              child: Text("Add UPI Link"),

              onPressed: () async {

                if(upiName.text.isEmpty || upiId.text.isEmpty){

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("UPI Name and ID required"))
                  );

                  return;
                }

                await ApiService.addUpi(
                  widget.userId,
                  upiName.text,
                  upiId.text
                );

                Navigator.pop(context);

                load();
              },

            )

          ],

        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    if(user == null){
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: Text("Account"),
      ),

      body: Padding(

        padding: EdgeInsets.all(20),

        child: ListView(

          children: [

            card("Name", user["username"]),
            card("Email", user["email"]),

            SizedBox(height:20),

            Text(
              "UPI Link",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(height:10),

            Container(

              padding: EdgeInsets.symmetric(horizontal:10),

              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),

              child: DropdownButton<int>(

                isExpanded: true,
                value: selectedUpi,
                underline: SizedBox(),

                items: [

                  ...upiList
                      .where((u) => u["upi_id"] != null && u["upi_id"] != "")
                      .map<DropdownMenuItem<int>>((u){

                    return DropdownMenuItem<int>(
                      value: u["id"],
                      child: Text("${u["upi_name"]} (${u["upi_id"]})"),
                    );

                  }).toList(),

                  DropdownMenuItem<int>(

                    value: -1,

                    child: Row(
                      children: [

                        Icon(Icons.add,color:Colors.blue),
                        SizedBox(width:8),
                        Text("Add UPI Link")

                      ],
                    ),

                  )

                ],

                onChanged: (v){

                  if(v == -1){

                    addUpiPopup();

                  }else{

                    setState(() {
                      selectedUpi = v;
                    });

                  }

                },

              ),

            ),

            SizedBox(height:30),

            // ---------------- LOGOUT BUTTON ----------------

            ElevatedButton.icon(

              onPressed: logout,

              icon: Icon(Icons.logout),

              label: Text("Logout"),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical:14),
              ),

            )

          ],
        ),
      ),
    );
  }

  Widget card(title,value){

    return Container(

      margin: EdgeInsets.only(bottom:15),

      padding: EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(title),

          SizedBox(height:5),

          Text(
            value,
            style: TextStyle(
              fontSize:16,
              fontWeight:FontWeight.w500
            ),
          )

        ],
      ),
    );
  }
}