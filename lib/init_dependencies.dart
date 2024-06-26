import 'package:diary_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:diary_app/core/network/connection_checker.dart';
import 'package:diary_app/core/secrets/app_secrets.dart';
import 'package:diary_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:diary_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:diary_app/features/auth/domain/repository/auth_repository.dart';
import 'package:diary_app/features/auth/domain/usecases/current_user.dart';
import 'package:diary_app/features/auth/domain/usecases/user_login.dart';
import 'package:diary_app/features/auth/domain/usecases/user_sign_up.dart';
import 'package:diary_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:diary_app/features/diary/data/datasources/diary_local_data_source.dart';
import 'package:diary_app/features/diary/data/datasources/diary_remote_data_source.dart';
import 'package:diary_app/features/diary/data/repositories/diary_repository_impl.dart';
import 'package:diary_app/features/diary/domain/repositories/diary_repository.dart';
import 'package:diary_app/features/diary/domain/usecases/get_all_diarys.dart';
import 'package:diary_app/features/diary/domain/usecases/update_diary.dart';
import 'package:diary_app/features/diary/domain/usecases/upload_diary.dart';
import 'package:diary_app/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'init_dependencies.main.dart';
