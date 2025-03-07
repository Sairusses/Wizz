import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
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
  List<Map<String, dynamic>> budgetList = [];
  late Map<String, String> userMap;
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
      userMap = await fetchUserMap();
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
    _fetchTasksAndExpenses(teamId!);
    setState(() {
      teamBudgetSpent = totalBudgetSpent;
      teamBudget = totalBudget;
      isLoading = false;
    });
  }

  Future<Map<String, String>> fetchUserMap() async {
    Map<String, String> userMap = {};
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    for (var doc in usersSnapshot.docs) {
      userMap[doc.id] = doc['username'];
    }
    return userMap;
  }

  Future<void> _fetchTasksAndExpenses(String teamId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference tasksRef = firestore.collection('teams').doc(teamId).collection('tasks');
    CollectionReference expensesRef = firestore.collection('teams').doc(teamId).collection('expenses');

    try {
      QuerySnapshot tasksSnapshot = await tasksRef.get();
      List<Map<String, dynamic>> tasks = tasksSnapshot.docs.map((doc) {
        return {
          "title": doc["title"] ?? "No Title",
          "description": doc["description"] ?? "No description",
          "budget": doc["budget"] ?? 0.0,
          "created_at": _formatTimestamp(doc["created_at"])
        };
      }).toList();

      QuerySnapshot expensesSnapshot = await expensesRef.get();
      List<Map<String, dynamic>> expenses = expensesSnapshot.docs.map((doc) {
        return {
          "title": doc["title"] ?? "No Title",
          "description": doc["description"] ?? "No description",
          "budget": doc["budget"] ?? 0.0,
          "created_at": _formatTimestamp(doc["date"])
        };
      }).toList();

      List<Map<String, dynamic>> combinedData = [...tasks, ...expenses];

      List<Map<String, dynamic>> uniqueBudgetList = [];
      Set<String> seenItems = {};

      for (var item in combinedData) {
        String uniqueKey = "${item['title']}";
        if (!seenItems.contains(uniqueKey)) {
          seenItems.add(uniqueKey);
          uniqueBudgetList.add(item);
        }
      }

      setState(() {
        budgetList = uniqueBudgetList;
      });


    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('MM/dd/yyyy').format(dateTime);
    }
    return "Unknown Date";
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
        backgroundColor: Colors.grey[50],
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width*.55,
            height: MediaQuery.of(context).size.height*.25,
            child: Card(
              elevation: 6,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SpinKitPouringHourGlass(color: Colors.blueAccent),
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
                physics: PageScrollPhysics(),
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
                    : LeaderDashboard(teamId: teamId!, tasks: allTasks, teamBudget: teamBudget, teamBudgetSpent: teamBudgetSpent),
                  ChatsScreen(teamId: teamId!),
                  AIWindowScreen(allTasks: allTasks, budgetList: budgetList, teamBudget: teamBudget, teamBudgetSpent: teamBudgetSpent, userMap: userMap,),
                  role == "member"
                      ? ReportsMember()
                      : ReportsLeader(userMap: userMap, tasks: allTasks, teamBudget: teamBudget, teamBudgetSpent: teamBudgetSpent, budgetList: budgetList,),
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
                        color: Colors.blueAccent,
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
                            color: currentPage == 0 ? Colors.blueAccent : Colors.white,
                          )),
                      ),
                      SizedBox(
                        height: 55,
                        width: 40,
                        child: Center(
                          child: Icon(
                            Icons.chat,
                            color: currentPage == 1 ? Colors.blueAccent : Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 55,
                        width: 40,
                        child: Center(
                          child: Icon(
                            Symbols.robot_2,
                            color: currentPage == 2 ? Colors.blueAccent : Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 55,
                        width: 40,
                        child: Center(
                          child: Icon(
                            Symbols.graph_3,
                            color: currentPage == 3 ? Colors.blueAccent : Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 55,
                        width: 40,
                        child: Center(
                          child: Icon(
                            Icons.person,
                            color: currentPage == 4 ? Colors.blueAccent : Colors.white,
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