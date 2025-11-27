import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up user with email, password, name, and role
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Save user data in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': name,
          'email': email,
          'role': role, // ✅ store the correct role
          'bloodGroup': 'N/A',
          'hall': 'N/A',
          'idNumber': 'N/A',
          'department': 'N/A',
          'session': 'N/A',
          'roll': '',
          'school': '',
          'college': '',
          'address': '',
          'phoneNumber': '',
          'facebookId': '',
          'whatsapp': '',
          'instagram': '',
          'profilePicUrl': 'https://i.imgur.com/8x8gK4h.png',
          'coverPicUrl': 'https://i.imgur.com/9k0JzGZ.png',
        });
      }

      return user;
    } catch (e) {
      print('Sign Up Error: $e');
      return null;
    }
  }

  // Sign in user
  Future<User?> signIn({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Sign In Error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
