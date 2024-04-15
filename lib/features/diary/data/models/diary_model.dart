import 'package:diary_app/features/diary/domain/entities/diary.dart';

class DiaryModel extends Diary {
  DiaryModel({
    required String id,
    required String posterId,
    required String title,
    required String content,
    required List<String> imageUrls,
    required List<String> topics,
    required DateTime updatedAt,
    String? posterName,
  }) : super(
          id: id,
          posterId: posterId,
          title: title,
          content: content,
          imageUrls: imageUrls,
          topics: topics,
          updatedAt: updatedAt,
          posterName: posterName,
        );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'poster_id': posterId,
      'title': title,
      'content': content,
      'image_urls': imageUrls,
      'topics': topics,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DiaryModel.fromJson(Map<String, dynamic> map) {
    return DiaryModel(
      id: map['id'] as String,
      posterId: map['poster_id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      imageUrls: List<String>.from(map['image_urls'] ?? []),
      topics: List<String>.from(map['topics'] ?? []),
      updatedAt: map['updated_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['updated_at']),
    );
  }

  DiaryModel copyWith({
    String? id,
    String? posterId,
    String? title,
    String? content,
    List<String>? imageUrls,
    List<String>? topics,
    DateTime? updatedAt,
    String? posterName,
  }) {
    return DiaryModel(
      id: id ?? this.id,
      posterId: posterId ?? this.posterId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      topics: topics ?? this.topics,
      updatedAt: updatedAt ?? this.updatedAt,
      posterName: posterName ?? this.posterName,
    );
  }

  factory DiaryModel.fromDiary(Diary diary) {
    return DiaryModel(
      id: diary.id,
      posterId: diary.posterId,
      title: diary.title,
      content: diary.content,
      imageUrls: diary.imageUrls,
      topics: diary.topics,
      updatedAt: diary.updatedAt,
      posterName: diary.posterName,
    );
  }
  factory DiaryModel.create({
    required String posterId,
    required String title,
    required String content,
    required List<String> topics,
    DateTime? updatedAt,
  }) {
    return DiaryModel(
      id: '',
      posterId: posterId,
      title: title,
      content: content,
      imageUrls: [],
      topics: topics,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
