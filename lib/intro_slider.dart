import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_signup/login_screen.dart';
import 'main_screens/home_screen.dart';

class IntroSlider extends StatefulWidget {
  const IntroSlider({super.key});

  @override
  _IntroSliderState createState() => _IntroSliderState();
}

class _IntroSliderState extends State<IntroSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _introData = [
    {'title': 'Welcome to Wizz', 'description': 'Your all-in-one team management app.', 'icon': Icons.dashboard},
    {'title': 'Stay Connected', 'description': 'Chat with your team seamlessly.', 'icon': Icons.chat_bubble_outline},
    {'title': 'Track Progress', 'description': 'Keep an eye on tasks and reports powered by DeepSeek.', 'icon': Icons.timeline},
  ];

  @override
  void initState() {
    super.initState();
    _checkIfSeen(context);
  }

  Future<void> _checkIfSeen(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? seenIntro = prefs.getBool('seenIntro');

    if (seenIntro == true) {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
        );
      }
    }
  }

  Future<void> _setSeenIntro() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenIntro', true);
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _introData.length,
            itemBuilder: (context, index) => IntroPage(
              title: _introData[index]['title']!,
              description: _introData[index]['description']!,
              icon: _introData[index]['icon']!,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: TextButton(
              onPressed: () {
                _setSeenIntro();
                String? uid = FirebaseAuth.instance.currentUser?.uid;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => uid == null ? LoginScreen() : HomeScreen()),
                );
              },
              child: const Text('Skip', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: _currentPage == _introData.length - 1
                  ? () {
                _setSeenIntro();
                String? uid = FirebaseAuth.instance.currentUser?.uid;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => uid == null ? LoginScreen() : HomeScreen()),
                );
              }
                  : () => _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease),
              child: Text(_currentPage == _introData.length - 1 ? 'Get Started' : 'Next',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_introData.length, (index) => buildDot(index)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index) => Container(
    margin: EdgeInsets.only(right: 5),
    height: 10,
    width: _currentPage == index ? 20 : 10,
    decoration: BoxDecoration(
      color: _currentPage == index ? Colors.blue : Colors.grey,
      borderRadius: BorderRadius.circular(5),
    ),
  );
}

class IntroPage extends StatelessWidget {
  final String title, description;
  final IconData icon;

  const IntroPage({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 150, color: Colors.blueAccent),
        SizedBox(height: 20),
        Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      ],
    );
  }
}
