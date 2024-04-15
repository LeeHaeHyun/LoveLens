part of 'diary_bloc.dart';

@immutable
sealed class DiaryState {}

final class DiaryInitial extends DiaryState {}

final class DiaryLoading extends DiaryState {}

final class DiaryFailure extends DiaryState {
  final String error;
  DiaryFailure(this.error);
}

final class DiaryUploadSuccess extends DiaryState {}

final class DiarysDisplaySuccess extends DiaryState {
  final List<Diary> diarys;
  DiarysDisplaySuccess(this.diarys);
}

final class DiaryUpdateSuccess extends DiaryState {}
