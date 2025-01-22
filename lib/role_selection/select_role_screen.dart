import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wizz/role_selection/create_team.dart';
import 'package:wizz/role_selection/join_team.dart';
import 'package:wizz/services/firestore_service.dart';

import '../services/auth_service.dart';

class SelectRole extends StatelessWidget{
  const SelectRole({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfafafafa),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 75),
          Header(),
          SizedBox(height: 35),
          LeaderBox(),
          SizedBox(height: 15,),
          MemberBox(),
          SizedBox(height: 15,),
          Text(
            'You can change your role later in settings',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w300,
              color: Colors.black54,
              fontSize: 12
            ),
          )


        ],
      ),
    );
  }
  
}

class MemberBox extends StatelessWidget{
  const MemberBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: 300,
      width: double.infinity,
      child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 50,
                      width: 52,
                      child: Image(
                        image: AssetImage('assets/member_icon.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    SizedBox(width: 10,),
                    Text(
                      'Member',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.black
                      ),
                    )
                  ],
                ),
                SizedBox(height: 25,),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.black87),
                    SizedBox(width: 5), // Space between icon and text
                    Text(
                      "View and update assigned tasks",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w300
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12,),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.black87),
                    SizedBox(width: 5), // Space between icon and text
                    Text(
                      "Collaborate with team members",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w300
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14,),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.black87),
                    SizedBox(width: 5), // Space between icon and text
                    Text(
                      "Track personal progress",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w300
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async{
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Center(child: CircularProgressIndicator(color: Colors.black)),
                      );
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> JoinTeam()));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey)
                        )
                    ),
                    child: Text('Select Member Role'),
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }

}

class LeaderBox extends StatelessWidget{
  const LeaderBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: 300,
      width: double.infinity,
      child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
        child: Padding(
            padding: EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 50,
                    width: 52,
                    child: Image(
                      image: AssetImage('assets/leader_icon.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  SizedBox(width: 10,),
                  Text(
                    'Leader',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.black
                    ),
                  )
                ],
              ),
              SizedBox(height: 25,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: Colors.black87),
                  SizedBox(width: 5), // Space between icon and text
                  Text(
                    "Manage team tasks and assignments",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w300
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: Colors.black87),
                  SizedBox(width: 5), // Space between icon and text
                  Text(
                    "Access AI-powered forecasting tools",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w300
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: Colors.black87),
                  SizedBox(width: 5), // Space between icon and text
                  Text(
                    "Set project milestones and deadlines",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w300
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async{
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Center(child: CircularProgressIndicator(color: Colors.black)),
                    );
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> CreateTeam()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      )
                  ),
                  child: Text('Select Leader Role'),
                ),
              ),

            ],
          ),
        )
      ),
    );
  }

}

class Header extends StatelessWidget{
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'Choose Your Role',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.black
            ),
          ),
          SizedBox(height: 10,),
          Text(
            "Select how you'll participate in the project",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.black
            ),
          )
        ],
      ),
    );
  }

}

class BackButton extends StatelessWidget{
  const BackButton({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 20,),
        IconButton(
          onPressed: (){},
          icon: Icon(Icons.arrow_back),
          iconSize: 32,
          color: Colors.black,

        )
      ],
    );
  }

}