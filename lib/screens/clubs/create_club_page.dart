import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/club_model.dart';
// import '../../services/club_service.dart';
import '../../service/club_service.dart';

class CreateClubPage extends StatefulWidget {
  const CreateClubPage({super.key});

  @override
  State<CreateClubPage> createState() => _CreateClubPageState();
}

class _CreateClubPageState extends State<CreateClubPage> {
  final _formKey = GlobalKey<FormState>();
  final ClubService clubService = ClubService();

  // Text controllers
  final nameController = TextEditingController();
  final motoController = TextEditingController();
  final descriptionController = TextEditingController();
  final missionController = TextEditingController();
  final visionController = TextEditingController();
  final whoCanJoinController = TextEditingController();
  final membershipCriteriaController = TextEditingController();
  final rulesController = TextEditingController();
  final electionController = TextEditingController();
  final meetingController = TextEditingController();

  String clubType = "Academic";

  File? logoFile;
  File? bannerFile;

  Future<String> uploadImage(File file, String folder) async {
    String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";

    Reference ref = FirebaseStorage.instance.ref().child("$folder/$fileName");
    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    String id = FirebaseFirestore.instance.collection('clubs').doc().id;

    String logoUrl = '';
    String bannerUrl = '';

    // Upload logo if selected
    if (logoFile != null) {
      logoUrl = await uploadImage(logoFile!, "club_logos");
    } else {
      logoUrl = "https://via.placeholder.com/150";
    }

    // Upload banner if selected
    if (bannerFile != null) {
      bannerUrl = await uploadImage(bannerFile!, "club_banners");
    } else {
      bannerUrl = "https://i.imgur.com/LxWkZp0.png"; // default banner
    }

    Club club = Club(
      id: id,
      name: nameController.text.trim(),
      moto: motoController.text.trim(),
      type: clubType,
      logoUrl: logoUrl,
      bannerUrl: bannerUrl,
      description: descriptionController.text.trim(),
      mission: missionController.text.trim(),
      vision: visionController.text.trim(),
      whoCanJoin: whoCanJoinController.text.trim(),
      membershipCriteria: membershipCriteriaController.text.trim(),
      rulesAndRegulations: rulesController.text.trim(),
      electionProcess: electionController.text.trim(),
      meetingRules: meetingController.text.trim(),
      isMember: false,
      memberCount: 0,
    );

    await clubService.createClub(club);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Club created successfully!")),
    );

    Navigator.pop(context);
  }

  Widget imagePickerBox({
    required String label,
    required File? imageFile,
    required VoidCallback onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPick,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: imageFile == null
                ? const Center(child: Icon(Icons.add_a_photo, size: 40))
                : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(imageFile, fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Club"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Club Name"),
                validator: (v) => v!.isEmpty ? "Enter club name" : null,
              ),

              // Moto
              TextFormField(
                controller: motoController,
                decoration: const InputDecoration(labelText: "Club Moto"),
              ),

              const SizedBox(height: 16),

              // Type dropdown
              DropdownButtonFormField(
                value: clubType,
                items: const [
                  DropdownMenuItem(value: "Academic", child: Text("Academic")),
                  DropdownMenuItem(value: "Cultural", child: Text("Cultural")),
                  DropdownMenuItem(value: "Sports", child: Text("Sports")),
                  DropdownMenuItem(value: "Tech", child: Text("Tech")),
                  DropdownMenuItem(value: "Social", child: Text("Social")),
                ],
                onChanged: (v) => setState(() => clubType = v.toString()),
                decoration: const InputDecoration(labelText: "Club Type"),
              ),

              const SizedBox(height: 20),

              // Logo Picker
              imagePickerBox(
                label: "Club Logo",
                imageFile: logoFile,
                onPick: () async {
                  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (picked != null) setState(() => logoFile = File(picked.path));
                },
              ),

              const SizedBox(height: 20),

              // Banner Picker
              imagePickerBox(
                label: "Club Banner",
                imageFile: bannerFile,
                onPick: () async {
                  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (picked != null) setState(() => bannerFile = File(picked.path));
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: "Short Description"),
              ),

              TextFormField(
                controller: missionController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: "Mission"),
              ),

              TextFormField(
                controller: visionController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: "Vision"),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              TextFormField(
                controller: whoCanJoinController,
                decoration: const InputDecoration(labelText: "Who Can Join"),
              ),

              TextFormField(
                controller: membershipCriteriaController,
                decoration: const InputDecoration(labelText: "Membership Criteria"),
              ),

              TextFormField(
                controller: rulesController,
                decoration: const InputDecoration(labelText: "Rules & Regulations"),
              ),

              TextFormField(
                controller: electionController,
                decoration: const InputDecoration(labelText: "Election Process"),
              ),

              TextFormField(
                controller: meetingController,
                decoration: const InputDecoration(labelText: "Meeting Rules"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submit,
                child: const Text("Create Club"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
