import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// ------------------------ Upload image to ImgBB ------------------------
  Future<String?> _uploadImageToImgBB(File file) async {
    const apiKey = "2db265648cacb08a42651a80c762436e";

    final url = Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey");

    final request = http.MultipartRequest("POST", url)
      ..files.add(await http.MultipartFile.fromPath("image", file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseData);

      return jsonData["data"]["url"];
    } else {
      print("Image upload failed: ${response.statusCode}");
      return null;
    }
  }

  /// ------------------------ Submit Post ------------------------
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

      // Upload image (if selected)
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImageToImgBB(_selectedImage!);
      }

      await _postService.createPost(
        content: content,
        authorUid: user.uid,
        authorEmail: user.email ?? "",
        authorName: authorName,
        imageUrl: imageUrl, // <-- Pass image URL to Firestore
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
      body: SingleChildScrollView(
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

            // Preview selected image
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedImage!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Add Image"),
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
