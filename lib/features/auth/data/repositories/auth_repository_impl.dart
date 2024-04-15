import 'package:diary_app/core/constants/constants.dart';
import 'package:diary_app/core/error/exceptions.dart';
import 'package:diary_app/core/error/failures.dart';
import 'package:diary_app/core/network/connection_checker.dart';
import 'package:diary_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:diary_app/core/common/entities/user.dart';
import 'package:diary_app/features/auth/data/models/user_model.dart';
import 'package:diary_app/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

// 인증(Authentication) 관련 기능을 담당
class AuthRepositoryImpl implements AuthRepository {
  // 인증에 관련된 원격 데이터를 처리하는 객체
  final AuthRemoteDataSource remoteDataSource;
  // 네트워크 연결 상태를 확인하는 객체
  final ConnectionChecker connectionChecker;
  // 사용자의 정보를 가져오는 비동기 함수
  const AuthRepositoryImpl(
    this.remoteDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      // 네트워크에 연결되어 있는지 확인
      if (!await (connectionChecker.isConnected)) {
        final session = remoteDataSource.currentUserSession;

        if (session == null) {
          return left(Failure('환영합니다😄! 서버에 연결중입니다.'));
        }
        // 세션이 존재한다면, 사용자 정보를 가지고 UserModel 객체를 생성 후 반환
        return right(
          UserModel(
            id: session.user.id,
            email: session.user.email ?? '',
            name: '',
          ),
        );
      }
      // 원격 데이터 소스에서 현재 사용자의 데이터를 확인
      final user = await remoteDataSource.getCurrentUserData();
      if (user == null) {
        return left(Failure('환영합니다😄 데이터를 불러오는 중입니다.'));
      }

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.loginWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  Future<Either<Failure, User>> _getUser(
    Future<User> Function() fn,
  ) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final user = await fn();

      return right(user);
    } on ServerException catch (e) {
      if (e.message.toLowerCase() == "invalid login credentials") {
        return left(Failure("존재하지 않는 계정입니다. 다시 확인해주세요!"));
      } else if (e.message.toLowerCase() == "anonymous sign-ins are disabled") {
        return left(Failure("공백을 포함한 회원 정보를 올바르게 입력해주세요!"));
      } else if (e.message.toLowerCase() ==
          "password should be at least 6 characters") {
        return left(Failure("비밀번호는 최소 6자 이상, 문자와 숫자를 섞어서 입력해주세요!"));
      } else if (e.message.toLowerCase() ==
          "signup requires a vaild password") {
        return left(Failure("비밀번호는 최소 6자 이상, 문자와 숫자를 섞어서 입력해주세요!"));
      } else if (e.message.toLowerCase() == "email rate limit exceeded") {
        return left(Failure("안정된 서버를 위해 1시간 후에 다시 시도해주세요!"));
      } else if (e.message.toLowerCase() ==
          "unable to validate email address: invalid format") {
        return left(Failure("올바른 이메일 형식이 아닙니다. 다시 확인해주세요!"));
      } else if (e.message.toLowerCase() == "user already registered") {
        return left(Failure("이미 가입된 이메일입니다. 다른 이메일을 작성해주세요!"));
      }
      return left(Failure("개발자에게 문의해주세요. 내용은 ${e.message}"));
    }
  }
}
