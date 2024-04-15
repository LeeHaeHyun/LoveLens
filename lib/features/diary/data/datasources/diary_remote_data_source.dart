import 'dart:io';

import 'package:diary_app/core/error/exceptions.dart';
import 'package:diary_app/features/diary/data/models/diary_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class DiaryRemoteDataSource {
  Future<DiaryModel> uploaddiary(DiaryModel diary);
  Future<void> updateDiary(DiaryModel diary);
  Future<String> uploaddiaryImage({
    required List<File> images,
    required DiaryModel diary,
  });
  Future<List<DiaryModel>> getAlldiarys();
}

class DiaryRemoteDataSourceImpl implements DiaryRemoteDataSource {
  final SupabaseClient supabaseClient;
  DiaryRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<DiaryModel> uploaddiary(DiaryModel diary) async {
    try {
      final diaryData =
          await supabaseClient.from('diarys').insert(diary.toJson()).select();

      return DiaryModel.fromJson(diaryData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploaddiaryImage({
    required List<File> images,
    required DiaryModel diary,
  }) async {
    try {
      for (File image in images) {
        // Iterate through each image in the list
        await supabaseClient.storage.from('diary_images').upload(
              diary.id,
              image,
            );
      }
      return supabaseClient.storage.from('diary_images').getPublicUrl(
            diary.id,
          );
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<DiaryModel>> getAlldiarys() async {
    try {
      final diarys =
          await supabaseClient.from('diarys').select('*, profiles (name)');
      return diarys
          .map(
            (diary) => DiaryModel.fromJson(diary).copyWith(
              posterName: diary['profiles']['name'],
            ),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateDiary(DiaryModel diary) async {
    try {
      await supabaseClient
          .from('diarys')
          .update(diary.toJson())
          .eq('id', diary.id);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
