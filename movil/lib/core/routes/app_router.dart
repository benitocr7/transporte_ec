import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_step1_screen.dart';
import '../../features/auth/presentation/screens/register_step2_screen.dart';
import '../../features/auth/domain/user_entity.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/loads/presentation/screens/loads_screen.dart';
import '../../features/loads/presentation/screens/load_detail_screen.dart';
import '../../features/loads/data/loads_repository_impl.dart';
import '../../features/loads/presentation/cubit/loads_cubit.dart';
import '../../features/publish/presentation/screens/publish_screen.dart';
import '../../features/messages/presentation/screens/messages_screen.dart';
import '../../features/messages/presentation/screens/chat_screen.dart';
import '../../features/messages/presentation/cubit/messages_cubit.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../widgets/main_shell.dart';

class AppRouter {
  AppRouter(this._authCubit);

  final AuthCubit _authCubit;
  final _loadsRepo = LoadsRepositoryImpl();
  final _messagesCubit = MessagesCubit();

  late final GoRouter router = GoRouter(
    initialLocation: '/home',
    refreshListenable: _GoRouterRefreshStream(_authCubit.stream),
    redirect: (context, state) {
      final authState = _authCubit.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register');

      if (authState is AuthInitial || authState is AuthLoading) return null;

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fadeTransition(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/register/step1',
        pageBuilder: (context, state) => _slideTransition(state, const RegisterStep1Screen()),
      ),
      GoRoute(
        path: '/register/step2',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return _slideTransition(
            state,
            RegisterStep2Screen(
              name: extra['name'] ?? '',
              email: extra['email'] ?? '',
              password: extra['password'] ?? '',
            ),
          );
        },
      ),

      // Main shell
      ShellRoute(
        builder: (context, state, child) => MainShell(
          child: child,
          location: state.matchedLocation,
        ),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _fadeTransition(state, const HomeScreen()),
          ),
          GoRoute(
            path: '/loads',
            pageBuilder: (context, state) => _fadeTransition(
              state,
              BlocProvider(
                create: (_) => LoadsCubit(_loadsRepo),
                child: const LoadsScreen(),
              ),
            ),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return _slideTransition(
                    state,
                    BlocProvider(
                      create: (_) => LoadsCubit(_loadsRepo),
                      child: LoadDetailScreen(loadId: id),
                    ),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/publish',
            pageBuilder: (context, state) => _fadeTransition(state, const PublishScreen()),
          ),
          GoRoute(
            path: '/messages',
            pageBuilder: (context, state) => _fadeTransition(
              state,
              BlocProvider.value(
                value: _messagesCubit,
                child: const MessagesScreen(),
              ),
            ),
            routes: [
              GoRoute(
                path: 'chat/:contactId',
                pageBuilder: (context, state) {
                  final contactId = state.pathParameters['contactId']!;
                  final extra = state.extra as Map<String, String>? ?? {};
                  final contactName = extra['name'] ?? 'Empresa';
                  return _slideTransition(
                    state,
                    BlocProvider.value(
                      value: _messagesCubit,
                      child: ChatScreen(
                        contactId: contactId,
                        contactName: contactName,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => _fadeTransition(state, const ProfileScreen()),
          ),
        ],
      ),
    ],
  );

  static CustomTransitionPage _fadeTransition(GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondary, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  static CustomTransitionPage _slideTransition(GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondary, child) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final dynamic _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
