import 'package:ntodo/features/todo/data/models/create_model.dart';
import 'package:ntodo/features/todo/data/models/todo_model.dart';
import 'package:ntodo/features/todo/data/models/update_model.dart';

abstract class GetRemoteDatasource {
  Future<List<TodoModel>> getAll();
  Future<CreateModel> create({required String title});
  Future<UpdateModel> update({required String title, required int id});
  Future<UpdateModel> toggleCompleted({required String title, required int id, required bool completed});
  Future<void> delete({required String id});

  }


