import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'member_page.dart';
import 'contro_list_page.dart';
import 'pending_page.dart';
import 'account_page.dart';
import 'create_contro_page.dart';

class DashboardPage extends StatefulWidget {

  final int userId;

  DashboardPage(this.userId);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  var data;

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {

    data = await ApiService.dashboard(widget.userId);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    if(data == null){
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(

      body: SafeArea(

        child: Padding(

          padding: EdgeInsets.all(20),

          child: Column(

            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  GestureDetector(

                    onTap: () async {

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AccountPage(widget.userId),
                        ),
                      );

                      load();

                    },

                    child: CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                  )

                ],
              ),

              SizedBox(height:25),

              card("Total Contro", data["total_contro"], () async {

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ControListPage(widget.userId),
                  ),
                );

                load();

              }),

              card("Total Member", data["total_members"], () async {

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MemberPage(widget.userId),
                  ),
                );

                load();

              }),

              card("Pending Amount", data["pending_payment"], () async {

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PendingPage(widget.userId),
                  ),
                );

                load();

              }),

              SizedBox(height:25),

              ElevatedButton(

                onPressed: () async {

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateControPage(widget.userId),
                    ),
                  );

                  load();

                },

                child: Text("Create Contro"),

              )

            ],
          ),
        ),
      ),
    );
  }

  Widget card(title,value,onTap){

    return GestureDetector(

      onTap: onTap,

      child: Container(

        margin: EdgeInsets.only(top:15),
        padding: EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:[

            Text(title),

            Text(value.toString())

          ],
        ),
      ),
    );
  }
}