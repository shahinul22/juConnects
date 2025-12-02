import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../service/post_service.dart';
import '../dashboards/faculty_dashboard.dart';
import '../dashboards/staff_dashboard.dart';
import '../dashboards/student_dashboard.dart';
import 'create_post_screen.dart';
import 'comments_screen.dart';
import 'edit_post_screen.dart';

class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  void _openUserProfile(BuildContext context, String uid, String role) {
    if (role == "Student") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StudentDashboardScreen(userId: uid)),
      );
    } else if (role == "Faculty") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FacultyDashboardScreen(userId: uid)),
      );
    } else if (role == "Staff") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StaffDashboardScreen(userId: uid)),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Unknown role")));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsStream = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();

    final currentUser = FirebaseAuth.instance.currentUser;
    final postService = PostService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jahangirnagar University'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePostScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: postsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final postDocs = snapshot.data!.docs;
          if (postDocs.isEmpty) {
            return const Center(child: Text("No posts yet. Be the first!"));
          }

          return ListView.builder(
            itemCount: postDocs.length,
            itemBuilder: (context, idx) {
              final postDoc = postDocs[idx];
              final data = postDoc.data() as Map<String, dynamic>;
              final postId = postDoc.id;

              final authorUid = data['authorUid'] ?? '';
              final authorRole = data['authorRole'] ?? 'Student';
              final authorName = data['authorName']?.toString() ?? 'Unknown';
              final authorPhotoUrl = data['authorPhotoUrl']?.toString() ?? '';
              final content = data['content'] ?? '';
              final imageUrl = data['imageUrl'] ?? '';
              final timestamp = data['timestamp'] as Timestamp?;
              final dateStr = timestamp != null
                  ? DateFormat('MMM d, h:mm a').format(timestamp.toDate())
                  : 'Just now';
              final isOwner = currentUser != null && currentUser.uid == authorUid;

              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                _openUserProfile(context, authorUid, authorRole),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blueAccent.shade100,
                              backgroundImage: authorPhotoUrl.isNotEmpty
                                  ? NetworkImage(authorPhotoUrl)
                                  : null,
                              child: authorPhotoUrl.isEmpty
                                  ? Text(
                                authorName.isNotEmpty
                                    ? authorName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(color: Colors.white),
                              )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(authorName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(dateStr,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600])),
                              ],
                            ),
                          ),
                          if (isOwner)
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == "edit") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditPostScreen(
                                        postId: postId,
                                        currentContent: content,
                                      ),
                                    ),
                                  );
                                } else if (value == "delete") {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Delete Post?"),
                                      content: const Text(
                                          "Are you sure you want to delete this post?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text("Delete"),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (ok == true) {
                                    await postService.deletePost(postId: postId);
                                  }
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: "edit", child: Text("Edit")),
                                PopupMenuItem(value: "delete", child: Text("Delete")),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // CONTENT
                      Text(content, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      // IMAGE
                      if (imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(imageUrl),
                        ),
                      const SizedBox(height: 10),
                      // COMMENTS BUTTON
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.comment_outlined),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CommentsScreen(postId: postId),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
