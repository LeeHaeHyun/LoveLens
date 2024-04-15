import 'package:flutter/material.dart';
import 'package:diary_app/core/utils/calculate_reading_time.dart';
import 'package:diary_app/features/diary/domain/entities/diary.dart';
import 'package:diary_app/features/diary/presentation/pages/diary_viewer_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diary_app/core/common/cubits/app_user/app_user_cubit.dart';

class DiaryCard extends StatelessWidget {
  static route(Diary diary) => MaterialPageRoute(
        builder: (context) => DiaryCard(
          diary: diary,
          color: Colors.black,
        ),
      );

  final Diary diary;
  final Color color;

  DiaryCard({
    Key? key,
    required this.diary,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, DiaryViewerPage.route(diary));
      },
      child: Container(
        height: 200,
        margin: const EdgeInsets.all(16).copyWith(
          bottom: 4,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: diary.topics
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Chip(label: Text(e)),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Text(
                  diary.title.length > 18
                      ? '${diary.title.substring(0, 18)} ...'
                      : diary.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            BlocBuilder<AppUserCubit, AppUserState>(
              builder: (context, state) {
                if (state is AppUserLoggedIn) {
                  Widget userInfo;
                  if (state.user.id != diary.posterId) {
                    userInfo = const Text(' (타인의 게시물)');
                  } else {
                    userInfo = const Text(' (나의 게시물)');
                  }
                  return Row(
                    children: [
                      Text('${diary.posterName}'),
                      userInfo,
                    ],
                  );
                } else {
                  return const Column(); // 빈 Column을 반환
                }
              },
            ),
            Column(
              children: [
                Text('약 ${calculateReadingTime(diary.content)} 분 분량'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
