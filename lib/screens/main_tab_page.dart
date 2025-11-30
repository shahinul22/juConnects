import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'authentication/login_screen.dart';
import 'dashboards/student_dashboard.dart';
import 'dashboards/faculty_dashboard.dart';
import 'dashboards/staff_dashboard.dart';

import 'feed/feed_page.dart';
import 'notifications/notification_page.dart';
import 'menu/menu_page.dart';

class MainTabPage extends StatefulWidget {
  const MainTabPage({Key? key}) : super(key: key);

  @override
  _MainTabPageState createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  int _currentIndex = 0;
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) return LoginScreen();

    return Scaffold(
      body: _getCurrentTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notices'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }

  Widget _getCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return const FeedPage();
      case 1:
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final role = snapshot.data!['role'];

            if (role == 'Student') {
              return StudentDashboardScreen(userId: user!.uid);
            } else if (role == 'Faculty') {
              return FacultyDashboardScreen(userId: user!.uid);
            } else {
              return StaffDashboardScreen(userId: user!.uid);
            }
          },
        );
      case 2:
        return const NotificationPage();
      case 3:
        return const MenuPage();
      default:
        return const FeedPage();
    }
  }
}
