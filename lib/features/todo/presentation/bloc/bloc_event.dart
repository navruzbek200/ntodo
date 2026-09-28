abstract class HomeEvent {
  const HomeEvent();
}

class GetAllEvent extends HomeEvent {
  /// true on first open: the bloc is app-wide, so without this a previous
  /// user's list could flash on screen after re-login.
  final bool clearCurrent;
  GetAllEvent({this.clearCurrent = false});
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
  final List<String> ids;
  DeleteEvent({required this.ids});
}
