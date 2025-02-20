import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:wizz/services/task_service.dart';
import '../services/auth_service.dart';
import '../services/budget_service.dart';
import '../services/team_service.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();

}
class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;
  late int currentPage;
  ValueNotifier<bool> isBottomBarVisible = ValueNotifier(true);
  String? userId;
  String? teamId;
  String? role;
  List<Map<String, dynamic>> allTasks = [];
  List<Map<String, dynamic>> allTasksAssignedToMember = [];
  List<Map<String, dynamic>> inProgressTasksAssignedToMember = [];
  List<Map<String, dynamic>> completedTasksAssignedToMember = [];
  List<Map<String, dynamic>> dueTodayTasksAssignedToMember = [];
  late int teamBudget;
  late int teamBudgetSpent;
  bool isLoading = true;

  @override
  void initState() {
    userId = FirebaseAuth.instance.currentUser?.uid;
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
      String? team = await TeamService().getUserTeam();
      String? role = await TeamService().getUserRole();
      setState(() {
        this.role = role;
        teamId = team;
      });
      _fetchAllTasks();
      _fetchBudget();
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      AuthService().showToast("Error fetching team: $error");
    }
  }

  void _fetchAllTasks() async {
    try {
      if (teamId != null) {
        if(role == 'leader'){
          List<Map<String, dynamic>> fetchedAllTasks = await TaskService().fetchAllTasks(teamId!);
          setState(() {
            allTasks = fetchedAllTasks;
          });
        }else{
          List<Map<String, dynamic>> fetchedAllTasksAssignedToMember
          = await TaskService().fetchAllTasksAssignedToUser(userId!, teamId!);
          List<Map<String, dynamic>> fetchedInProgressTasksAssignedToMember
          = await TaskService().fetchInProgressTasksAssignedTo(userId!, teamId!);
          List<Map<String, dynamic>> fetchedCompletedTasksAssignedToMember
          = await TaskService().fetchCompletedTasksAssignedTo(userId!, teamId!);
          List<Map<String, dynamic>> fetchedDueTodayTasksAssignedToMember
          = await TaskService().fetchDueTodayTasksAssignedTo(userId!, teamId!);
          setState(() {
            allTasksAssignedToMember = fetchedAllTasksAssignedToMember;
            inProgressTasksAssignedToMember = fetchedInProgressTasksAssignedToMember;
            completedTasksAssignedToMember = fetchedCompletedTasksAssignedToMember;
            dueTodayTasksAssignedToMember = fetchedDueTodayTasksAssignedToMember;
          });
        }
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      AuthService().showToast("Error fetching tasks: $error");
    }
  }

  void _fetchBudget() async{
    BudgetService budgetService = BudgetService();
    int totalBudgetSpent = await budgetService.getTotalSpentBudget(teamId!);
    int totalBudget = await budgetService.getTeamBudget(teamId!);
    setState(() {
      teamBudgetSpent = totalBudgetSpent;
      teamBudget = totalBudget;
      isLoading = false;
    });
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
        backgroundColor: Colors.grey[200],
        body: Center(
          child: Dialog(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                height: MediaQuery.of(context).size.height*.25,
                width: MediaQuery.of(context).size.width*.25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.black54),
                    const SizedBox(height: 10),
                    const Text(
                      'Loading user data...',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
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
              curve: Curves.linear,
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
                  role == "member"
                    ? MemberDashboard(
                      controller: controller,
                      userId: userId!,
                      teamId: teamId!,
                      allTasks: allTasksAssignedToMember,
                      inProgressTasks: inProgressTasksAssignedToMember,
                      completedTasks: completedTasksAssignedToMember,
                      dueTodayTasks: dueTodayTasksAssignedToMember,
                    )
                    : LeaderDashboard(teamId: teamId!, tasks: allTasks, teamBudget: teamBudget, teamBudgetSpent: teamBudgetSpent,),
                  ChatsScreen(),
                  AIWindowScreen(),
                  role == "member" ? ReportsMember() : ReportsLeader(),
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
                      insets: EdgeInsets.fromLTRB(16, 0, 16, 8)
                    ),
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