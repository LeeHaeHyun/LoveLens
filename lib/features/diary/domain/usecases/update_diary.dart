import 'package:diary_app/core/error/failures.dart';
import 'package:diary_app/core/usecase/usecase.dart';
import 'package:diary_app/features/diary/domain/entities/diary.dart';
import 'package:diary_app/features/diary/domain/repositories/diary_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateDiary implements UseCase<void, UpdateDiaryParams> {
  final DiaryRepository diaryRepository;
  UpdateDiary(this.diaryRepository);

  @override
  Future<Either<Failure, void>> call(UpdateDiaryParams params) async {
    return await diaryRepository.updateDiary(diary: params.diary);
  }
}

class UpdateDiaryParams {
  final Diary diary;

  UpdateDiaryParams({required this.diary});
}
