import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ControDetailPage extends StatefulWidget {
  final int controId;
  final String name;
  final int userId;

  ControDetailPage(this.controId, this.name, this.userId);

  @override
  State<ControDetailPage> createState() => _ControDetailPageState();
}

class _ControDetailPageState extends State<ControDetailPage> {

  List members = [];
  List upiList = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    members = await ApiService.controMembers(widget.controId);
    upiList = await ApiService.upiList(widget.userId);
    setState(() {});
  }

  // ================= SEND REMINDER SMS =================

  sendReminder() async {

  if (upiList.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please add UPI in Account first")),
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Sending WhatsApp reminders...")),
  );

  bool success = await ApiService.sendReminder(widget.controId);

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Reminder sent on WhatsApp ✅")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to send reminder ❌")),
    );
  }
}

  // ================= UPDATE PAYMENT STATUS =================

  updateStatus(int id, String status) async {
    await ApiService.updateStatus(id, status);
    load();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),

      body: Padding(
        padding: EdgeInsets.all(15),

        child: Column(
          children: [

            Expanded(
              child: ListView.builder(
                itemCount: members.length,

                itemBuilder: (context, index) {

                  var m = members[index];

                  int pending =
                      (m["pending_amount"] is int)
                          ? m["pending_amount"]
                          : (m["pending_amount"] ?? 0).toInt();

                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              m["name"],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text("Pending ₹$pending")

                          ],
                        ),

                        Row(
                          children: [

                            Row(
                              children: [

                                Radio<String>(
                                  value: "Paid",
                                  groupValue: m["status"],
                                  onChanged: (v) {
                                    updateStatus(m["id"], "Paid");
                                  },
                                ),

                                Text("Paid")
                              ],
                            ),

                            Row(
                              children: [

                                Radio<String>(
                                  value: "Pending",
                                  groupValue: m["status"],
                                  onChanged: (v) {
                                    updateStatus(m["id"], "Pending");
                                  },
                                ),

                                Text("Pending")
                              ],
                            ),

                          ],
                        ),

                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 10),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: sendReminder,
                child: Text("Send Reminder"),
              ),
            )

          ],
        ),
      ),
    );
  }
}