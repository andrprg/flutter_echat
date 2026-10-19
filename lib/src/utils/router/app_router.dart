/// Конфиг go_router (заготовка).
///
/// После добавления пакета `go_router`:
/// — `MaterialApp.router` в `src/app.dart`;
/// — `GoRouter` + `StatefulShellRoute` здесь;
/// — SMART shell (`nav_shell.dart`) рядом.

enum AppRoute {
  login,           // /login
  register,        // /register
  signupProfile,   // /signup/profile
  chats,           // /chats
  chatThread,      // /chats/:id
  groups,          // /groups
  groupThread,     // /groups/:id
  profile,         // /profile
  more,            // /more
}

@Riverpod(keepAlive: true)
class AppRouter extends _$AppRouter {
  @override
  GoRouter build() {
    return GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      ],
    );
  }
}