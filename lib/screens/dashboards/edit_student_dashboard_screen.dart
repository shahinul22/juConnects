// FULL WORKING EditProfileScreen using IMGBB instead of Firebase Storage
// Requirements:
// 1. Add dependency:  http: ^1.2.1
// 2. Create free imgbb account → get API key
// 3. Replace YOUR_IMGBB_API_KEY with your key

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_data.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditProfileScreen extends StatefulWidget {
  final UserData userData;

  const EditProfileScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // --- Controllers ---
  late TextEditingController _fullNameController;
  late TextEditingController _roleController;
  late TextEditingController _bloodController;
  late TextEditingController _hallController;
  late TextEditingController _idController;
  late TextEditingController _departmentController;
  late TextEditingController _sessionController;
  late TextEditingController _rollController;
  late TextEditingController _schoolController;
  late TextEditingController _collegeController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _facebookController;
  late TextEditingController _whatsappController;
  late TextEditingController _instagramController;

  bool _isUploading = false;
  bool _isSaving = false;

  final String imgbbApiKey = "2db265648cacb08a42651a80c762436e";

  @override
  void initState() {
    super.initState();

    _fullNameController = TextEditingController(text: widget.userData.fullName);
    _roleController = TextEditingController(text: widget.userData.role);
    _bloodController = TextEditingController(text: widget.userData.bloodGroup);
    _hallController = TextEditingController(text: widget.userData.hall);
    _idController = TextEditingController(text: widget.userData.idNumber);
    _departmentController = TextEditingController(text: widget.userData.department);
    _sessionController = TextEditingController(text: widget.userData.session);
    _rollController = TextEditingController(text: widget.userData.roll);
    _schoolController = TextEditingController(text: widget.userData.school);
    _collegeController = TextEditingController(text: widget.userData.college);
    _addressController = TextEditingController(text: widget.userData.address);
    _phoneController = TextEditingController(text: widget.userData.phoneNumber);
    _facebookController = TextEditingController(text: widget.userData.facebookId);
    _whatsappController = TextEditingController(text: widget.userData.whatsapp);
    _instagramController = TextEditingController(text: widget.userData.instagram);
  }

  Future<String?> uploadToImgbb(File imageFile) async {
    try {
      setState(() => _isUploading = true);

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final url = Uri.parse("https://api.imgbb.com/1/upload?key=$imgbbApiKey");

      final response = await http.post(url, body: {
        "image": base64Image,
      });

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        return data["data"]["url"];
      } else {
        debugPrint("IMGBB upload failed: ${data.toString()}");
        return null;
      }
    } catch (e) {
      debugPrint("IMGBB error: $e");
      return null;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> pickImage(bool isProfile) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    final imageUrl = await uploadToImgbb(file);

    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload image")),
      );
      return;
    }

    final fieldName = isProfile ? "profilePicUrl" : "coverPicUrl";

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userData.uid)
        .update({fieldName: imageUrl});

    setState(() {
      if (isProfile) {
        widget.userData.profilePicUrl = imageUrl;
      } else {
        widget.userData.coverPicUrl = imageUrl;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Image updated successfully!")),
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final Map<String, dynamic> data = {
        'fullName': _fullNameController.text.trim(),
        'role': _roleController.text.trim(),
        'bloodGroup': _bloodController.text.trim(),
        'hall': _hallController.text.trim(),
        'idNumber': _idController.text.trim(),
        'department': _departmentController.text.trim(),
        'session': _sessionController.text.trim(),
        'roll': _rollController.text.trim(),
        'school': _schoolController.text.trim(),
        'college': _collegeController.text.trim(),
        'address': _addressController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'facebookId': _facebookController.text.trim(),
        'whatsapp': _whatsappController.text.trim(),
        'instagram': _instagramController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userData.uid)
          .update(data);

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _updateProfile,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Profile & Cover ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: NetworkImage(widget.userData.profilePicUrl),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => pickImage(true),
                      child: const Text("Change Profile Photo"),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(widget.userData.coverPicUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => pickImage(false),
                      child: const Text("Change Cover Photo"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- Name ---
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isSaving ? null : _updateProfile,
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Changes"),
            )
          ],
        ),
      ),
    );
  }
}