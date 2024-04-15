part of 'diary_bloc.dart';

@immutable
sealed class DiaryEvent {}

final class DiaryUpload extends DiaryEvent {
  final DiaryModel diary;
  final String posterId;
  final String title;
  final String content;
  final List<File> images;
  final List<String> topics;

  DiaryUpload({
    required this.diary,
    required this.posterId,
    required this.title,
    required this.content,
    required this.images,
    required this.topics,
  });
}

final class DiaryFetchAlldiarys extends DiaryEvent {}

final class DiaryUpdate extends DiaryEvent {
  final Diary diary;

  DiaryUpdate({required this.diary});
}
