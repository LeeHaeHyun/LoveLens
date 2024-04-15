import 'dart:io';
import 'package:diary_app/core/usecase/usecase.dart';
import 'package:diary_app/features/diary/data/models/diary_model.dart';
import 'package:diary_app/features/diary/domain/entities/diary.dart';
import 'package:diary_app/features/diary/domain/usecases/get_all_diarys.dart';
import 'package:diary_app/features/diary/domain/usecases/update_diary.dart';
import 'package:diary_app/features/diary/domain/usecases/upload_diary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'diary_event.dart';
part 'diary_state.dart';

class DiaryBloc extends Bloc<DiaryEvent, DiaryState> {
  final Uploaddiary _uploaddiary;
  final GetAlldiarys _getAlldiarys;
  final UpdateDiary _updateDiary;

  DiaryBloc({
    required Uploaddiary uploaddiary,
    required GetAlldiarys getAlldiarys,
    required UpdateDiary updateDiary,
  })  : _uploaddiary = uploaddiary,
        _getAlldiarys = getAlldiarys,
        _updateDiary = updateDiary,
        super(DiaryInitial()) {
    on<DiaryEvent>((event, emit) => emit(DiaryLoading()));
    on<DiaryUpload>(_ondiaryUpload);
    on<DiaryUpdate>(_onDiaryUpdate);
    on<DiaryFetchAlldiarys>(_onFetchAlldiarys);
  }

  void _ondiaryUpload(
    DiaryUpload event,
    Emitter<DiaryState> emit,
  ) async {
    final res = await _uploaddiary(
      UploaddiaryParams(
        posterId: event.posterId,
        title: event.title,
        content: event.content,
        images: event.images, // Changed event.image to event.images
        topics: event.topics,
      ),
    );

    res.fold(
      (l) => emit(DiaryFailure(l.message)),
      (r) => emit(DiaryUploadSuccess()),
    );
  }

  void _onFetchAlldiarys(
    DiaryFetchAlldiarys event,
    Emitter<DiaryState> emit,
  ) async {
    final res = await _getAlldiarys(NoParams());

    res.fold(
      (l) => emit(DiaryFailure(l.message)),
      (r) => emit(DiarysDisplaySuccess(r)),
    );
  }

  void _onDiaryUpdate(
    DiaryUpdate event,
    Emitter<DiaryState> emit,
  ) async {
    final res = await _updateDiary(
      UpdateDiaryParams(diary: event.diary),
    );

    res.fold(
      (l) => emit(DiaryFailure(l.message)),
      (r) => emit(DiaryUpdateSuccess()),
    );
  }
}
