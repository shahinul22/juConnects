import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
// Keep your existing imports
import '../../core/auth_service.dart';
import 'edit_student_dashboard_screen.dart';
import '../authentication/login_screen.dart';
import 'package:ju_connect/models/user_data.dart';

class StudentDashboardScreen extends StatefulWidget {
  final String userId;
  const StudentDashboardScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _StudentDashboardScreenState createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final AuthService _auth = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserData? userData;
  bool isLoading = true;
  String? errorMessage;

  static const String dummyProfilePic = 'https://i.imgur.com/8x8gK4h.png';
  static const String dummyCoverPic = 'https://i.imgur.com/9k0JzGZ.png';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(widget.userId).get();

      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          userData = UserData.fromFirestore(userDoc);
          isLoading = false;
        });
      } else {
        await _firestore.collection('users').doc(widget.userId).set({
          'fullName': 'New Student',
          'email': FirebaseAuth.instance.currentUser?.email ?? 'N/A',
          'role': 'Student',
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
          'profilePicUrl': dummyProfilePic,
          'coverPicUrl': dummyCoverPic,
          'clubs': [],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        DocumentSnapshot newUserDoc = await _firestore.collection('users').doc(widget.userId).get();
        setState(() {
          userData = UserData.fromFirestore(newUserDoc);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  void _editProfile() async {
    if (userData == null) return;

    final bool? didUpdate = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(userData: userData!)),
    );

    if (didUpdate == true) {
      setState(() => isLoading = true);
      await _fetchUserData();
    }
  }

  // Social launch functions
  void _launchFacebook() async {
    final url = 'https://facebook.com/${userData!.facebookId}';
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
  }

  void _launchInstagram() async {
    final url = 'https://instagram.com/${userData!.instagram.replaceAll('@', '')}';
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
  }

  void _launchWhatsApp() async {
    final url = 'https://wa.me/${userData!.whatsapp.replaceAll(RegExp(r'[^0-9]'), '')}';
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
  }

  void _launchPhone() async {
    final url = 'tel:${userData!.phoneNumber}';
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
  }

  void _launchEmail() async {
    final url = 'mailto:${userData!.email}';
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (userData == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: _buildErrorUI(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // Everything is inside SingleChildScrollView, so it scrolls together
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeaderSection(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoCard(
                    title: 'Basic Information',
                    icon: Icons.person_outline,
                    iconColor: Colors.blue,
                    children: [
                      _buildInfoRowWithAction(Icons.water_drop, 'Blood Group', userData!.bloodGroup, Colors.red),
                      _buildInfoRowWithAction(Icons.apartment, 'Hall/Residence', userData!.hall, Colors.orange),
                      _buildInfoRowWithAction(Icons.work_outline, 'Role', userData!.role, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Educational Information',
                    icon: Icons.school_outlined,
                    iconColor: Colors.purple,
                    children: [
                      _buildInfoRowWithAction(Icons.email_outlined, 'Email', userData!.email, Colors.blue, onTap: _launchEmail),
                      _buildInfoRowWithAction(Icons.badge_outlined, 'Student ID', userData!.idNumber, Colors.indigo),
                      _buildInfoRowWithAction(Icons.business_outlined, 'Department', userData!.department, Colors.teal),
                      _buildInfoRowWithAction(Icons.calendar_today_outlined, 'Session', userData!.session, Colors.amber),
                      if (userData!.roll.isNotEmpty)
                        _buildInfoRowWithAction(Icons.numbers, 'Roll No', userData!.roll, Colors.cyan),
                      if (userData!.school.isNotEmpty)
                        _buildInfoRowWithAction(Icons.school_outlined, 'Previous School', userData!.school, Colors.blueGrey),
                      if (userData!.college.isNotEmpty)
                        _buildInfoRowWithAction(Icons.account_balance_outlined, 'Previous College', userData!.college, Colors.brown),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Clubs & Societies Card ---
                  if (userData!.clubs.isNotEmpty)
                    _buildInfoCard(
                      title: 'Clubs & Societies',
                      icon: Icons.group_outlined,
                      iconColor: Colors.deepPurple,
                      children: userData!.clubs.map((club) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Icon(Icons.circle, size: 10, color: Colors.deepPurple),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${club.clubName} — ${club.role}',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800]),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                  // Contact Details
                  if (_hasContactInfo())
                    _buildInfoCard(
                      title: 'Contact Details',
                      icon: Icons.contacts_outlined,
                      iconColor: Colors.green,
                      children: [
                        if (userData!.phoneNumber.isNotEmpty)
                          _buildInfoRowWithAction(Icons.phone_outlined, 'Phone Number', userData!.phoneNumber, Colors.green, onTap: _launchPhone),
                        if (userData!.whatsapp.isNotEmpty)
                          _buildInfoRowWithAction(Icons.chat_outlined, 'WhatsApp', userData!.whatsapp, Colors.green, onTap: _launchWhatsApp),
                        if (userData!.facebookId.isNotEmpty)
                          _buildInfoRowWithAction(Icons.facebook, 'Facebook', userData!.facebookId, Colors.blue, onTap: _launchFacebook),
                        if (userData!.instagram.isNotEmpty)
                          _buildInfoRowWithAction(Icons.camera_alt_outlined, 'Instagram', userData!.instagram, Colors.pink, onTap: _launchInstagram),
                        if (userData!.address.isNotEmpty)
                          _buildInfoRowWithAction(Icons.location_on_outlined, 'Address', userData!.address, Colors.red),
                      ],
                    ),

                  if (_hasSocialMedia()) _buildSocialMediaCard(),

                  const SizedBox(height: 30),
                ],
              ),
            ),

            // --- Bottom Section (Scrolls with page) ---

            // 1. Zebra Line Separator
            SizedBox(
              height: 12,
              width: double.infinity,
              child: CustomPaint(painter: ZebraStripePainter()),
            ),

            // 2. Action Buttons (White background)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickAction(Icons.edit_note, 'Edit Profile', Colors.indigo, _editProfile),
                  _buildQuickAction(Icons.share, 'Share Profile', Colors.green, () => _showComingSoonSnackbar('Share Profile')),
                  _buildQuickAction(Icons.qr_code, 'QR Code', Colors.orange, () => _showComingSoonSnackbar('QR Code')),
                ],
              ),
            ),
            // Add safe area padding for bottom of screen
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? "Could not load data",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "User ID: ${widget.userId}",
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                _fetchUserData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigo.shade700, Colors.indigo.shade900],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(Colors.indigo.withOpacity(0.4), BlendMode.overlay),
                child: Image.network(userData?.coverPicUrl ?? dummyCoverPic, fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 56,
                      backgroundImage: NetworkImage(userData?.profilePicUrl ?? dummyProfilePic),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(userData?.fullName ?? 'New Student', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Text(userData?.role ?? 'Student', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.5)),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(userData?.email ?? 'N/A', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackbar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withOpacity(0.3), width: 2)
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700]), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required Color iconColor, required List<Widget> children}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey[800])),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.grey[300]!, Colors.grey[100]!]))),
            const SizedBox(height: 16),
            Column(children: children),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRowWithAction(IconData icon, String label, String value, Color iconColor, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: iconColor, size: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
                    ],
                  ),
                ),
                if (onTap != null) Icon(Icons.arrow_outward, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.share_outlined, color: Colors.purple, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Connect With Me', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey[800])),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (userData!.facebookId.isNotEmpty) _socialIconButton(Icons.facebook, Colors.blue, _launchFacebook),
                if (userData!.instagram.isNotEmpty) _socialIconButton(Icons.camera_alt_outlined, Colors.pink, _launchInstagram),
                if (userData!.whatsapp.isNotEmpty) _socialIconButton(Icons.chat_outlined, Colors.green, _launchWhatsApp),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialIconButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(radius: 24, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 24)),
    );
  }

  bool _hasContactInfo() {
    return userData!.phoneNumber.isNotEmpty || userData!.whatsapp.isNotEmpty || userData!.facebookId.isNotEmpty || userData!.instagram.isNotEmpty || userData!.address.isNotEmpty;
  }

  bool _hasSocialMedia() {
    return userData!.facebookId.isNotEmpty || userData!.instagram.isNotEmpty || userData!.whatsapp.isNotEmpty;
  }
}

// Custom Painter for Zebra Stripes
class ZebraStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // 1. Background (Yellow)
    paint.color = const Color(0xFFFFEA00);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // 2. Stripes (Black)
    paint.color = Colors.black;
    const double stripeWidth = 12.0;
    const double gap = 12.0;

    // Draw diagonals from left to right
    for (double i = -size.height; i < size.width; i += (stripeWidth + gap)) {
      final path = Path();
      path.moveTo(i, size.height);
      path.lineTo(i + stripeWidth, size.height);
      path.lineTo(i + stripeWidth + size.height, 0);
      path.lineTo(i + size.height, 0);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}