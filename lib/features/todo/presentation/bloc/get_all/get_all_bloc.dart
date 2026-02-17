import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:ntodo/features/todo/domain/usecase/get_usecase.dart';
import 'package:ntodo/features/todo/domain/usecase/update_usecase.dart';
import 'package:ntodo/features/todo/presentation/bloc/bloc_event.dart';
import 'package:ntodo/features/todo/presentation/bloc/get_all/get_all_state.dart';
import '../../../domain/entities/get_entity.dart';
import 'package:ntodo/features/auth/data/datasource/local/auth_local_remote_datasource.dart';
import '../../../../../core/di/service_locator.dart';

class GetAllBloc extends Bloc<HomeEvent, GetAllState> {
  final GetUsecase getUsecase;
  final UpdateUsecase updateUsecase;

  GetAllBloc(this.getUsecase, this.updateUsecase) : super(GetAllInitial()) {
    on<GetAllEvent>(_onGetAll);
    on<ToggleTodoEvent>(_onToggle);
  }

  Future<void> _onGetAll(GetAllEvent event, Emitter<GetAllState> emit) async {
    emit(GetAllLoading());
    try {
      final result = await getUsecase();
      emit(GetAllSuccess(getEntity: result));
    } on DioException catch (e) {
      // ✅ 401 bo‘lsa session expired
      if (e.response?.statusCode == 401) {
        await sl<AuthLocalRemoteDatasource>().logout();
        emit(GetAllError(message: "SESSION_EXPIRED"));
        return;
      }
      emit(GetAllError(message: _mapDioErrorToMessage(e)));
    } catch (_) {
      emit(GetAllError(message: "Noma’lum xato yuz berdi"));
    }
  }

  Future<void> _onToggle(ToggleTodoEvent event, Emitter<GetAllState> emit) async {
    final current = state;
    if (current is! GetAllSuccess) return;

    final updatedList = current.getEntity.map((t) {
      if (t.id == event.id) {
        return GetEntity(
          id: t.id,
          title: t.title,
          completed: event.value,
          userId: t.userId,
        );
      }
      return t;
    }).toList();

    emit(GetAllSuccess(getEntity: updatedList));

    try {
      await updateUsecase(
        id: event.id,
        title: event.title,
        completed: event.value,
      );
    } on DioException catch (e) {
      // ✅ 401 bo‘lsa session expired
      if (e.response?.statusCode == 401) {
        await sl<AuthLocalRemoteDatasource>().logout();
        emit(GetAllError(message: "SESSION_EXPIRED"));
        return;
      }
      // ❗ boshqa xato -> rollback
      emit(GetAllSuccess(getEntity: current.getEntity));
    } catch (_) {
      emit(GetAllSuccess(getEntity: current.getEntity));
    }
  }

  String _mapDioErrorToMessage(DioException error) {
    if (error.type == DioExceptionType.unknown) return "Internet ulanmagan.";
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return "So‘rov vaqtida javob kelmadi.";
    }

    final code = error.response?.statusCode;
    if (code == 400) return "Ma’lumot noto‘g‘ri.";
    if (code == 401) return "Authorization xato.";
    if (code == 500) return "Server xatosi.";

    return "Noma’lum xato.";
  }
}