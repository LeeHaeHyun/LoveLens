import 'package:diary_app/core/error/failures.dart';
import 'package:diary_app/core/usecase/usecase.dart';
import 'package:diary_app/features/diary/domain/entities/diary.dart';
import 'package:diary_app/features/diary/domain/repositories/diary_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAlldiarys implements UseCase<List<Diary>, NoParams> {
  final DiaryRepository diaryRepository;
  GetAlldiarys(this.diaryRepository);

  @override
  Future<Either<Failure, List<Diary>>> call(NoParams params) async {
    return await diaryRepository.getAlldiarys();
  }
}
