import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/auth_service.dart';
import '../authentication/login_screen.dart';
import 'edit_student_dashboard_screen.dart';
import '../../models/user_data.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  final UserData userData;

  const EditProfileScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

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

  // Halls list
  final List<String> halls = [
    'Al Beruni Hall',
    'Meer Mosharraf Hossain Hall',
    'Shaheed Salam-Barkat Hall',
    'A.F.M. Kamaluddin Hall',
    'Moulana Bhasani Hall',
    'Bangabondhu Sheikh Majibur Rahman Hall',
    'Shaheed Rafiq-Jabbar Hall',
    'Nawab Faizunnesa Hall',
    'Fazilatunnesa Hall',
    'Jahanara Imam Hall',
    'Preetilata Hall',
    'Begum Khaleda Zia Hall',
    'Sheikh Hasina Hall',
  ];

  final List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  final List<String> roles = [
    'Student',
    'Faculty',
    'Staff',
    'Alumni',
    'Guest'
  ];

  final List<String> juDepartments = [
    // Faculty of Mathematical & Physical Sciences
    "Physics",
    "Chemistry",
    "Computer Science and Engineering (CSE)",
    "Environmental Sciences",
    "Geological Sciences",
    "Mathematics",
    "Statistics",

    // Faculty of Social Sciences
    "Anthropology",
    "Economics",
    "Geography and Environment",
    "Government and Politics",
    "Public Administration",
    "Urban and Regional Planning",

    // Faculty of Arts & Humanities
    "Archaeology",
    "Bangla",
    "English",
    "Drama & Dramatics",
    "Fine Arts",
    "History",
    "International Relations",
    "Journalism & Media Studies",
    "Philosophy",

    // Faculty of Biological Sciences
    "Botany",
    "Biochemistry & Molecular Biology",
    "Biotechnology & Genetic Engineering",
    "Microbiology",
    "Pharmacy",
    "Public Health & Informatics",
    "Zoology",

    // Faculty of Business Studies
    "Accounting & Information Systems",
    "Finance & Banking",
    "Marketing",
    "Management Studies",

    // Faculty of Law
    "Law & Justice",

    // Additional / Special Department
    "Remote Sensing & GIS",
    "Other"
  ];

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

  @override
  void dispose() {
    _fullNameController.dispose();
    _roleController.dispose();
    _bloodController.dispose();
    _hallController.dispose();
    _idController.dispose();
    _departmentController.dispose();
    _sessionController.dispose();
    _rollController.dispose();
    _schoolController.dispose();
    _collegeController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _facebookController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(bool isProfilePic) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final file = File(image.path);
      final folder = isProfilePic ? 'profile_pics' : 'cover_pics';
      final fileName = '${widget.userData.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final ref = FirebaseStorage.instance.ref().child(folder).child(fileName);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      final fieldName = isProfilePic ? 'profilePicUrl' : 'coverPicUrl';
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userData.uid)
          .update({fieldName: downloadUrl});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload successful')),
      );
    } catch (e) {
      debugPrint('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
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
      debugPrint('Update error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required TextEditingController controller,
    bool required = false,
    String? hintText,
  }) {
    // Ensure current value is present in list; if not, show it as an extra option
    final current = controller.text;
    final values = List<String>.from(items);
    if (current.isNotEmpty && !values.contains(current)) {
      values.insert(0, current);
    }

    String? selected = controller.text.isNotEmpty ? controller.text : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<String>(
              value: selected,
              decoration: InputDecoration(
                hintText: hintText ?? 'Select $label',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: values.map((v) => DropdownMenuItem(
                value: v,
                child: Text(
                  v,
                  style: TextStyle(
                    color: v == 'Other' ? Colors.blue : Colors.grey[800],
                    fontWeight: v == 'Other' ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              )).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    controller.text = v;
                  });
                }
              },
              validator: required ? (v) => (v == null || v.isEmpty) ? 'Required' : null : null,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              dropdownColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.indigo, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.photo_library, color: Colors.indigo, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Profile Images',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Profile Picture
                Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(widget.userData.profilePicUrl),
                        ),
                        if (_isUploading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : () => _pickAndUploadImage(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Profile',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Cover Photo
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(widget.userData.coverPicUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isUploading ? null : () => _pickAndUploadImage(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.grey[800],
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Cover Photo',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextInputField(
              controller: _fullNameController,
              label: 'Full Name',
              required: true,
            ),
            _buildDropdownField(
              label: 'Role',
              items: roles,
              controller: _roleController,
              required: true,
            ),
            _buildDropdownField(
              label: 'Blood Group',
              items: bloodGroups,
              controller: _bloodController,
            ),
            _buildDropdownField(
              label: 'Hall / Residence',
              items: halls,
              controller: _hallController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationalInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.school_outlined, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Educational Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Department',
              items: juDepartments,
              controller: _departmentController,
            ),
            _buildTextInputField(
              controller: _idController,
              label: 'Student/Faculty ID',
            ),
            _buildTextInputField(
              controller: _sessionController,
              label: 'Session',
              hintText: 'e.g., 2020-21',
            ),
            _buildTextInputField(
              controller: _rollController,
              label: 'Roll No',
              keyboardType: TextInputType.number,
            ),
            _buildTextInputField(
              controller: _schoolController,
              label: 'Previous School',
              maxLines: 2,
            ),
            _buildTextInputField(
              controller: _collegeController,
              label: 'Previous College',
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.contacts_outlined, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextInputField(
              controller: _phoneController,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
            ),
            _buildTextInputField(
              controller: _whatsappController,
              label: 'WhatsApp',
              keyboardType: TextInputType.phone,
            ),
            _buildTextInputField(
              controller: _facebookController,
              label: 'Facebook ID',
              hintText: 'Username or profile URL',
            ),
            _buildTextInputField(
              controller: _instagramController,
              label: 'Instagram',
              hintText: '@username',
            ),
            _buildTextInputField(
              controller: _addressController,
              label: 'Address',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _updateProfile,
            tooltip: 'Save Changes',
          ),
        ],
      ),
      body: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImageUploadSection(),
              const SizedBox(height: 16),
              _buildPersonalInfoSection(),
              const SizedBox(height: 16),
              _buildEducationalInfoSection(),
              const SizedBox(height: 16),
              _buildContactInfoSection(),
              const SizedBox(height: 24),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}