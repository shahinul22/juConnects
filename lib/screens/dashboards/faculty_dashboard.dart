import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/auth_service.dart';

class FacultyDashboardScreen extends StatefulWidget {
  final String userId;

  const FacultyDashboardScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _FacultyDashboardScreenState createState() => _FacultyDashboardScreenState();
}

class _FacultyDashboardScreenState extends State<FacultyDashboardScreen> {
  final AuthService _auth = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;

  Map<String, dynamic>? facultyData;

  @override
  void initState() {
    super.initState();
    _fetchFacultyData();
  }

  Future<void> _fetchFacultyData() async {
    try {
      final doc = await _firestore.collection('users').doc(widget.userId).get();
      if (doc.exists) {
        setState(() {
          facultyData = doc.data();
          isLoading = false;
        });
      } else {
        setState(() {
          facultyData = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching faculty data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Dashboard'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : facultyData == null
          ? const Center(child: Text('No data found'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Name and Designation
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                  facultyData!['profilePicUrl'] ?? 'https://i.imgur.com/8x8gK4h.png'),
            ),
            const SizedBox(height: 16),
            Text(
              facultyData!['fullName'] ?? 'Faculty Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              facultyData![' '] ?? 'Designation',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow('Department', facultyData!['department'] ?? 'N/A', Icons.apartment),
            const Divider(),
            _buildInfoRow('Email', facultyData!['email'] ?? 'N/A', Icons.email, onTap: () {
              _launchURL('mailto:${facultyData!['email']}');
            }),
            const Divider(),
            _buildInfoRow('Phone', facultyData!['phoneNumber'] ?? 'N/A', Icons.phone, onTap: () {
              _launchURL('tel:${facultyData!['phoneNumber']}');
            }),
            const Divider(),
            _buildInfoRow('Address', facultyData!['address'] ?? 'N/A', Icons.location_on),
            const Divider(),
            if (facultyData!['facebookId'] != null && facultyData!['facebookId'] != '')
              _buildInfoRow('Facebook', facultyData!['facebookId'], Icons.facebook, onTap: () {
                _launchURL('https://facebook.com/${facultyData!['facebookId']}');
              }),
            if (facultyData!['instagram'] != null && facultyData!['instagram'] != '')
              _buildInfoRow('Instagram', facultyData!['instagram'], Icons.camera_alt, onTap: () {
                _launchURL('https://instagram.com/${facultyData!['instagram'].replaceAll("@", "")}');
              }),
            if (facultyData!['whatsapp'] != null && facultyData!['whatsapp'] != '')
              _buildInfoRow('WhatsApp', facultyData!['whatsapp'], Icons.chat, onTap: () {
                _launchURL('https://wa.me/${facultyData!['whatsapp'].replaceAll(RegExp(r'[^0-9]'), '')}');
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value),
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }
}
