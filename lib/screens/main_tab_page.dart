import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// NEW (Correct):
import 'authentication/login_screen.dart';

// 2. IMPORT DASHBOARDS
import 'dashboards/student_dashboard.dart';
import 'dashboards/faculty_dashboard.dart';
import 'dashboards/staff_dashboard.dart';

// 3. IMPORT NEW TABS
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
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (_currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>  LoginScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safety check
    if (_currentUser == null) return  LoginScreen();

    return Scaffold(
      body: _getCurrentTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
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
      // Logic to decide WHICH dashboard to show based on role
        return FutureBuilder<Widget>(
          future: _getDashboardByRole(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));

            // Return the dashboard or a fallback
            return snapshot.data ?? const Center(child: Text("Profile not found"));
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

  Future<Widget> _getDashboardByRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return  LoginScreen();

    // Fetch user role from Firestore
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!doc.exists) return const Center(child: Text("User data not found in Database"));

    final role = doc.data()?['role'];

    // Return correct screen based on role
    if (role == 'Student') return StudentDashboardScreen(userId: user.uid);
    if (role == 'Faculty') return FacultyDashboardScreen(userId: user.uid);
    return StaffDashboardScreen(userId: user.uid);
  }
}