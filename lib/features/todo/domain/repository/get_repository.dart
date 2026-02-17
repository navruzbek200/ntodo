
import 'package:ntodo/features/todo/domain/entities/create_entity.dart';
import 'package:ntodo/features/todo/domain/entities/update_entity.dart';

import '../entities/get_entity.dart';

abstract class GetRepository {


  Future<List<GetEntity>> getAll();
  Future<CreateEntity>create({required String title});
  Future<UpdateEntity>update({required String title, required int id});
  Future<UpdateEntity> toggleCompleted({required int id, required bool completed, required String title});
  Future<void>delete({required String id,});

}
