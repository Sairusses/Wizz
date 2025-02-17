import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wizz/role_selection/select_role_screen.dart';
import 'package:wizz/services/team_service.dart';

import '../main_screens/home_screen.dart';

class JoinTeam extends StatelessWidget {
  JoinTeam({super.key});
  final TextEditingController _teamCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _JoinTeamAppBar(),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _TeamAvatar(),
            SizedBox(height: 16),
            _TitleText(),
            SizedBox(height: 8),
            _SubtitleText(),
            SizedBox(height: 16),
            _TeamCodeInput(controller: _teamCodeController),
            SizedBox(height: 25),
            _JoinButton(controller: _teamCodeController),
            SizedBox(height: 16),
            _ContactInfo(),
          ],
        ),
      ),
    );
  }
}

class _JoinTeamAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text(
        "Join Team",
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 25),
        color: Colors.black,
        //on press
        onPressed: () {
          Future.microtask(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SelectRole()),
            );
          });
        },
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(4.0),
        child: Divider(color: Colors.grey, height: 1.0),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TeamAvatar extends StatelessWidget {
  const _TeamAvatar();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 40,
      backgroundColor: Colors.black12,
      child: Icon(Icons.groups, size: 40, color: Colors.black),
    );
  }
}

class _TitleText extends StatelessWidget {
  const _TitleText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Enter Team Code",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }
}

class _SubtitleText extends StatelessWidget {
  const _SubtitleText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Enter the code provided by your team leader",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey),
    );
  }
}

class _TeamCodeInput extends StatelessWidget {
  final TextEditingController controller;
   const _TeamCodeInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Team Code", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(fontSize: 14, color: Colors.black),
          decoration: InputDecoration(
            hintText: "Enter code (e.g., TEAM123)",
            hintStyle: TextStyle(fontSize: 14, color: Colors.black54),
            suffixIconColor: Colors.black87,
            suffixIcon: IconButton(onPressed: ()=> controller.clear(), icon: Icon(Icons.clear)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(color: Colors.black, width: 1),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ],
    );
  }
}

class _JoinButton extends StatelessWidget {
  final TextEditingController controller;
  const _JoinButton({required this.controller});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return Center(child: CircularProgressIndicator());
            },
          );
          String? teamID = await TeamService().validateTeamCode(controller.text);
          String? uid = FirebaseAuth.instance.currentUser?.uid;
          if (teamID != null && uid != null) {
            await TeamService().assignUserToTeam(uid, teamID);

            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false,
            );
          } else {
            Navigator.pop(context);
            Fluttertoast.showToast(
              msg: 'Team code does not exist',
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Colors.grey,
              textColor: Colors.black,
              fontSize: 14,
              gravity: ToastGravity.SNACKBAR,
            );
          }
        },

        child: const Text("Join Team"),
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  const _ContactInfo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Don't have a code?",
          style: TextStyle(fontSize: 14, fontFamily: 'Inter', color: Colors.black54),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            "Contact your team leader",
            style: TextStyle(fontSize: 14, fontFamily: 'Inter', color: Colors.black),
          ),
        ),
      ],
    );
  }
}

