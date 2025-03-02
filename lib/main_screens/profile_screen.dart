import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wizz/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});


  @override
  ProfileScreenState createState() => ProfileScreenState();


}

class ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin{
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Center(
          child: ElevatedButton(
            onPressed: (){
              AuthService().logout(context);
            },
            child: Text("Log Out")
          )
      ),
    );
  }
}
