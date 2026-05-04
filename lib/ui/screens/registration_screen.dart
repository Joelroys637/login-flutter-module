import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants.dart';
import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import '../widgets/glass_container.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _previousClassController = TextEditingController();
  final _mobileController = TextEditingController();
  bool _passedPreviousClass = false;
  XFile? _imageFile;
  Uint8List? _imageBytes;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageFile = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a photo')));
        return;
      }

      final student = Student(
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        address: _addressController.text.trim(),
        previousClass: _previousClassController.text.trim(),
        passedPreviousClass: _passedPreviousClass,
        mobile: _mobileController.text.trim(),
        photoUrl: '', // Handled in Provider
        createdAt: DateTime.now(),
      );

      final success = await context.read<StudentProvider>().registerStudent(student, _imageFile);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student Registered successfully')));
        // Clear form
        _nameController.clear();
        _ageController.clear();
        _addressController.clear();
        _previousClassController.clear();
        _mobileController.clear();
        setState(() {
          _imageFile = null;
          _imageBytes = null;
          _passedPreviousClass = false;
        });
      } else if (mounted) {
        final error = context.read<StudentProvider>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Failed to register student')));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _previousClassController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType type = TextInputType.text, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator ?? (value) => value == null || value.trim().isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<StudentProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E2C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                        child: _imageBytes == null
                            ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white70)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Register New Student', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    _buildTextField(_nameController, 'Name', validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please enter Name';
                      if (RegExp(r'[0-9]').hasMatch(val)) return 'Name cannot contain numbers';
                      return null;
                    }),
                    _buildTextField(_ageController, 'Age', type: TextInputType.number, validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please enter Age';
                      final age = int.tryParse(val.trim());
                      if (age == null) return 'Enter a valid number';
                      if (age > 150) return 'Age cannot be greater than 150';
                      if (age <= 0) return 'Age must be greater than 0';
                      return null;
                    }),
                    _buildTextField(_addressController, 'Address'),
                    _buildTextField(_previousClassController, 'Previous Class'),
                    _buildTextField(_mobileController, 'Mobile', type: TextInputType.phone, validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please enter Mobile';
                      if (val.trim().length != 10) return 'Mobile must be 10 digits';
                      if (int.tryParse(val.trim()) == null) return 'Enter a valid mobile number';
                      return null;
                    }),
                    SwitchListTile(
                      title: const Text('Passed Previous Class?', style: TextStyle(color: Colors.white)),
                      value: _passedPreviousClass,
                      activeColor: AppColors.accentColor,
                      onChanged: (val) {
                        setState(() {
                          _passedPreviousClass = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Submit', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
