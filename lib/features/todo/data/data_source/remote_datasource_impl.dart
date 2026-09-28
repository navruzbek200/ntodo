import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:ntodo/core/network/api_urls.dart';
import 'package:ntodo/features/todo/data/data_source/remote_datasource.dart';
import 'package:ntodo/features/todo/data/models/create_model.dart';
import 'package:ntodo/features/todo/data/models/todo_model.dart';
import 'package:ntodo/features/todo/data/models/update_model.dart';
import '../../../../../core/network/dio_clinet.dart';
import '../../../../../core/untils/logger.dart';

class GetRemoteDatasourceImpl implements GetRemoteDatasource {
  final DioClinet dioClient;

  const GetRemoteDatasourceImpl({
    required this.dioClient,
  });

  @override
  Future<List<TodoModel>> getAll() async {
    try {
      final response = await dioClient.get(ApiUrls.getAll);
      final data = response.data;

      // Backend returns `null` (not `[]`) when the user has no todos.
      if (data == null) return <TodoModel>[];
      if (data is! List) {
        throw FormatException('GET /todos: expected a list, got $data');
      }

      final todos = data
          .whereType<Map>()
          .map((e) => TodoModel.fromJson(e.cast<String, dynamic>()))
          .toList();
      LoggerService.info('Loaded ${todos.length} todos');
      return todos;
    } on DioException catch (e, s) {
      LoggerService.error('Get todos failed: ${e.response?.data ?? e.message}', e, s);
      rethrow;
    } catch (e, s) {
      LoggerService.error('Get todos: unexpected error', e, s);
      rethrow;
    }
  }

  @override
  Future<CreateModel> create({required String title}) async {
    try {
      final response = await dioClient.post(
        ApiUrls.create,
        data: {"title": title},
      );
      LoggerService.info('Todo created: "$title"');
      return CreateModel.fromJson(_asMap(response.data));
    } on DioException catch (e, s) {
      LoggerService.error('Create todo failed: ${e.response?.data ?? e.message}', e, s);
      rethrow;
    } catch (e, s) {
      LoggerService.error('Create todo: unexpected error', e, s);
      rethrow;
    }
  }

  @override
  Future<UpdateModel> update({required String title, required int id}) {
    return toggleCompleted(id: id, title: title, completed: false);
  }

  @override
  Future<UpdateModel> toggleCompleted({
    required int id,
    required bool completed,
    required String title,
  }) async {
    try {
      final response = await dioClient.put(
        ApiUrls.update,
        queryParams: {'id': id},
        data: {"title": title, "completed": completed},
      );
      LoggerService.info('Todo #$id updated: "$title", completed=$completed');
      return UpdateModel.fromJson(_asMap(response.data));
    } on DioException catch (e, s) {
      LoggerService.error('Update todo #$id failed: ${e.response?.data ?? e.message}', e, s);
      rethrow;
    } catch (e, s) {
      LoggerService.error('Update todo #$id: unexpected error', e, s);
      rethrow;
    }
  }

  @override
  Future<void> delete({required String id}) async {
    try {
      // Backend answers 204 No Content on success.
      await dioClient.delete(ApiUrls.delete, queryParams: {'id': id});
      LoggerService.info('Todo #$id deleted');
    } on DioException catch (e, s) {
      LoggerService.error('Delete todo #$id failed: ${e.response?.data ?? e.message}', e, s);
      rethrow;
    } catch (e, s) {
      LoggerService.error('Delete todo #$id: unexpected error', e, s);
      rethrow;
    }
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    final decoded = raw is String ? jsonDecode(raw) : raw;
    if (decoded is Map) return decoded.cast<String, dynamic>();
    throw FormatException('Expected a JSON object, got $raw');
  }
}
