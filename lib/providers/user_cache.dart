import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data.dart';

/// PROVIDER (FAMILY)
final userDataProvider = AsyncNotifierProviderFamily<UserCacheNotifier, UserData?, String>(
  UserCacheNotifier.new,
);

/// NOTIFIER
class UserCacheNotifier extends FamilyAsyncNotifier<UserData?, String> {

  @override
  Future<UserData?> build(String uid) async {
    final actualUid = uid.isNotEmpty ? uid : FirebaseAuth.instance.currentUser?.uid;
    if (actualUid == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(actualUid)
        .get();

    if (!doc.exists) return null;

    return UserData.fromFirestore(doc);
  }

  /// MANUAL REFRESH
  Future<void> refreshFor(String uid) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(uid));
  }
}
