import 'package:flutter/material.dart';
import 'package:wizz/services/auth_service.dart';
import 'package:wizz/services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  final String teamId;
  final String role;

  const ProfileScreen({super.key, required this.uid, required this.teamId, required this.role});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {
  get uid => widget.uid;
  get teamId => widget.teamId;
  get role => widget.role;

  final UserService _userService = UserService();
  String _username = "Loading...";
  String _email = "Loading...";

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    var userData = await _userService.getUserData();
    if (userData != null) {
      setState(() {
        _username = userData['username'] ?? "No Username";
        _email = userData['email'] ?? "No Email";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.black54,
            height: .5,
          ),
        ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildProfileOptions(),
            const SizedBox(height: 20),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage("assets/profile_avatar.png"), // Change to NetworkImage for real images
        ),
        const SizedBox(height: 10),
        Text(
          _username,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          _email,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 5),
        Chip(
          label: Text(role),
          backgroundColor: Colors.blueAccent,
          labelStyle: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildProfileOptions() {
    return Column(
      children: [
        _buildListTile(Icons.edit, "Edit Profile", () {
          // Navigate to edit profile screen
        }),
        _buildListTile(Icons.info, "About Wizz", () {
          // Navigate to about section
        }),
      ],
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[800],
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          AuthService().logout(context);
        },
        child: const Text("Log Out", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
