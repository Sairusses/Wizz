import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:wizz/leader_screens/leader_dashboard.dart';
import 'package:wizz/leader_screens/leader_reports.dart';
import 'package:wizz/main_screens/ai_window_screen.dart';
import 'package:wizz/main_screens/profile_screen.dart';
import 'package:wizz/member_screens/member_dashboard.dart';
import 'package:wizz/member_screens/member_reports.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget{
  final String role;
  const HomeScreen({required this.role, super.key});

  @override
  HomeScreenState createState() => HomeScreenState();

}
class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;
  late int currentPage;
  ValueNotifier<bool> isBottomBarVisible = ValueNotifier(true);
  String? teamId;
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    _initializeTeamId();
    currentPage = 0;
    tabController = TabController(length: 5, vsync: this);
    tabController.animation!.addListener(
          () {
        final value = tabController.animation!.value.round();
        if (value != currentPage && mounted) {
          changePage(value);
        }
      },
    );
    super.initState();
  }

  void _initializeTeamId() async {
    try {
      String? team = await FirestoreService().getUserTeam();
      setState(() {
        teamId = team;
      });
      _fetchInProgressTasks();
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      AuthService().showToast("Error fetching team: $error");
    }
  }
  void _fetchInProgressTasks() async {
    try {
      if (teamId != null) {
        List<Map<String, dynamic>> fetchedTasks = await FirestoreService().fetchInProgressTasks(teamId!);
        setState(() {
          tasks = fetchedTasks;
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      AuthService().showToast("Error fetching tasks: $error");
    }
  }

  void changePage(int newPage) {
    setState(() {
      currentPage = newPage;
      isBottomBarVisible.value = newPage == 0;
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    isBottomBarVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(isLoading){
      return Scaffold(
        body: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.black54),
                const SizedBox(height: 10),
                const Text(
                  'Loading leader dashboard...',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }else{
      return Scaffold(
        body: ValueListenableBuilder<bool>(
            valueListenable: isBottomBarVisible,
            builder: (context, isVisible, child){
              return BottomBar(
                clip: Clip.none,
                fit: StackFit.expand,
                icon: (width, height) => Center(
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: null,
                    icon: Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: width,
                    ),
                  ),
                ),
                borderRadius: BorderRadius.circular(250),
                duration: Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
                showIcon: true,
                width: MediaQuery.of(context).size.width * 0.8,
                barColor: Colors.black87,
                start: 2,
                end: 0,
                offset: 10,
                iconHeight: 35,
                iconWidth: 35,
                barAlignment: Alignment.bottomCenter,
                hideOnScroll: true,
                scrollOpposite: false,
                body: (context, controller) => TabBarView(
                    controller: tabController,
                    dragStartBehavior: DragStartBehavior.down,
                    children: [
                      widget.role == "member"
                          ? MemberDashboard(controller: controller)
                          : LeaderDashboard(teamId: teamId!, tasks: tasks),
                      ChatsScreen(),
                      AIWindowScreen(),
                      widget.role == "member" ? ReportsMember() : ReportsLeader(),
                      ProfileScreen(),
                    ]
                ),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    TabBar(
                      dividerColor: Colors.transparent,
                      indicatorPadding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      controller: tabController,
                      indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(
                            color: Colors.blueGrey,
                            width: 4,
                          ),
                          insets: EdgeInsets.fromLTRB(16, 0, 16, 8)),
                      tabs: [
                        SizedBox(
                          height: 55,
                          width: 40,
                          child: Center(
                              child: Icon(
                                Icons.home,
                                color: currentPage == 0 ? Colors.blueGrey : Colors.white,
                              )),
                        ),
                        SizedBox(
                          height: 55,
                          width: 40,
                          child: Center(
                            child: Icon(
                              Icons.chat,
                              color: currentPage == 1 ? Colors.blueGrey : Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 55,
                          width: 40,
                          child: Center(
                            child: Icon(
                              Symbols.robot_2,
                              color: currentPage == 2 ? Colors.blueGrey : Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 55,
                          width: 40,
                          child: Center(
                            child: Icon(
                              Symbols.graph_3,
                              color: currentPage == 3 ? Colors.blueGrey : Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 55,
                          width: 40,
                          child: Center(
                            child: Icon(
                              Icons.person,
                              color: currentPage == 4 ? Colors.blueGrey : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
        ),
      );
    }
  }


}