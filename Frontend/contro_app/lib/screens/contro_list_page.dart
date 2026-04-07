import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'contro_detail_page.dart';

class ControListPage extends StatefulWidget {

  final int userId;

  ControListPage(this.userId);

  @override
  State<ControListPage> createState() => _ControListPageState();
}

class _ControListPageState extends State<ControListPage> {

  List list = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {

    list = await ApiService.controList(widget.userId);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Total Contro"),
      ),

      body: Padding(
        padding: EdgeInsets.all(15),

        child: ListView.builder(

          itemCount: list.length,

          itemBuilder: (context,index){

            var item = list[index];

            double paid = (item["paid"] ?? 0).toDouble();
            double pending = (item["pending"] ?? 0).toDouble();
            int members = item["total_members"] ?? 0;

            // date format
            String date = item["created_at"] ?? "";
            String formattedDate = "";

            if(date.isNotEmpty){
              DateTime dt = DateTime.parse(date);
              formattedDate = DateFormat("dd MMM yyyy").format(dt);
            }

            return GestureDetector(

              onTap: () async {

                await Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (context) => ControDetailPage(
                      item["id"],
                      item["contro_name"],
                      widget.userId,
                    ),

                  ),

                );

                load();

              },

              child: Container(

                margin: EdgeInsets.only(bottom:15),
                padding: EdgeInsets.all(15),

                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              item["contro_name"],
                              style: TextStyle(
                                fontSize:16,
                                fontWeight:FontWeight.bold,
                              ),
                            ),

                            SizedBox(height:3),

                            Text(
                              "Created: $formattedDate",
                              style: TextStyle(
                                fontSize:12,
                                color: Colors.grey,
                              ),
                            )

                          ],
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal:10,vertical:5),

                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Text("Total Member $members"),
                        )

                      ],
                    ),

                    SizedBox(height:10),

                    Row(

                      children: [

                        box("Paid", paid),
                        SizedBox(width:10),
                        box("Pending", pending),

                      ],

                    )

                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget box(title,value){

    return Expanded(

      child: Container(

        padding: EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),

        child: Column(

          children: [

            Text(title),
            SizedBox(height:5),
            Text("₹$value")

          ],
        ),

      ),

    );
  }
}