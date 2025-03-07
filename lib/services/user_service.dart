import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get userId => _auth.currentUser?.uid;

  Future<Map<String, dynamic>?> getUserData() async {
    if (userId == null) return null;

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  Future<void> updateUserData({String? username, String? email}) async {
    if (userId == null) return;

    try {
      Map<String, dynamic> updateData = {};
      if (username != null) updateData['username'] = username;
      if (email != null) {
        await _auth.currentUser!.verifyBeforeUpdateEmail(email); // Update email in FirebaseAuth
        updateData['email'] = email;
      }

      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updateData);
      }
    } catch (e) {
      print("Error updating user data: $e");
    }
  }

  Future<void> updatePassword(String newPassword) async {
    if (_auth.currentUser == null) return;

    try {
      await _auth.currentUser!.updatePassword(newPassword);
      print("Password updated successfully");
    } catch (e) {
      print("Error updating password: $e");
    }
  }
}
