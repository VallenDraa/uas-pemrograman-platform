import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebaselab/models/model.dart';

import '../services/firebase_service.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studymatController = TextEditingController();
  final TextEditingController _targetDateController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // FirebaseService instance
  final FirebaseService _firebaseService = FirebaseService();

  // Search and filtering
  String _searchQuery = '';
  bool _sortAscending = true;

  // Filter tasks based on search query
  List<QueryDocumentSnapshot> _filterTasks(List<QueryDocumentSnapshot> tasks) {
    if (_searchQuery.isEmpty) {
      return tasks;
    } else {
      return tasks.where((task) {
        final name = task['name'].toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  // Sort tasks based on target_date
  List<QueryDocumentSnapshot> _sortTasks(List<QueryDocumentSnapshot> tasks) {
    tasks.sort((a, b) {
      final dateA = DateTime.parse(a['target_date']);
      final dateB = DateTime.parse(b['target_date']);
      if (_sortAscending) {
        return dateA.compareTo(dateB);
      } else {
        return dateB.compareTo(dateA);
      }
    });
    return tasks;
  }

  // Add task
  Future<void> _addTask() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          labelText: 'Subject/Topic Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a subject/topic name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _studymatController,
                      decoration:
                          const InputDecoration(labelText: 'Study Material'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter study material details';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _targetDateController,
                      decoration:
                          const InputDecoration(labelText: 'Target Date'),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          _targetDateController.text =
                              pickedDate.toIso8601String();
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a target date';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                          labelText: 'Duration (in hours)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter duration';
                        }
                        int? parsedValue = int.tryParse(value);
                        if (parsedValue == null || parsedValue < 1) {
                          return 'Please enter a valid positive number greater than 1';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final task = Task(
                            name: _nameController.text,
                            studymat: _studymatController.text,
                            targetdate: _targetDateController.text,
                            duration: _durationController.text,
                          );

                          try {
                            await _firebaseService.addTask(task);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Task added successfully!')),
                            );
                            Navigator.pop(context); // Close the modal
                            _clearFields();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error adding task: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('Save Task'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _clearFields() {
    _nameController.clear();
    _studymatController.clear();
    _targetDateController.clear();
    _durationController.clear();
  }

// Edit task
  Future<void> _editTask(String taskId) async {
    try {
      final taskDoc = await _firebaseService.getTaskById(taskId);
      if (taskDoc.exists) {
        final taskData = taskDoc.data() as Map<String, dynamic>;
        _nameController.text = taskData['name'] ?? '';
        _studymatController.text = taskData['studymat'] ?? '';
        _targetDateController.text = taskData['target_date'] ?? '';
        _durationController.text = taskData['duration'] ?? '';

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                              labelText: 'Subject/Topic Name'),
                        ),
                        TextFormField(
                          controller: _studymatController,
                          decoration: const InputDecoration(
                              labelText: 'Study Material'),
                        ),
                        TextFormField(
                          controller: _targetDateController,
                          decoration:
                              const InputDecoration(labelText: 'Target Date'),
                        ),
                        TextFormField(
                          controller: _durationController,
                          decoration: const InputDecoration(
                              labelText: 'Duration (in hours)'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final updatedTask = Task(
                                name: _nameController.text,
                                studymat: _studymatController.text,
                                targetdate: _targetDateController.text,
                                duration: _durationController.text,
                              );
                              await _firebaseService.updateTask(
                                  taskId, updatedTask);

                              await Future.delayed(const Duration(seconds: 1));
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                              _clearFields();
                            }
                          },
                          child: const Text('Update Task'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      } else {
        throw Exception('Task not found');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Delete task
  Future<void> _deleteTask(String taskId) async {
    try {
      await _firebaseService.deleteTask(taskId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black38,
        title: const Text(
          'Study Planner',
          style: TextStyle(fontSize: 26, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Tasks',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Sort by Date:'),
              IconButton(
                icon: Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<QueryDocumentSnapshot>>(
              stream: _firebaseService.getTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No tasks available.'));
                } else {
                  final tasks = snapshot.data!;
                  final filteredTasks = _filterTasks(tasks);
                  final sortedTasks = _sortTasks(filteredTasks);

                  return ListView.builder(
                    itemCount: sortedTasks.length,
                    itemBuilder: (context, index) {
                      final task = Task.fromMap(
                          sortedTasks[index].data() as Map<String, dynamic>);
                      final taskId = sortedTasks[index].id;

                      return ListTile(
                        title: Text(task.name),
                        subtitle: Column(
                          children: [
                            Text('Duration: ${task.duration} hours'),
                            Text('Material : ${task.studymat} '),
                            Text('Due Date : ${task.targetdate} '),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editTask(taskId),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteTask(taskId),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: Colors.black38,
        child: const Icon(Icons.add),
      ),
    );
  }
}
