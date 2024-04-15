import 'package:diary_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:diary_app/core/theme/theme.dart';
import 'package:diary_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:diary_app/features/auth/presentation/pages/login_page.dart';
import 'package:diary_app/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:diary_app/features/diary/presentation/pages/diary_page.dart';
import 'package:diary_app/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 비동기적으로 실행
void main() async {
  // Flutter 애플리케이션의 바인딩을 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => serviceLocator<AppUserCubit>(),
      ),
      BlocProvider(
        create: (_) => serviceLocator<AuthBloc>(),
      ),
      BlocProvider(
        create: (_) => serviceLocator<DiaryBloc>(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '러브렌즈',
      theme: AppTheme.darkThemeMode.copyWith(
        textTheme: AppTheme.darkThemeMode.textTheme.copyWith(
          bodyMedium: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
          ),
          // 필요한 경우 다른 텍스트 스타일 설정 추가
        ),
      ),
      home: BlocSelector<AppUserCubit, AppUserState, bool>(
        selector: (state) {
          return state is AppUserLoggedIn;
        },
        builder: (context, isLoggedIn) {
          if (isLoggedIn) {
            return const DiaryPage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
