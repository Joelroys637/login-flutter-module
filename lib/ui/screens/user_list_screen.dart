import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../core/constants.dart';
import 'registration_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canRead = auth.hasPermission('User', 'read');
    final canWrite = auth.hasPermission('User', 'write');
    final canUpdate = auth.hasPermission('User', 'update');
    final canDelete = auth.hasPermission('User', 'delete');

    if (!canRead) {
      return const Center(child: Text('You do not have permission to view users.'));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: context.read<UserProvider>().getUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data ?? [];
                if (users.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                return _isGridView ? _buildGrid(users, canUpdate, canDelete) : _buildList(users, canUpdate, canDelete);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: canWrite ? FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrationScreen())),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('All Registered Users', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view, color: AppColors.primaryColor),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<UserModel> users, bool canUpdate, bool canDelete) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) => _userCard(users[index], canUpdate, canDelete),
    );
  }

  Widget _buildList(List<UserModel> users, bool canUpdate, bool canDelete) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: users.length,
      itemBuilder: (context, index) => _userListItem(users[index], canUpdate, canDelete),
    );
  }

  Widget _userCard(UserModel user, bool canUpdate, bool canDelete) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: user.photoUrl.isNotEmpty
                  ? Image.memory(base64Decode(user.photoUrl), fit: BoxFit.cover, width: double.infinity)
                  : Container(color: Colors.grey[200], child: const Icon(Icons.person, size: 50, color: Colors.grey)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                Text(user.role, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text('Age: ${user.age}', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (canUpdate) IconButton(
                      icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationScreen(user: user))),
                    ),
                    if (canDelete) IconButton(
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      onPressed: () => _confirmDelete(user),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _userListItem(UserModel user, bool canUpdate, bool canDelete) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: user.photoUrl.isNotEmpty ? MemoryImage(base64Decode(user.photoUrl)) : null,
            child: user.photoUrl.isEmpty ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${user.role} • ${user.age} years old', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          if (canUpdate) IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationScreen(user: user))),
          ),
          if (canDelete) IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(user),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<UserProvider>().deleteUser(user.id!);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
