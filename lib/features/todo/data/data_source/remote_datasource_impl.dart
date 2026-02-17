import 'dart:convert';
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        //  server null qaytarsa -> bo‘sh list
        if (data == null) return <TodoModel>[];

        final List rawList;
        if (data is List) {
          rawList = data;
        } else if (data is Map<String, dynamic> && data['results'] is List) {
          rawList = data['results'] as List;
        } else {
          //  format boshqa bo‘lsa ham crash bo‘lmasin
          return <TodoModel>[];
        }

        return rawList
            .whereType<Map<String, dynamic>>()
            .map(TodoModel.fromJson)
            .toList();
      }

      throw Exception('Get All failed: ${response.statusCode}');
    } catch (e, s) {
      LoggerService.error('Error during Get All: $e');
      print(s);
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final raw = response.data;

        final Map<String, dynamic> json = raw is String
            ? jsonDecode(raw) as Map<String, dynamic>
            : (raw as Map<String, dynamic>);

        return CreateModel.fromJson(json);
      }

      throw Exception('Update failed: ${response.statusCode}');
    } catch (e, s) {
      LoggerService.error('Error during Update: $e');
      print(s);
      rethrow;
    }
  }

  @override
  Future<UpdateModel> update({required String title, required int id}) async {
    try {
      final response = await dioClient.put(
        "${ApiUrls.update}?id=$id",
        data: {
          "title": title,
          "completed": false, // ✅ edit doim false
        },
      );
      return _parseUpdate(response);
    } catch (e, s) {
      LoggerService.error('Error during Update: $e');
      print(s);
      rethrow;
    }
  }

  @override
  Future<UpdateModel> toggleCompleted({
    required int id,
    required bool completed,
    required String title,
  }) async {
    try {
      final response = await dioClient.put(
        "${ApiUrls.update}?id=$id",
        data: {
          "title": title,
          "completed": completed, // ✅ checkbox qiymati
        },
      );
      return _parseUpdate(response);
    } catch (e, s) {
      LoggerService.error('Error during Toggle: $e');
      print(s);
      rethrow;
    }
  }

  UpdateModel _parseUpdate(dynamic response) {
    // response: sening dioClient Response qaytaradi (statusCode, data)
    final status = response.statusCode as int?;
    if (status == 200 || status == 201) {
      final raw = response.data;
      final Map<String, dynamic> json = raw is String
          ? jsonDecode(raw) as Map<String, dynamic>
          : (raw as Map<String, dynamic>);
      return UpdateModel.fromJson(json);
    }
    throw Exception('Request failed: $status');
  }

  @override
  Future<void> delete({required String id}) async {
    try {
      final response = await dioClient.delete(
        "${ApiUrls.delete}?id=$id",
      );

      final status = response.statusCode ?? 0;
      if (status == 204 || status == 200) return;

      throw Exception('Delete failed: $status');
    } catch (e, s) {
      LoggerService.error('Error during Delete: $e');
      print(s);
      rethrow;
    }
  }
}