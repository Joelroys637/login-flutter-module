import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants.dart';
import '../../models/user_model.dart';
import '../../models/role_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/role_provider.dart';

class RegistrationScreen extends StatefulWidget {
  final UserModel? user;
  const RegistrationScreen({Key? key, this.user}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _ageController;
  late TextEditingController _addressController;
  String? _selectedRole;
  XFile? _imageFile;
  Uint8List? _imageBytes;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name);
    _passwordController = TextEditingController(text: widget.user?.password);
    _ageController = TextEditingController(text: widget.user?.age.toString());
    _addressController = TextEditingController(text: widget.user?.address);
    _selectedRole = widget.user?.role;
    if (widget.user?.photoUrl.isNotEmpty ?? false) {
      _imageBytes = base64Decode(widget.user!.photoUrl);
    }
  }

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
      if (_imageBytes == null && _imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a photo')));
        return;
      }

      final user = UserModel(
        id: widget.user?.id,
        name: _nameController.text.trim(),
        password: _passwordController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        address: _addressController.text.trim(),
        photoUrl: widget.user?.photoUrl ?? '',
        role: _selectedRole!,
        createdAt: widget.user?.createdAt ?? DateTime.now(),
      );

      final provider = context.read<UserProvider>();
      bool success;
      if (widget.user == null) {
        success = await provider.registerUser(user, _imageFile);
      } else {
        success = await provider.updateUser(widget.user!.id!, user, _imageFile);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.user == null ? 'User Registered' : 'User Updated')));
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Operation failed')));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<UserProvider>().isLoading;
    final roles = context.watch<RoleProvider>().roles;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(widget.user == null ? 'Register User' : 'Edit User', style: const TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1C1E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                      child: _imageBytes == null ? const Icon(Icons.add_a_photo, size: 40, color: AppColors.primaryColor) : null,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(_nameController, 'Full Name', Icons.person_outline),
                  _buildTextField(_passwordController, 'Password', Icons.lock_outline, isPassword: true),
                  _buildTextField(_ageController, 'Age', Icons.cake_outlined, type: TextInputType.number),
                  _buildTextField(_addressController, 'Address', Icons.location_on_outlined, maxLines: 2),
                  _buildRoleDropdown(roles),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(widget.user == null ? 'Submit' : 'Update User', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text, bool isPassword = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        obscureText: isPassword,
        maxLines: isPassword ? 1 : maxLines,
        style: const TextStyle(color: Color(0xFF1A1C1E)),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primaryColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (v) => v == null || v.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildRoleDropdown(List<RoleModel> roles) {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Role',
        prefixIcon: const Icon(Icons.work_outline, color: AppColors.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: roles.map((r) => DropdownMenuItem<String>(value: r.name, child: Text(r.name))).toList(),
      onChanged: (v) => setState(() => _selectedRole = v),
      validator: (v) => v == null ? 'Please select a role' : null,
    );
  }
}
