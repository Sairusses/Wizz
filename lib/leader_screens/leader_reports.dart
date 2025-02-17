import 'package:flutter/material.dart';

class ReportsLeader extends StatefulWidget {
  const ReportsLeader({super.key});

  @override
  ReportsLeaderState createState() => ReportsLeaderState();
}

class ReportsLeaderState extends State<ReportsLeader> with AutomaticKeepAliveClientMixin{
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: Center(
          child: Text('Leader Reports'),
        )
    );
  }
}