import 'package:diary_app/core/error/exceptions.dart';
import 'package:diary_app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 사용자의 인증 정보를 처리하기 위한 데이터 소스를 정의하고 구현
abstract interface class AuthRemoteDataSource {
  // 현재 사용자 세션 정보를 가져오는 메서드
  Session? get currentUserSession;
  //  이메일과 비밀번호를 사용하여 새로운 사용자를 등록
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });
  // 이메일과 비밀번호를 사용하여 사용자를 로그인
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });
  // 현재 사용자의 데이터를 가져옴
  Future<UserModel?> getCurrentUserData();
}

// AuthRemoteDataSource 인터페이스를 구현
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // Supabase 데이터베이스와 통신
  final SupabaseClient supabaseClient;
  AuthRemoteDataSourceImpl(this.supabaseClient);

// currentUserSession : 현재 사용자 세션 정보를 가져옴
  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;

// 이메일과 비밀번호를 사용하여 사용자를 로그인
  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Supabase 클라이언트를 사용하여 이메일과 비밀번호를 인증
      final response = await supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
      );
      if (response.user == null) {
        throw const ServerException('회원 정보가 비어 있습니다.');
      }
      // UserModel 객체로 변환하여 반환
      return UserModel.fromJson(response.user!.toJson());
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {
          'name': name,
        },
      );
      if (response.user == null) {
        throw const ServerException('회원 정보가 비어 있습니다.');
      }
      return UserModel.fromJson(response.user!.toJson());
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUserSession != null) {
        final userData = await supabaseClient.from('profiles').select().eq(
              'id',
              currentUserSession!.user.id,
            );
        return UserModel.fromJson(userData.first).copyWith(
          email: currentUserSession!.user.email,
        );
      }

      return null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
