import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/auth_service.dart';

class StaffDashboardScreen extends StatefulWidget {
  final String userId;

  const StaffDashboardScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _StaffDashboardScreenState createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  final AuthService _auth = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;

  Map<String, dynamic>? staffData;

  @override
  void initState() {
    super.initState();
    _fetchStaffData();
  }

  Future<void> _fetchStaffData() async {
    try {
      final doc = await _firestore.collection('users').doc(widget.userId).get();
      if (doc.exists) {
        setState(() {
          staffData = doc.data();
          isLoading = false;
        });
      } else {
        setState(() {
          staffData = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching staff data: $e");
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
        title: const Text('Staff Dashboard'),
        backgroundColor: Colors.teal,
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
          : staffData == null
          ? const Center(child: Text('No data found'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Name and Designation
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                staffData!['profilePicUrl'] ?? 'https://i.imgur.com/8x8gK4h.png',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              staffData!['fullName'] ?? 'Staff Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              staffData!['designation'] ?? 'Position',
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
            _buildInfoRow('Department/Unit', staffData!['department'] ?? 'N/A', Icons.apartment),
            const Divider(),
            _buildInfoRow('Email', staffData!['email'] ?? 'N/A', Icons.email, onTap: () {
              _launchURL('mailto:${staffData!['email']}');
            }),
            const Divider(),
            _buildInfoRow('Phone', staffData!['phoneNumber'] ?? 'N/A', Icons.phone, onTap: () {
              _launchURL('tel:${staffData!['phoneNumber']}');
            }),
            const Divider(),
            _buildInfoRow('Address', staffData!['address'] ?? 'N/A', Icons.location_on),
            const Divider(),
            if (staffData!['facebookId'] != null && staffData!['facebookId'] != '')
              _buildInfoRow('Facebook', staffData!['facebookId'], Icons.facebook, onTap: () {
                _launchURL('https://facebook.com/${staffData!['facebookId']}');
              }),
            if (staffData!['instagram'] != null && staffData!['instagram'] != '')
              _buildInfoRow('Instagram', staffData!['instagram'], Icons.camera_alt, onTap: () {
                _launchURL('https://instagram.com/${staffData!['instagram'].replaceAll("@", "")}');
              }),
            if (staffData!['whatsapp'] != null && staffData!['whatsapp'] != '')
              _buildInfoRow('WhatsApp', staffData!['whatsapp'], Icons.chat, onTap: () {
                _launchURL('https://wa.me/${staffData!['whatsapp'].replaceAll(RegExp(r'[^0-9]'), '')}');
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value),
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }
}
