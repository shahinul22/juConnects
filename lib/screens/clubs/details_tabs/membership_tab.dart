import 'package:flutter/material.dart';
import '../../../models/club_model.dart';
import '../../../models/join_request_model.dart';
import '../../../service/club_service.dart';
import 'add_member_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MembershipTab extends StatefulWidget {
  final Club club;

  MembershipTab({required this.club});

  @override
  State<MembershipTab> createState() => _MembershipTabState();
}

class _MembershipTabState extends State<MembershipTab> {
  final ClubService service = ClubService();
  List<Map<String, dynamic>> requests = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _listenRequests();
  }

  void _listenRequests() {
    service.getJoinRequests(widget.club.id).listen((data) {
      setState(() {
        requests = data;
        loading = false;
      });
    });
  }

  Future<Map<String, dynamic>> _getUserData(String uid) async {
    final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return snap.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final isAdmin = widget.club.admins.contains(uid);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Join Our Community",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(widget.club.whoCanJoin),
          const SizedBox(height: 20),

          // ADMIN: Toggle Join Button
          if (isAdmin)
            ElevatedButton(
              onPressed: () async {
                await service.toggleJoinButton(widget.club.id, !widget.club.joinButtonEnabled);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(widget.club.joinButtonEnabled
                        ? "Join Button Disabled"
                        : "Join Button Enabled"),
                  ),
                );
              },
              child: Text(widget.club.joinButtonEnabled
                  ? "Disable Join Button"
                  : "Enable Join Button"),
            ),

          const SizedBox(height: 20),

          // USER: Request to Join
          if (!isAdmin && widget.club.joinButtonEnabled && !widget.club.members.contains(uid))
            ElevatedButton(
              onPressed: () async {
                final userData = await _getUserData(uid);

                final request = JoinRequest(
                  uid: uid,
                  name: userData["fullName"] ?? "Unknown",
                  email: userData["email"] ?? "No Email",
                  image: userData["profilePicUrl"] ?? "https://i.imgur.com/8x8gK4h.png",
                  hall: userData["hall"] ?? "Unknown Hall",
                  studentId: userData["studentId"] ?? "Unknown",
                  department: userData["department"] ?? "Unknown",
                  session: userData["session"] ?? "Unknown",
                  phone: userData["phone"] ?? "N/A",
                  timestamp: DateTime.now(),
                );

                await service.sendJoinRequest(
                  clubId: widget.club.id,
                  uid: request.uid,
                  name: request.name,
                  email: request.email,
                  image: request.image,
                  hall: request.hall,
                  studentId: request.studentId,
                  department: request.department,
                  session: request.session,
                  phone: request.phone,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Join request submitted")),
                );
              },
              child: Text("Request to Join Club"),
            ),

          const SizedBox(height: 30),

          // ADMIN: Pending Join Requests
          if (isAdmin)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pending Join Requests",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (loading) Center(child: CircularProgressIndicator()),
                if (!loading && requests.isEmpty)
                  Text("No pending requests."),
                if (!loading && requests.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final req = requests[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                req['image'] ?? "https://i.imgur.com/8x8gK4h.png"),
                          ),
                          title: Text(req['name'] ?? "Unknown"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Email: ${req['email'] ?? "N/A"}"),
                              Text("Department: ${req['department'] ?? "N/A"}"),
                              Text("Session: ${req['session'] ?? "N/A"}"),
                              Text("Hall: ${req['hall'] ?? "N/A"}"),
                              Text("Phone: ${req['phone'] ?? "N/A"}"),
                              Text("Student ID: ${req['studentId'] ?? "N/A"}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green),
                                onPressed: () async {
                                  await service.approveRequest(
                                    clubId: widget.club.id,
                                    uid: req['uid'],
                                  );
                                  setState(() {
                                    requests.removeAt(index);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("${req['name']} approved")),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () async {
                                  await service.rejectRequest(
                                    clubId: widget.club.id,
                                    uid: req['uid'],
                                  );
                                  setState(() {
                                    requests.removeAt(index);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("${req['name']} rejected")),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),

          const SizedBox(height: 20),

          // ADMIN: Add Member Manually
          if (isAdmin)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddMemberForm(club: widget.club),
                  ),
                );
              },
              child: Text("Add Member / Advisor"),
            ),
        ],
      ),
    );
  }
}
