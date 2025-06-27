import 'package:flutter/material.dart';
import 'package:todo/models/task_model.dart';
import 'package:todo/utils/snackbar_helper.dart';
import 'package:todo/widgets/status_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController taskController = TextEditingController();
  int? editIndex;
  TextEditingController editController = TextEditingController();

  final List<TaskModel> _tasksList = [];

  int get _activeTasksCount =>
      _tasksList.where((task) => !task.isCompleted).length;
  int get _completedTasksCount =>
      _tasksList.where((task) => task.isCompleted).length;

  bool showActiveTasks = true;

  FocusNode editFocusNode = FocusNode();

  void _addTask() {
    if (taskController.text.trim().isNotEmpty) {
      setState(
        () {
          _tasksList.add(
            TaskModel(
              task: taskController.text.trim(),
            ),
          );
        },
      );
      showSnackBar(context, '${taskController.text.trim()} is added');
      taskController.clear();
    } else {
      showSnackBar(context, 'Please enter a task');
    }
  }

  void _deleteTask(int index) {
    final deletedTask = _tasksList[index];
    setState(() {
      _tasksList.removeAt(index);
    });
    showSnackBar(context, '"${deletedTask.task}" is deleted');
  }

  @override
  Widget build(BuildContext context) {
    final List<TaskModel> filteredTasksList = _tasksList
        .where((task) => task.isCompleted != showActiveTasks)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusCard(
                      title: 'Active Tasks',
                      count: _activeTasksCount,
                      isActive: showActiveTasks,
                      onTap: () {
                        setState(() {
                          showActiveTasks = true;
                        });
                      },
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(width: 20),
                    StatusCard(
                      title: 'Completed Tasks',
                      count: _completedTasksCount,
                      isActive: !showActiveTasks,
                      onTap: () {
                        setState(() {
                          showActiveTasks = false;
                        });
                      },
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: taskController,
                      decoration: const InputDecoration(
                        labelText: 'Add a new task',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _addTask(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('Add Task'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: filteredTasksList.isEmpty
                    ? const Center(
                        child: Text(
                          'No tasks found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredTasksList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Dismissible(
                            key: Key(UniqueKey().toString()),
                            background: Container(
                              color: showActiveTasks
                                  ? Colors.green
                                  : Colors.orange,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              child: showActiveTasks
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : const Icon(Icons.restore,
                                      color: Colors.white),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                return await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(showActiveTasks
                                        ? 'Complete Task'
                                        : 'Reopen Task'),
                                    content: const Text('Are you sure?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Ok'),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Task'),
                                    content: const Text('Are you sure?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Ok'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            onDismissed: (direction) {
                              final task = filteredTasksList[index];
                              final taskIndex = _tasksList.indexOf(task);
                              if (direction == DismissDirection.startToEnd) {
                                setState(() {
                                  _tasksList[taskIndex]
                                      .isCompleted = !_tasksList[
                                          taskIndex]
                                      .isCompleted; //toggle completion status
                                });

                                showSnackBar(context,
                                    '"${_tasksList[taskIndex].task}" is completed');
                              } else {
                                _deleteTask(taskIndex);
                              }
                            },
                            child: Card(
                              child: ListTile(
                                title: editIndex == index
                                    ? TextField(
                                        controller: editController,
                                        autofocus: true,
                                        focusNode: editFocusNode,
                                        key: ValueKey(editIndex),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onSubmitted: (newValue) {
                                          setState(() {
                                            final taskIndex =
                                                _tasksList.indexOf(
                                                    filteredTasksList[index]);
                                            _tasksList[taskIndex].task =
                                                newValue;
                                            editIndex = null;
                                          });
                                        },
                                      )
                                    : Text(filteredTasksList[index].task),
                                trailing: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (editIndex == index) {
                                        final taskIndex = _tasksList
                                            .indexOf(filteredTasksList[index]);
                                        _tasksList[taskIndex].task =
                                            editController.text;
                                        editIndex = null;
                                        // Ensure TextField gets unfocused after completing rebuild
                                        // editFocusNode.unfocus();
                                      } else {
                                        editIndex = index;
                                        editController.text =
                                            filteredTasksList[index].task;
                                      }
                                    });
                                    // Ensure TextField gets focus after rebuild
                                    Future.delayed(Duration(milliseconds: 50),
                                        () {
                                      editFocusNode.requestFocus();
                                    });
                                  },
                                  icon: Icon(
                                    editIndex == index
                                        ? Icons.check
                                        : Icons.edit,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, right: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _tasksList.clear();
                });
                showSnackBar(context, 'All tasks are deleted');
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}
