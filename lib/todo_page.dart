import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'timer_service.dart';
import 'models/todo_task.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _addTask(TimerService timerService) {
    if (_taskController.text.isNotEmpty) {
      timerService.addTask(_taskController.text);
      _taskController.clear();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerService = Provider.of<TimerService>(context);
    final theme = timerService.currentTheme;
    final Color textColor = theme.textColor;
    final Color accentColor = theme.accent;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tasks",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, color: accentColor, size: 24),
                  ),
                  onPressed: () => _showAddTaskDialog(context, timerService),
                ),
              ],
            ),
          ),
          Expanded(
            child: timerService.tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.checklist_rounded, size: 80, color: textColor.withOpacity(0.1)),
                        const SizedBox(height: 20),
                        Text(
                          "Your task list is empty.",
                          style: TextStyle(
                            color: textColor.withOpacity(0.6),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Focus on what matters today.",
                          style: TextStyle(
                            color: textColor.withOpacity(0.4),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : (() {
                    final sortedTasks = List<TodoTask>.from(timerService.tasks)
                      ..sort((a, b) {
                        if (a.isCompleted == b.isCompleted) return 0;
                        return a.isCompleted ? 1 : -1;
                      });
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: sortedTasks.length,
                      itemBuilder: (context, index) {
                        final task = sortedTasks[index];
                        return Dismissible(
                          key: Key(task.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => timerService.removeTask(task.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(task.isCompleted ? 0.05 : 0.3),
                              Colors.white.withOpacity(task.isCompleted ? 0.02 : 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withOpacity(task.isCompleted ? 0.05 : 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: GestureDetector(
                              onTap: () => timerService.toggleTask(task.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: task.isCompleted ? accentColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: task.isCompleted ? accentColor : accentColor.withOpacity(0.4),
                                    width: 2.5,
                                  ),
                                  boxShadow: task.isCompleted ? [
                                    BoxShadow(
                                      color: accentColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ] : [],
                                ),
                                child: task.isCompleted
                                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                                    : null,
                              ),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                color: textColor.withOpacity(task.isCompleted ? 0.4 : 1.0),
                                fontSize: 17,
                                fontWeight: task.isCompleted ? FontWeight.normal : FontWeight.w700,
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                letterSpacing: 0.2,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline_rounded, 
                                size: 22, 
                                color: textColor.withOpacity(0.2)
                              ),
                              onPressed: () => timerService.removeTask(task.id),
                            ),
                          ), // ListTile
                        ), // Container
                      ); // Dismissible
                    },
                  ); // ListView.builder
                }()), // IIFE
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, TimerService timerService) {
    final theme = timerService.currentTheme;
    final Color textColor = theme.textColor;
    final Color accentColor = theme.accent;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Glassmorphism for the sheet
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 32,
          right: 32,
          top: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "New Task",
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.w800, 
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _taskController,
              autofocus: true,
              style: TextStyle(color: textColor, fontSize: 18),
              decoration: InputDecoration(
                hintText: "What are you working on?",
                hintStyle: TextStyle(color: textColor.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: accentColor.withOpacity(0.3), width: 2),
                ),
              ),
              onSubmitted: (_) => _addTask(timerService),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () => _addTask(timerService),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: accentColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  "ADD TASK",
                  style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
