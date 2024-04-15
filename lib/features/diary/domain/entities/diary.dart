import 'package:cross_file/src/types/interface.dart';

class Diary {
  final String id;
  final String posterId;
  final String title;
  final String content;
  final List<String> imageUrls;
  final List<String> topics;
  final DateTime updatedAt;
  final String? posterName;

  Diary({
    required this.id,
    required this.posterId,
    required this.title,
    required this.content,
    required this.imageUrls,
    required this.topics,
    required this.updatedAt,
    this.posterName,
  });
  Diary copyWith({
    String? id,
    String? posterId,
    String? title,
    String? content,
    List<String>? imageUrls,
    List<String>? topics,
    DateTime? updatedAt,
    String? posterName,
  }) {
    return Diary(
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
}
