import 'dart:io';

import 'package:diary_app/core/constants/constants.dart';
import 'package:diary_app/core/error/exceptions.dart';
import 'package:diary_app/core/error/failures.dart';
import 'package:diary_app/core/network/connection_checker.dart';
import 'package:diary_app/features/diary/data/datasources/diary_local_data_source.dart';
import 'package:diary_app/features/diary/data/datasources/diary_remote_data_source.dart';
import 'package:diary_app/features/diary/data/models/diary_model.dart';
import 'package:diary_app/features/diary/domain/entities/diary.dart';
import 'package:diary_app/features/diary/domain/repositories/diary_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final DiaryRemoteDataSource diaryRemoteDataSource;
  final DiaryLocalDataSource diaryLocalDataSource;
  final ConnectionChecker connectionChecker;

  DiaryRepositoryImpl(
    this.diaryRemoteDataSource,
    this.diaryLocalDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, Diary>> uploaddiary({
    required List<File> images,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      List<String> imageUrls = [];
      for (File image in images) {
        DiaryModel diaryModel = DiaryModel(
          id: const Uuid().v1(),
          posterId: posterId,
          title: title,
          content: content,
          imageUrls: [],
          topics: topics,
          updatedAt: DateTime.now(),
        );

        final imageUrl = await diaryRemoteDataSource
            .uploaddiaryImage(images: [image], diary: diaryModel);
        imageUrls.add(imageUrl);
      }

      DiaryModel diaryModel = DiaryModel(
        id: const Uuid().v1(),
        posterId: posterId,
        title: title,
        content: content,
        imageUrls: imageUrls,
        topics: topics,
        updatedAt: DateTime.now(),
      );

      final uploadeddiary = await diaryRemoteDataSource.uploaddiary(diaryModel);
      return right(uploadeddiary);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Diary>>> getAlldiarys() async {
    try {
      if (!await connectionChecker.isConnected) {
        final diarys = diaryLocalDataSource.loaddiarys();
        return right(diarys);
      }
      final diarys = await diaryRemoteDataSource.getAlldiarys();
      diaryLocalDataSource.uploadLocaldiarys(diarys: diarys);
      return right(diarys);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateDiary({required Diary diary}) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      final updatedDiary = await diaryRemoteDataSource.updateDiary(
        DiaryModel.fromDiary(diary), // DiaryModel에 fromDiary 메서드 추가
      );
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
