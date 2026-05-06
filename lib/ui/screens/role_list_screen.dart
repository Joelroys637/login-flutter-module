import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/role_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/role_model.dart';
import '../../core/constants.dart';
import 'add_edit_role_screen.dart';

class RoleListScreen extends StatelessWidget {
  const RoleListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canRead = auth.hasPermission('Role & Permissions', 'read');
    final canWrite = auth.hasPermission('Role & Permissions', 'write');
    final canUpdate = auth.hasPermission('Role & Permissions', 'update');
    final canDelete = auth.hasPermission('Role & Permissions', 'delete');

    if (!canRead) {
      return const Center(child: Text('You do not have permission to view roles.'));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(context, canWrite),
          Expanded(
            child: Consumer<RoleProvider>(
              builder: (context, provider, child) {
                final roles = provider.roles;
                if (roles.isEmpty) {
                  return const Center(child: Text('No roles found.'));
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                      ),
                      child: DataTable(
                        columnSpacing: 30,
                        headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
                        dataTextStyle: const TextStyle(color: Color(0xFF1A1C1E)),
                        columns: const [
                          DataColumn(label: Text('Role Name')),
                          DataColumn(label: Text('Description')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: roles.map((role) {
                          return DataRow(cells: [
                            DataCell(Text(role.name)),
                            DataCell(Text(role.description, maxLines: 1, overflow: TextOverflow.ellipsis)),
                            DataCell(_buildStatusChip(role.isActive)),
                            DataCell(Row(
                              children: [
                                if (canUpdate) IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditRoleScreen(role: role))),
                                ),
                                if (canDelete) IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () => _confirmDelete(context, role),
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool canWrite) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Roles & Permissions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
          if (canWrite) ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditRoleScreen())),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Role', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(color: isActive ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _confirmDelete(BuildContext context, RoleModel role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text('Are you sure you want to delete ${role.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<RoleProvider>().deleteRole(role.id!);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
