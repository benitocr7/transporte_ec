import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  final prefs = await SharedPreferences.getInstance();
  final AuthRepository authRepo = AuthRepositoryImpl(prefs);
  final authCubit = AuthCubit(authRepo);

  // Check existing session on startup
  await authCubit.checkSession();

  runApp(RutaLinkApp(authCubit: authCubit));
}

class RutaLinkApp extends StatefulWidget {
  const RutaLinkApp({super.key, required this.authCubit});
  final AuthCubit authCubit;

  @override
  State<RutaLinkApp> createState() => _RutaLinkAppState();
}

class _RutaLinkAppState extends State<RutaLinkApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(widget.authCubit);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: widget.authCubit,
      child: MaterialApp.router(
        title: 'RutaLink',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _appRouter.router,
      ),
    );
  }
}
