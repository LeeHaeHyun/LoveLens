part of 'app_user_cubit.dart';

@immutable
sealed class AppUserState {
  void fold(Future<Null> Function(dynamic loggedInState) param0, Null Function(dynamic loggedOutState) param1) {}
}

final class AppUserInitial extends AppUserState {}

final class AppUserLoggedIn extends AppUserState {
  final User user;
  AppUserLoggedIn(this.user);
}
