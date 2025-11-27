import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import '../services/post_service.dart';
import '../../service/post_service.dart';

class EditPostScreen extends StatefulWidget {
  final String postId;
  final String currentContent;
  const EditPostScreen({required this.postId, required this.currentContent, super.key});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _ctr;
  final _service = PostService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ctr = TextEditingController(text: widget.currentContent);
  }

  Future<void> _save() async {
    final newContent = _ctr.text.trim();
    if (newContent.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await _service.editPost(postId: widget.postId, newContent: newContent);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _ctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _ctr,
              maxLines: 8,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            _isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _save, child: const Text('Save'))
          ],
        ),
      ),
    );
  }
}
