import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chat_ui_screen.dart';

class ChatsScreen extends StatefulWidget {
  final String teamId;

  const ChatsScreen({super.key, required this.teamId});

  @override
  ChatsScreenState createState() => ChatsScreenState();
}

class ChatsScreenState extends State<ChatsScreen> with AutomaticKeepAliveClientMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = "";

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _AppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search members...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('teams').doc(widget.teamId).collection('members').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No team members found."));

                var members = snapshot.data!.docs.where((doc) {
                  var member = doc.data() as Map<String, dynamic>;
                  return member['username']?.toLowerCase().contains(searchQuery) ?? false;
                }).toList();

                return ListView(
                  children: members.map((doc) {
                    var member = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        backgroundImage: member['profilePic'] != null
                            ? NetworkImage(member['profilePic'])
                            : null,
                        child: member['profilePic'] == null ? const Icon(Icons.person, color: Colors.white) : null,
                      ),
                      title: Text(member['username'] ?? "Unknown"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatUIScreen(
                              receiverId: member['userID'],
                              receiverName: member['username'],
                              receiverPic: member['profilePic'],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0),
        child: Container(
          color: Colors.black54,
          height: .5,
        ),
      ),
      backgroundColor: Colors.white,
      leading: Icon(Icons.message_rounded),
      title: Text(
        'Chat Dash',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
      ),
    );
  }
}
