import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../main_screens/home_screen.dart';
import '../services/team_service.dart';

class CreateTeam extends StatelessWidget{
  const CreateTeam({super.key});
  @override
  Widget build(BuildContext context) {
    TextEditingController teamNameController = TextEditingController();
    TextEditingController teamCodeController = TextEditingController();
    TextEditingController teamDescriptionController = TextEditingController();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: Colors.black54,
              height: .5,
            )
        ),
        title: Text('Create Team',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
        ),
        leading: IconButton(
            onPressed: ()=> Navigator.pop(context),
            icon: Icon(Icons.arrow_back,
              color: Colors.black,
            ),
        ),
      ),
      body: Container(
        color: Colors.grey[50],
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 10,
            children: [
              Text('Team Name',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.normal,
                  color: Colors.black
                ),
              ),
              TextFormField(
                controller: teamNameController,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter',
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter team name',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Inter',
                    color: Colors.black54,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(10),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Colors.black, width: 1.3),
                  ),
                )
              ),
              Text('Team Code',
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                    color: Colors.black
                ),
              ),
              TextFormField(
                  controller: teamCodeController,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Inter',
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter team code',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                      color: Colors.black54,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: const EdgeInsets.all(10),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.black, width: 1.3),
                    ),
                  )
              ),
              Text('Team Description',
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                    color: Colors.black
                ),
              ),
              TextFormField(
                  controller: teamDescriptionController,
                  maxLines: 4,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Inter',
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: "Describe your team's purpose",
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                      color: Colors.black54,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.black, width: 1.3),
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * .8,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () async {
            // Validate input fields (e.g., controllers must not be empty)
            if (teamNameController.text.trim().isEmpty ||
                teamCodeController.text.trim().isEmpty ||
                teamDescriptionController.text.trim().isEmpty) {
              Fluttertoast.showToast(
                msg: 'Please fill in all fields',
                backgroundColor: Colors.red,
                textColor: Colors.white,
              );
              return;
            }

            // Show loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return const Center(child: CircularProgressIndicator(color: Colors.blueGrey,));
              },
            );

            try {
              // Call the createTeam method
              await TeamService().createTeam(
                teamName: teamNameController.text.trim(),
                teamCode: teamCodeController.text.trim(),
                teamDescription: teamDescriptionController.text.trim(),
                leaderId: FirebaseAuth.instance.currentUser!.uid,
              );

              // Close loading indicator
              Navigator.pop(context);

              // Show success message
              Fluttertoast.showToast(
                msg: 'Team created successfully!',
                backgroundColor: Colors.grey,
                textColor: Colors.white,
              );

              // Navigate to the desired screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(role: 'leader')),
              );
            } catch (error) {
              // Close loading indicator
              Navigator.pop(context);

              // Show error message
              Fluttertoast.showToast(
                msg: 'Failed to create team: $error',
                backgroundColor: Colors.red,
                textColor: Colors.white,
              );
            }
          },
          child: const Text("Create Team"),
        ),
      ),

    );
  }
  
}