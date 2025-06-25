import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController taskController = TextEditingController();

  final List<Map<String, dynamic>> _tasksList = [];

  int get _activeTasksCount =>
      _tasksList.where((task) => !task['isCompleted']).length;
  int get _completedTasksCount =>
      _tasksList.where((task) => task['isCompleted']).length;

  bool showActiveTasks = true;

  void _addTask() {
    if (taskController.text.trim().isNotEmpty) {
      setState(
        () {
          _tasksList.add({
            'task': taskController.text.trim(),
            'isCompleted': false,
          });
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${taskController.text}" is added'),
          duration: const Duration(milliseconds: 800),
        ),
      );
      taskController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task'),
          duration: Duration(milliseconds: 800),
        ),
      );
    }
  }

  void _deleteTask(int index) {
    final deletedTask = _tasksList[index];
    setState(() {
      _tasksList.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${deletedTask['task']}" is deleted'),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filteredTasksList = _tasksList
        .where((task) => task['isCompleted'] != showActiveTasks)
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
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            showActiveTasks = true;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: showActiveTasks
                                ? Colors.orangeAccent
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Active Tasks',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$_activeTasksCount',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            showActiveTasks = false;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                !showActiveTasks ? Colors.green : Colors.grey,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Completed Tasks',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$_completedTasksCount',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
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
                        labelText: 'Enter a task',
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
                child: filteredTasksList.isNotEmpty
                    ? ListView.builder(
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
                                  // _tasksList[taskIndex]['isCompleted'] = true;
                                  _tasksList[taskIndex]['isCompleted'] =
                                      !_tasksList[taskIndex]['isCompleted'];
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '"${_tasksList[taskIndex]['task']}" is completed'),
                                    duration: const Duration(milliseconds: 800),
                                  ),
                                );
                              } else {
                                _deleteTask(taskIndex);
                              }
                            },
                            child: Card(
                              child: ListTile(
                                title: Text(filteredTasksList[index]['task']),
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          'No tasks found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
