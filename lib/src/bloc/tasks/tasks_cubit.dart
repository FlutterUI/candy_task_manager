import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:task_manger/src/data/repositories/task_repository.dart';
import 'package:task_manger/src/mangers/notification_manger.dart';

import 'tasks.state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit(this._taskRepository, this._notificationManger)
      : super(const TasksState.init()) {
    _taskRepository.onTasksChange.listen((event) {
      init();
    });
  }

  final TaskRepository _taskRepository;
  final NotificationManger _notificationManger;
  void init() async {
    try {
      final tasks = await _taskRepository.readTodayTasks();
      final tasksOfDates = await _taskRepository.readUpCommingTasks();

      emit(state.copyWith(
          isLoading: false, todayTasks: tasks, tasksOfDate: tasksOfDates));
    } catch (e) {
      log(e.toString());
    }
  }

  void markAsCompleted(int id) async {
    final task = state.todayTasks.firstWhere((element) => element.id == id);
    if (task.isCompleted) {
      return;
    }
    final newTask = task.copyWith(isCompleted: true);
    await _taskRepository.markTaskAsComplete(id);
    final newTasks = [...state.todayTasks];
    newTasks.removeWhere((element) => element.id == id);
    newTasks.add(newTask);
    await _notificationManger.cancelNotification(id);
    emit(state.copyWith(todayTasks: newTasks));
  }
}