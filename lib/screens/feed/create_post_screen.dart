import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../service/post_service.dart';
import '../../providers/user_cache.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _contentController = TextEditingController();
  bool _isLoading = false;

  final _postService = PostService();

  Future<void> _submitPost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final userData = await ref.read(userDataProvider(user.uid).future);

      final authorName =
      userData?.fullName?.isNotEmpty == true ? userData!.fullName : "Unknown User";

      final authorRole =
      userData?.role?.isNotEmpty == true ? userData!.role : "Student";

      await _postService.createPost(
        content: content,
        authorUid: user.uid,
        authorEmail: user.email ?? "",
        authorName: authorName,
        // authorRole: authorRole, // Uncomment if PostService needs role
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Post")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "What is happening on campus?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
              onPressed: _submitPost,
              icon: const Icon(Icons.send),
              label: const Text("Post"),
            ),
          ],
        ),
      ),
    );
  }
}
