import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../service/post_service.dart';
import '../../providers/user_cache.dart';

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
      Navigator.push(context,
        MaterialPageRoute(builder: (_) => StudentDashboardScreen(userId: uid)),
      );
    } else if (role == "Faculty") {
      Navigator.push(context,
        MaterialPageRoute(builder: (_) => FacultyDashboardScreen(userId: uid)),
      );
    } else if (role == "Staff") {
      Navigator.push(context,
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
        title: const Text('Campus Feed'),
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

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No posts yet. Be the first!"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, idx) {
              final postDoc = docs[idx];
              final data = postDoc.data() as Map<String, dynamic>;

              final authorName = data['authorName'] ?? 'Unknown User';
              final authorRole = data['authorRole'] ?? 'Student';
              final content = data['content'] ?? '';
              final likedBy = List<String>.from(data['likedBy'] ?? []);
              final likeCount = likedBy.length;
              final postId = postDoc.id;
              final timestamp = data['timestamp'] as Timestamp?;
              final isLiked =
                  currentUser != null && likedBy.contains(currentUser.uid);
              final isOwner =
                  currentUser != null && data['authorUid'] == currentUser.uid;

              final dateStr = timestamp != null
                  ? DateFormat('MMM d, h:mm a').format(timestamp.toDate())
                  : 'Just now';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _openUserProfile(
                                context,
                                data['authorUid'],
                                authorRole,
                              );
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.blueAccent.shade100,
                              child: Text(
                                authorName.isNotEmpty
                                    ? authorName[0].toUpperCase()
                                    : 'U',
                              ),
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
                                        fontSize: 12,
                                        color: Colors.grey[600])),
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
                                    await postService.deletePost(
                                        postId: postId);
                                  }
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                    value: "edit", child: Text("Edit")),
                                PopupMenuItem(
                                    value: "delete", child: Text("Delete")),
                              ],
                            ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      // CONTENT
                      Text(content, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),

                      // ACTIONS
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(isLiked
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined),
                            onPressed: () async {
                              if (currentUser == null) return;
                              await postService.toggleLike(
                                postId: postId,
                                userUid: currentUser.uid,
                              );
                            },
                          ),
                          Text("$likeCount"),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: const Icon(Icons.comment_outlined),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CommentsScreen(postId: postId),
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
