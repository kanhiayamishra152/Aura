import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/task_provider.dart';
import '../widgets/task_list_item.dart';
import '../widgets/premium_empty_state.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              color: Color(0xFF121212),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
              border: Border(
                top: BorderSide(color: Color(0xFF333333), width: 1.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                const Text(
                  'New Focus Task',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _taskController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                  cursorColor: const Color(0xFF39FF14),
                  decoration: InputDecoration(
                    hintText: 'What needs your attention?',
                    hintStyle: const TextStyle(color: Color(0xFF555555)),
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: const BorderSide(color: Color(0xFF39FF14), width: 1.0),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                GestureDetector(
                  onTap: () {
                    if (_taskController.text.trim().isNotEmpty) {
                      context.read<TaskProvider>().addTask(_taskController.text.trim());
                      _taskController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF39FF14),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: const Center(
                      child: Text(
                        'CREATE TASK',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers:[
            SliverAppBar(
              backgroundColor: Colors.black,
              expandedHeight: 120.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                title: const Text(
                  'Focus Tasks',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children:[
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 150.0,
                        height: 150.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow:[
                            BoxShadow(
                              color: const Color(0xFF39FF14).withOpacity(0.05),
                              blurRadius: 60.0,
                              spreadRadius: 20.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions:[
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF39FF14)),
                  onPressed: () => _showAddTaskSheet(context),
                ),
                const SizedBox(width: 16.0),
              ],
            ),
            Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                if (taskProvider.isLoading) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF39FF14)),
                    ),
                  );
                }

                if (taskProvider.tasks.isEmpty) {
                  return const SliverFillRemaining(
                    child: PremiumEmptyState(
                      icon: Icons.task_alt_rounded,
                      title: 'No Active Tasks',
                      subtitle: 'Add a task to start tracking your focus sessions efficiently.',
                    ),
                  );
                }

                final pendingTasks = taskProvider.pendingTasks;
                final completedTasks = taskProvider.completedTasks;

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Logic to render sections (Pending vs Completed)
                      if (index == 0 && pendingTasks.isNotEmpty) {
                        return _buildSectionHeader('PENDING');
                      }
                      
                      int listIndex = index;
                      if (pendingTasks.isNotEmpty) listIndex--;

                      if (listIndex < pendingTasks.length) {
                        final task = pendingTasks[listIndex];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: TaskListItem(
                            task: task,
                            onToggle: () => taskProvider.toggleTaskCompletion(task.id),
                            onDelete: () => taskProvider.deleteTask(task.id),
                          ),
                        );
                      }

                      listIndex -= pendingTasks.length;

                      if (listIndex == 0 && completedTasks.isNotEmpty) {
                        return _buildSectionHeader('COMPLETED');
                      }

                      if (completedTasks.isNotEmpty) listIndex--;

                      if (listIndex < completedTasks.length) {
                        final task = completedTasks[listIndex];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: TaskListItem(
                            task: task,
                            onToggle: () => taskProvider.toggleTaskCompletion(task.id),
                            onDelete: () => taskProvider.deleteTask(task.id),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    // Calculate total item count including headers
                    childCount: taskProvider.tasks.length + 
                                (pendingTasks.isNotEmpty ? 1 : 0) + 
                                (completedTasks.isNotEmpty ? 1 : 0),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100.0)), // Padding for Bottom Nav
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context),
        backgroundColor: const Color(0xFF39FF14),
        child: const Icon(Icons.add, color: Colors.black, size: 28.0),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF555555),
          fontSize: 12.0,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
