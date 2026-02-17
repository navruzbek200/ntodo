abstract class HomeEvent {
  const HomeEvent();
}

class GetAllEvent extends HomeEvent {
  GetAllEvent();
}

  class CreateEvent extends HomeEvent {
  final String title;
  CreateEvent({required this.title});
}

class UpdateEvent extends HomeEvent {
  final String title;
  final int id;
  UpdateEvent({required this.title, required this.id});
}

class ToggleTodoEvent extends HomeEvent {
  final int id;
  final bool value;
  final String title;
  ToggleTodoEvent({required this.id, required this.value, required this.title});
}

class DeleteEvent extends HomeEvent {
  final String id;
  DeleteEvent({required this.id});
}
