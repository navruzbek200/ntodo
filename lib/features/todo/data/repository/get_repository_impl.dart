import 'package:ntodo/features/todo/domain/entities/create_entity.dart';
import 'package:ntodo/features/todo/domain/entities/get_entity.dart';
import 'package:ntodo/features/todo/domain/entities/update_entity.dart';
import 'package:ntodo/features/todo/domain/repository/get_repository.dart';

import '../data_source/remote_datasource.dart';

class GetRepositoryImpl implements GetRepository {
  final GetRemoteDatasource getRemoteDatasource;

  GetRepositoryImpl({required this.getRemoteDatasource});

  @override
  Future<List<GetEntity>> getAll(){
    return getRemoteDatasource.getAll();
  }

  @override
  Future<CreateEntity> create({required String title}) {
    return getRemoteDatasource.create(title: title);
  }

  @override
  Future<UpdateEntity> update({required String title, required int id}) {
    return getRemoteDatasource.update(title: title, id: id);
  }

  @override
  Future<UpdateEntity> toggleCompleted({required int id, required bool completed, required String title}) {
    return getRemoteDatasource.toggleCompleted(id: id, completed: completed, title: title);

  }

  @override
  Future<void> delete({required String id}) {
    return getRemoteDatasource.delete(id: id);
  }

}

