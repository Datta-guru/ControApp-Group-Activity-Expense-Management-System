import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MemberPage extends StatefulWidget {

  final int userId;

  MemberPage(this.userId);

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {

  List members = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {

    members = await ApiService.members(widget.userId);

    setState(() {});
  }

  addMemberPopup(){

    TextEditingController name = TextEditingController();
    TextEditingController phone = TextEditingController();

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: Text("Add Member"),

          content: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              TextField(
                controller: name,
                decoration: InputDecoration(
                  labelText: "Member Name",
                ),
              ),

              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone No",
                ),
              ),

            ],
          ),

          actions: [

            ElevatedButton(

              child: Text("Add member"),

              onPressed: () async {

                if(name.text.isEmpty || phone.text.isEmpty){

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Enter name and phone")),
                  );

                  return;
                }

                await ApiService.addMember(
                  widget.userId,
                  name.text,
                  phone.text,
                );

                Navigator.pop(context);

                load(); // refresh list
              },

            )

          ],

        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Total Member"),
      ),

      body: Padding(

        padding: EdgeInsets.all(20),

        child: Column(

          children: [

            Expanded(

              child: ListView.builder(

                itemCount: members.length,

                itemBuilder:(context,index){

                  var m = members[index];

                  return Container(

                    margin: EdgeInsets.only(bottom:10),
                    padding: EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(

                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [

                        Text(
                          m["name"],
                          style: TextStyle(fontSize:16),
                        ),

                        Container(

                          padding: EdgeInsets.symmetric(
                            horizontal:12,
                            vertical:5,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Text(
                            "Contro created ${m["contro_count"]}",
                            style: TextStyle(fontSize:12),
                          ),

                        )

                      ],

                    ),

                  );
                },

              ),

            ),

            SizedBox(height:10),

            ElevatedButton(

              onPressed: addMemberPopup,

              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal:30,
                  vertical:12,
                ),
              ),

              child: Text("Add member"),

            )

          ],

        ),

      ),

    );
  }
}