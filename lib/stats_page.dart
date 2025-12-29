import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'timer_service.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final timerService = Provider.of<TimerService>(context);
    final theme = timerService.currentTheme;
    
    final Color textColor = theme.textColor;
    final Color accentColor = theme.accent;

    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              "Statistics",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
          TabBar(
            labelColor: textColor,
            unselectedLabelColor: textColor.withOpacity(0.4),
            indicatorColor: accentColor,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Daily'),
              Tab(text: 'Monthly'),
              Tab(text: 'Yearly'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                _buildStatList(timerService.getDailyStats(), textColor, accentColor),
                _buildStatList(timerService.getMonthlyStats(), textColor, accentColor),
                _buildStatList(timerService.getYearlyStats(), textColor, accentColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatList(Map<String, int> stats, Color textColor, Color accentColor) {
    if (stats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 80, color: textColor.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              "No history recorded.",
              style: TextStyle(color: textColor.withOpacity(0.4), fontSize: 16),
            ),
          ],
        ),
      );
    }
    
    // Sort by duration desc
    final sortedEntries = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        final duration = Duration(seconds: entry.value);
        final hours = duration.inHours;
        final minutes = duration.inMinutes.remainder(60);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  entry.key.substring(0, 1).toUpperCase(), 
                  style: TextStyle(
                    color: accentColor, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 20
                  )
                ),
              ),
            ),
            title: Text(
              entry.key, 
              style: TextStyle(
                fontWeight: FontWeight.w700, 
                color: textColor,
                fontSize: 16
              )
            ),
            subtitle: Text(
              "Focus Session",
              style: TextStyle(
                color: textColor.withOpacity(0.5),
                fontSize: 12
              ),
            ),
            trailing: Text(
              "${hours}h ${minutes}m",
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w800, 
                color: textColor
              ),
            ),
          ),
        );
      },
    );
  }
}
