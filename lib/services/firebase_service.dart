import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/model.dart';

class FirebaseService {
  // Instances declarations
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Add task to Firestore
  Future<void> addTask(Task task) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('study_plans')
            .doc(user.uid)
            .collection('tasks')
            .add(task.toMap());
      } catch (e) {
        throw Exception('Error adding task: $e');
      }
    } else {
      throw Exception('User not logged in!');
    }
  }

  // Update task in Firestore
  Future<void> updateTask(String taskId, Task task) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('study_plans')
            .doc(user.uid)
            .collection('tasks')
            .doc(taskId)
            .update(task.toMap());
      } catch (e) {
        throw Exception('Error updating task: $e');
      }
    } else {
      throw Exception('User not logged in!');
    }
  }

  // Delete task from Firestore
  Future<void> deleteTask(String taskId) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('study_plans')
            .doc(user.uid)
            .collection('tasks')
            .doc(taskId)
            .delete();
      } catch (e) {
        throw Exception('Error deleting task: $e');
      }
    } else {
      throw Exception('User not logged in!');
    }
  }

  // Get tasks from Firestore
  Stream<List<QueryDocumentSnapshot>> getTasks() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('study_plans')
          .doc(user.uid)
          .collection('tasks')
          .snapshots()
          .map((snapshot) => snapshot.docs);
    } else {
      return Stream.value([]);  // Return an empty stream if user is not logged in
    }
  }

  // Get a single task by its ID
  Future<DocumentSnapshot> getTaskById(String taskId) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        return await _firestore
            .collection('study_plans')
            .doc(user.uid)
            .collection('tasks')
            .doc(taskId)
            .get();
      } catch (e) {
        throw Exception('Error fetching task: $e');
      }
    } else {
      throw Exception('User not logged in!');
    }
  }
}
