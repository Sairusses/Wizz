import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'auth_service.dart';

class TeamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<String> getCollectionJson(String teamId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('tasks')
          .get();

      List<Map<String, dynamic>> jsonList = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Convert Firestore Timestamps to ISO 8601 strings
        final formattedData = data.map((key, value) {
          if (value is Timestamp) {
            return MapEntry(key, value.toDate().toIso8601String());
          }
          return MapEntry(key, value);
        });

        return {"id": doc.id, ...formattedData};
      }).toList();

      return jsonEncode(jsonList);
    } catch (e) {
      throw Exception("Failed to fetch tasks: $e");
    }
  }

  Future<String?> getUserTeam() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    QuerySnapshot teamsSnapshot =
    await FirebaseFirestore.instance.collection('teams').get();

    for (var team in teamsSnapshot.docs) {
      var membersCollection = await team.reference.collection('members').doc(userId).get();
      if (membersCollection.exists) {
        return team.id;  // Return the team document ID
      }
    }
    return 'Nothing here'; // User is not in any team
  }

  Future<String?> fetchUserIdByUsername(String username) async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        return userSnapshot.docs.first.id;
      } else {
        AuthService().showToast('User not found for username: $username');
        return null;
      }
    } catch (e) {
      AuthService().showToast('Error fetching userId: $e');
      return null;
    }
  }

  Future<String?> getUsername(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc['username'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      AuthService().showToast('Error fetching username: $e');
      return null;
    }
  }
  Future<String?> getUserRole() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        return userDoc['role'];
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user role: $e");
      return null;
    }
  }

  Future<void> createTeam({
    required String teamName,
    required String teamCode,
    required String teamDescription,
    required String leaderId,
  }) async {
    try {
      DocumentReference newTeamRef = _firestore.collection('teams').doc();

      await newTeamRef.set({
        'teamName': teamName,
        'teamCode': teamCode,
        'teamDescription': teamDescription,
        'leaderID': leaderId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      String? username = await getUsername(leaderId);
      await newTeamRef.collection('members').doc(leaderId).set({
        'userID': leaderId,
        'role': 'leader',
        'username': username,
        'joinedAt': Timestamp.now(),
      });

      await _firestore.collection('users').doc(leaderId).update({
        'teamId': newTeamRef.id,
        'role': 'leader',
      });
    } catch (e) {
      throw Exception('Failed to create team: $e');
    }
  }

  Future<void> assignUserToTeam(String userId, String teamId) async {
    try {
      String? username = await getUsername(userId);
      await _firestore.collection('users').doc(userId).update({'teamId': teamId, 'role': 'member'});
      await _firestore.collection('teams').doc(teamId).collection('members').doc(userId).set({
        'userID': userId,
        'role': 'member',
        'username': username,
        'joinedAt': Timestamp.now(),
      });
    } catch (e) {
      AuthService().showToast('Error assigning user to team: $e');
    }
  }

  Future<String?> validateTeamCode(String teamCode) async {
    try {
      QuerySnapshot query = await _firestore.collection('teams').where('teamCode', isEqualTo: teamCode).limit(1).get();
      return query.docs.isNotEmpty ? query.docs.first.id : null;
    } catch (e) {
      AuthService().showToast('Error validating team code: $e');
      return null;
    }
  }

}