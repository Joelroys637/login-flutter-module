import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../core/constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _filterRole = 'All';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: context.read<UserProvider>().getUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allUsers = snapshot.data ?? [];
        final filteredUsers = _filterRole == 'All' 
            ? allUsers 
            : allUsers.where((u) => u.role == _filterRole).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildFilters(allUsers),
              const SizedBox(height: 20),
              _buildStatsCards(filteredUsers),
              const SizedBox(height: 30),
              _buildCharts(filteredUsers),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Analytics Dashboard',
      style: TextStyle(
        color: Color(0xFF1A1C1E),
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFilters(List<UserModel> allUsers) {
    final roles = ['All', ...allUsers.map((u) => u.role).toSet().toList()];
    
    return Row(
      children: [
        const Text('Filter by Role: ', style: TextStyle(color: Colors.black54)),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _filterRole,
              items: roles.map((r) => DropdownMenuItem<String>(value: r, child: Text(r))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _filterRole = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(List<UserModel> users) {
    return Row(
      children: [
        Expanded(
          child: _statCard('Total Users', users.length.toString(), Icons.people, Colors.blue),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _statCard('Avg. Age', _calculateAvgAge(users), Icons.cake, Colors.orange),
        ),
      ],
    );
  }

  String _calculateAvgAge(List<UserModel> users) {
    if (users.isEmpty) return '0';
    final sum = users.fold<int>(0, (prev, u) => prev + u.age);
    return (sum / users.length).toStringAsFixed(1);
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 15),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
          Text(title, style: const TextStyle(color: Colors.black45, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCharts(List<UserModel> users) {
    return Column(
      children: [
        _chartContainer('User Distribution by Role (Pie Chart)', _buildPieChart(users)),
        const SizedBox(height: 20),
        _chartContainer('Age Distribution (Bar Chart)', _buildBarChart(users)),
        const SizedBox(height: 20),
        _chartContainer('Registration Trend (Line Chart)', _buildLineChart(users)),
      ],
    );
  }

  Widget _chartContainer(String title, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
          const SizedBox(height: 20),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildPieChart(List<UserModel> users) {
    final roleCounts = <String, int>{};
    for (var u in users) {
      roleCounts[u.role] = (roleCounts[u.role] ?? 0) + 1;
    }

    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];
    int colorIdx = 0;

    return PieChart(
      PieChartData(
        sections: roleCounts.entries.map((e) {
          final color = colors[colorIdx % colors.length];
          colorIdx++;
          return PieChartSectionData(
            value: e.value.toDouble(),
            title: '${e.key}\n${e.value}',
            color: color,
            radius: 50,
            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBarChart(List<UserModel> users) {
    final ageGroups = <String, int>{'0-20': 0, '21-40': 0, '41-60': 0, '60+': 0};
    for (var u in users) {
      if (u.age <= 20) ageGroups['0-20'] = ageGroups['0-20']! + 1;
      else if (u.age <= 40) ageGroups['21-40'] = ageGroups['21-40']! + 1;
      else if (u.age <= 60) ageGroups['41-60'] = ageGroups['41-60']! + 1;
      else ageGroups['60+'] = ageGroups['60+']! + 1;
    }

    return BarChart(
      BarChartData(
        barGroups: ageGroups.entries.indexed.map((e) {
          return BarChartGroupData(
            x: e.$1,
            barRods: [BarChartRodData(toY: e.$2.value.toDouble(), color: AppColors.primaryColor, width: 20)],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(ageGroups.keys.elementAt(value.toInt()), style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }

  Widget _buildLineChart(List<UserModel> users) {
    // Group by day for the last 7 days
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    
    final data = last7Days.map((date) {
      final count = users.where((u) => 
        u.createdAt.year == date.year && 
        u.createdAt.month == date.month && 
        u.createdAt.day == date.day
      ).length;
      return count.toDouble();
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.indexed.map((e) => FlSpot(e.$1.toDouble(), e.$2)).toList(),
            isCurved: true,
            color: AppColors.primaryColor,
            barWidth: 4,
            belowBarData: BarAreaData(show: true, color: AppColors.primaryColor.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }
}
