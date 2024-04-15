import 'dart:io';
import 'package:diary_app/core/error/failures.dart';
import 'package:diary_app/core/usecase/usecase.dart';
import 'package:diary_app/features/diary/domain/entities/diary.dart';
import 'package:diary_app/features/diary/domain/repositories/diary_repository.dart';
import 'package:fpdart/fpdart.dart';

class Uploaddiary implements UseCase<Diary, UploaddiaryParams> {
  final DiaryRepository diaryRepository;
  Uploaddiary(this.diaryRepository);

  @override
  Future<Either<Failure, Diary>> call(UploaddiaryParams params) async {
    return await diaryRepository.uploaddiary(
      images: params.images,
      title: params.title,
      content: params.content,
      posterId: params.posterId,
      topics: params.topics,
    );
  }
}

class UploaddiaryParams {
  final String posterId;
  final String title;
  final String content;
  final List<File> images;
  final List<String> topics;

  UploaddiaryParams({
    required this.posterId,
    required this.title,
    required this.content,
    required this.images,
    required this.topics,
  });
}
