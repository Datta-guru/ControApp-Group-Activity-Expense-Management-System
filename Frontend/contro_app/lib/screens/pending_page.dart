import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class PendingPage extends StatefulWidget {

  final int userId;

  PendingPage(this.userId);

  @override
  State<PendingPage> createState() => _PendingPageState();
}

class _PendingPageState extends State<PendingPage> {

  List pending = [];
  List upiList = [];

  Map selected = {};
  bool selectAll = false;

  int? selectedUpi;

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {

    pending = await ApiService.pending(widget.userId);
    upiList = await ApiService.upiList(widget.userId);

    if (upiList.isNotEmpty) {
      selectedUpi = upiList[0]["id"];
    }

    selected.clear();

    for (var m in pending) {
      selected[m["phone"]] = false;
    }

    setState(() {});
  }

  toggleAll() {

    selectAll = !selectAll;

    for (var key in selected.keys) {
      selected[key] = selectAll;
    }

    setState(() {});
  }

  // ================= UPI POPUP =================

  showUpiPopup() {

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: Text("Select UPI"),

          content: DropdownButton<int>(

            value: selectedUpi,
            isExpanded: true,

            items: upiList.map<DropdownMenuItem<int>>((u){

              return DropdownMenuItem<int>(
                value: u["id"],
                child: Text("${u["upi_name"]} (${u["upi_id"]})"),
              );

            }).toList(),

            onChanged: (v){

              setState(() {
                selectedUpi = v;
              });

            },

          ),

          actions: [

            ElevatedButton(

              child: Text("Send Message"),

              onPressed:(){

                Navigator.pop(context);
                sendMessages();

              },

            )

          ],

        );

      },

    );

  }

  // ================= SEND SMS =================

  sendMessages() async {

    if(selectedUpi == null){
      return;
    }

    var upi = upiList.firstWhere((u) => u["id"] == selectedUpi);

    String upiId = upi["upi_id"];
    String upiName = upi["upi_name"];

    List<String> numbers = [];

    for (var m in pending) {

      if (selected[m["phone"]] == true) {

        numbers.add(m["phone"]);

      }

    }

    if(numbers.isEmpty){
      return;
    }

    // UPI LINK WITHOUT AMOUNT
    String paymentLink =
        "https://pay.google.com/gp/p/ui/pay?"
        "pa=$upiId"
        "&pn=${Uri.encodeComponent(upiName)}"
        "&cu=INR";

    String message =
        "Hello,\n\n"
        "Contro payment reminder.\n\n"
        "Please pay using UPI:\n"
        "$paymentLink\n\n"
        "UPI ID: $upiId\n\n"
        "After payment send screenshot.";

    String smsUri =
        "sms:${numbers.join(',')}?body=${Uri.encodeComponent(message)}";

    await launchUrl(
      Uri.parse(smsUri),
      mode: LaunchMode.externalApplication,
    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Pending Payment"),
      ),

      body: Padding(

        padding: EdgeInsets.all(20),

        child: Column(

          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Text("Select All"),

                Checkbox(
                  value: selectAll,
                  onChanged: (v){
                    toggleAll();
                  },
                )

              ],
            ),

            Expanded(

              child: ListView.builder(

                itemCount: pending.length,

                itemBuilder:(context,index){

                  var p = pending[index];

                  return Container(

                    margin: EdgeInsets.only(bottom:10),
                    padding: EdgeInsets.all(15),

                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(

                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [

                        Row(

                          children: [

                            Checkbox(

                              value: selected[p["phone"]] ?? false,

                              onChanged:(v){

                                selected[p["phone"]] = v;
                                setState(() {});

                              },

                            ),

                            Text(
                              p["name"],
                              style: TextStyle(fontSize:16),
                            ),

                          ],
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
                            "Pending ₹${p["pending_amount"]}",
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

              onPressed: showUpiPopup,

              child: Text("Send Message"),

            )

          ],

        ),

      ),

    );
  }
}