import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateControPage extends StatefulWidget {

  final int userId;

  CreateControPage(this.userId);

  @override
  State<CreateControPage> createState() => _CreateControPageState();
}

class _CreateControPageState extends State<CreateControPage> {

  TextEditingController name = TextEditingController();
  TextEditingController amount = TextEditingController();

  List members = [];
  List selectedMembers = [];

  // ✅ NEW: Category variable
  String selectedCategory = "other";

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

  loadMembers() async {
    members = await ApiService.membersList(widget.userId);
    setState(() {});
  }

  createContro() async {

    if(name.text.isEmpty || amount.text.isEmpty || selectedMembers.isEmpty){
      return;
    }

    await ApiService.createContro(
      widget.userId,
      name.text,
      int.parse(amount.text),
      selectedMembers,
      selectedCategory, // ✅ send category
    );

    Navigator.pop(context,true);
  }

  showMemberSelector(){

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      builder:(context){

        return StatefulBuilder(
          builder:(context,setModal){

            return Container(
              padding: EdgeInsets.all(20),
              height: 400,

              child: Column(
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Text(
                        "Select Members",
                        style: TextStyle(
                          fontSize:18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      IconButton(
                        icon: Icon(Icons.person_add),
                        onPressed: (){
                          addMemberPopup();
                        },
                      )

                    ],
                  ),

                  Expanded(
                    child: ListView.builder(
                      itemCount: members.length,

                      itemBuilder:(context,index){

                        var m = members[index];

                        bool checked =
                            selectedMembers.contains(m["id"]);

                        return CheckboxListTile(

                          value: checked,
                          title: Text(m["name"]),

                          onChanged:(v){

                            if(v!){
                              selectedMembers.add(m["id"]);
                            }else{
                              selectedMembers.remove(m["id"]);
                            }

                            setModal((){});
                          },

                        );

                      },

                    ),
                  ),

                  ElevatedButton(
                    onPressed:(){
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: Text("Done"),
                  )

                ],
              ),
            );
          },
        );
      },
    );
  }

  addMemberPopup(){

    TextEditingController mName = TextEditingController();
    TextEditingController mPhone = TextEditingController();

    showDialog(
      context: context,

      builder:(context){

        return AlertDialog(

          title: Text("Add Member"),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              TextField(
                controller: mName,
                decoration: InputDecoration(labelText:"Member Name"),
              ),

              TextField(
                controller: mPhone,
                decoration: InputDecoration(labelText:"Phone No"),
              ),

            ],
          ),

          actions: [

            ElevatedButton(
              onPressed: () async {

                if(mName.text.isEmpty || mPhone.text.isEmpty){
                  return;
                }

                await ApiService.addMember(
                  widget.userId,
                  mName.text,
                  mPhone.text,
                );

                Navigator.pop(context);
                loadMembers();

              },
              child: Text("Add"),
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
        title: Text("Create Contro"),
      ),

      body: Padding(
        padding: EdgeInsets.all(20),

        child: Column(
          children: [

            // Contro Name
            TextField(
              controller: name,
              decoration: InputDecoration(
                labelText: "Contro Name",
              ),
            ),

            SizedBox(height:15),

            // Amount
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount",
              ),
            ),

            SizedBox(height:15),

            // ✅ CATEGORY DROPDOWN
            DropdownButtonFormField<String>(

              value: selectedCategory,

              items: ["travel", "food", "rent", "other"]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.toUpperCase()),
                      ))
                  .toList(),

              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },

              decoration: InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height:20),

            // Member selector
            GestureDetector(

              onTap: showMemberSelector,

              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),

                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Text(
                  selectedMembers.isEmpty
                      ? "Select Members"
                      : "${selectedMembers.length} Members Selected",
                ),
              ),
            ),

            SizedBox(height:30),

            // Submit button
            ElevatedButton(
              onPressed: createContro,
              child: Text("Create Contro"),
            )

          ],
        ),
      ),
    );
  }
}