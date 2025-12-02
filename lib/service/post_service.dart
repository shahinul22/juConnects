import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String imgbbApiKey = "YOUR_IMGBB_API_KEY"; // Replace with your key

  /// UPLOAD IMAGE TO IMGBB
  Future<String?> uploadPostImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final url = Uri.parse("https://api.imgbb.com/1/upload?key=$imgbbApiKey");

      final response = await http.post(url, body: {
        "image": base64Image,
      });

      final data = jsonDecode(response.body);
      if (data["success"] == true) {
        return data["data"]["url"];
      } else {
        print("IMGBB upload failed: ${data.toString()}");
        return null;
      }
    } catch (e) {
      print("IMGBB error: $e");
      return null;
    }
  }

  /// CREATE NEW POST (with optional ImgBB image)
  Future<void> createPost({
    required String content,
    required String authorUid,
    required String authorName,
    required String authorEmail,
    String authorRole = "Student",
    String? imageUrl,
  }) async {
    final postRef = _firestore.collection('posts').doc();

    await postRef.set({
      'authorUid': authorUid,
      'authorName': authorName.isNotEmpty ? authorName : "Unknown",
      'authorEmail': authorEmail.isNotEmpty ? authorEmail : "unknown@example.com",
      'authorRole': authorRole,
      'content': content,
      'imageUrl': imageUrl ?? null,
      'likedBy': [],
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// TOGGLE LIKE
  Future<void> toggleLike({
    required String postId,
    required String userUid,
  }) async {
    final postRef = _firestore.collection('posts').doc(postId);
    await _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(postRef);
      if (!snapshot.exists) return;

      final likedBy = List<String>.from(snapshot.get('likedBy') ?? []);
      if (likedBy.contains(userUid)) {
        likedBy.remove(userUid);
      } else {
        likedBy.add(userUid);
      }
      tx.update(postRef, {'likedBy': likedBy});
    });
  }

  /// ADD COMMENT
  Future<void> addComment({
    required String postId,
    required String authorUid,
    required String authorName,
    required String content,
  }) async {
    final commentRef =
    _firestore.collection('posts').doc(postId).collection('comments').doc();

    await commentRef.set({
      'authorUid': authorUid,
      'authorName': authorName.isNotEmpty ? authorName : "Unknown",
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// DELETE POST
  Future<void> deletePost({required String postId}) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final commentsSnapshot = await postRef.collection('comments').get();
    for (var doc in commentsSnapshot.docs) {
      await doc.reference.delete();
    }
    await postRef.delete();
  }

  /// EDIT POST CONTENT (with optional image update)
  Future<void> editPost({
    required String postId,
    required String newContent,
    String? newImageUrl,
  }) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final data = {
      'content': newContent,
      'timestamp': FieldValue.serverTimestamp(),
    };
    if (newImageUrl != null) data['imageUrl'] = newImageUrl;

    await postRef.update(data);
  }
}
