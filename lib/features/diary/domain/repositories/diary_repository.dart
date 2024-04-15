import 'dart:io';

import 'package:diary_app/core/error/failures.dart';
import 'package:diary_app/features/diary/domain/entities/diary.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class DiaryRepository {
  Future<Either<Failure, Diary>> uploaddiary({
    required List<File> images,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  });

  Future<Either<Failure, List<Diary>>> getAlldiarys();

  Future<Either<Failure, void>> updateDiary({required Diary diary});
}
