import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// CREATE NEW POST
  Future<void> createPost({
    required String content,
    required String authorUid,
    required String authorName,
    String authorEmail = "",
    String authorRole = "Student",
  }) async {
    final postRef = _firestore.collection('posts').doc();

    await postRef.set({
      'authorUid': authorUid,
      'authorName': authorName,
      'authorEmail': authorEmail,
      'authorRole': authorRole,
      'content': content,
      'likedBy': [], // empty list initially
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
    final commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc();

    await commentRef.set({
      'authorUid': authorUid,
      'authorName': authorName,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// DELETE POST
  Future<void> deletePost({required String postId}) async {
    final postRef = _firestore.collection('posts').doc(postId);

    // Delete all comments first
    final commentsSnapshot = await postRef.collection('comments').get();
    for (var doc in commentsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Then delete the post
    await postRef.delete();
  }

  /// OPTIONAL: EDIT POST CONTENT
  Future<void> editPost({
    required String postId,
    required String newContent,
  }) async {
    final postRef = _firestore.collection('posts').doc(postId);
    await postRef.update({
      'content': newContent,
      'timestamp': FieldValue.serverTimestamp(), // update timestamp
    });
  }
}
