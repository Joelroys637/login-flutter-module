import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/role_provider.dart';
import '../../models/role_model.dart';
import '../../core/constants.dart';

class AddEditRoleScreen extends StatefulWidget {
  final RoleModel? role;
  const AddEditRoleScreen({Key? key, this.role}) : super(key: key);

  @override
  State<AddEditRoleScreen> createState() => _AddEditRoleScreenState();
}

class _AddEditRoleScreenState extends State<AddEditRoleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late bool _isActive;
  late Map<String, ModulePermissions> _permissions;

  final List<String> _modules = ['Dashboard', 'User', 'Role & Permissions'];

  @override
  void initState() {
    super.initState();
    final role = widget.role ?? RoleModel.empty();
    _nameController = TextEditingController(text: role.name);
    _descController = TextEditingController(text: role.description);
    _isActive = role.isActive;
    _permissions = {
      for (var m in _modules) m: ModulePermissions(
        read: role.permissions[m]?.read ?? false,
        write: role.permissions[m]?.write ?? false,
        update: role.permissions[m]?.update ?? false,
        delete: role.permissions[m]?.delete ?? false,
      )
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(widget.role == null ? 'Add New Role' : 'Edit Role', style: const TextStyle(color: Color(0xFF1A1C1E))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1C1E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFields(),
              const SizedBox(height: 30),
              const Text('Permission Control Table', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
              const SizedBox(height: 15),
              _buildPermissionTable(),
              const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFields() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: Color(0xFF1A1C1E)),
            decoration: const InputDecoration(labelText: 'Role Name', border: OutlineInputBorder()),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _descController,
            style: const TextStyle(color: Color(0xFF1A1C1E)),
            decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<bool>(
            value: _isActive,
            style: const TextStyle(color: Color(0xFF1A1C1E)),
            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: true, child: Text('Active')),
              DropdownMenuItem(value: false, child: Text('Inactive')),
            ],
            onChanged: (v) => setState(() => _isActive = v!),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTable() {
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E));
    const cellStyle = TextStyle(color: Color(0xFF1A1C1E));

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: headerStyle,
          dataTextStyle: cellStyle,
          columns: const [
            DataColumn(label: Text('Modules')),
            DataColumn(label: Text('Read')),
            DataColumn(label: Text('Write')),
            DataColumn(label: Text('Update')),
            DataColumn(label: Text('Delete')),
            DataColumn(label: Text('Select All')),
          ],
          rows: _modules.map((m) {
            final p = _permissions[m]!;
            return DataRow(cells: [
              DataCell(Text(m)),
              DataCell(Checkbox(value: p.read, activeColor: AppColors.primaryColor, onChanged: (v) => setState(() => p.read = v!))),
              DataCell(Checkbox(value: p.write, activeColor: AppColors.primaryColor, onChanged: (v) => setState(() => p.write = v!))),
              DataCell(Checkbox(value: p.update, activeColor: AppColors.primaryColor, onChanged: (v) => setState(() => p.update = v!))),
              DataCell(Checkbox(value: p.delete, activeColor: AppColors.primaryColor, onChanged: (v) => setState(() => p.delete = v!))),
              DataCell(Checkbox(
                value: p.read && p.write && p.update && p.delete,
                activeColor: AppColors.primaryColor,
                onChanged: (v) => setState(() {
                  p.read = v!; p.write = v; p.update = v; p.delete = v;
                }),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final isLoading = context.watch<RoleProvider>().isLoading;

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Save Role Settings', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final role = RoleModel(
        id: widget.role?.id,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        isActive: _isActive,
        permissions: _permissions,
      );

      final provider = context.read<RoleProvider>();
      bool success;
      if (widget.role == null) {
        success = await provider.addRole(role);
      } else {
        success = await provider.updateRole(role);
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Role settings saved successfully')));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save role settings. Please check your connection.')));
        }
      }
    }
  }
}
