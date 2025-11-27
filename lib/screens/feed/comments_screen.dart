import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import '../../services/post_service.dart';
import 'package:intl/intl.dart';
import '../../service/post_service.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({required this.postId, super.key});

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _controller = TextEditingController();
  final _postService = PostService();
  @override
  Widget build(BuildContext context) {
    final commentsStream = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots();

    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: commentsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('No comments yet'));
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    final content = d['content'] ?? '';
                    final author = d['authorName'] ?? 'Unknown';
                    final ts = d['timestamp'] as Timestamp?;
                    final date = ts != null ? DateFormat('MMM d, h:mm a').format(ts.toDate()) : 'Just now';
                    return ListTile(
                      title: Text(author, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(content),
                      trailing: Text(date, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Write a comment...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;
                    final user = currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in')));
                      return;
                    }
                    // get author name from cached user or fallback
                    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                    final name = (doc.exists && (doc.data() as Map<String, dynamic>?)?['fullName'] != null)
                        ? (doc.data() as Map<String, dynamic>)['fullName']
                        : user.email ?? 'Unknown';

                    await _postService.addComment(
                      postId: widget.postId,
                      authorUid: user.uid,
                      authorName: name,
                      content: text,
                    );
                    _controller.clear();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
