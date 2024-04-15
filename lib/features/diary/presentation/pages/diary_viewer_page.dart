import 'package:diary_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:diary_app/core/secrets/app_secrets.dart';
import 'package:diary_app/core/theme/app_pallete.dart';
import 'package:diary_app/core/utils/calculate_reading_time.dart';
import 'package:diary_app/core/utils/format_date.dart';
import 'package:diary_app/features/diary/domain/entities/diary.dart';
import 'package:diary_app/features/diary/presentation/pages/diary_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'edit_diary_page.dart';

class DiaryViewerPage extends StatefulWidget {
  static route(Diary diary) => MaterialPageRoute(
        builder: (context) => DiaryViewerPage(
          diary: diary,
        ),
      );
  final Diary diary;
  const DiaryViewerPage({
    Key? key,
    required this.diary,
  }) : super(key: key);

  @override
  _DiaryViewerPageState createState() => _DiaryViewerPageState();
}

class _DiaryViewerPageState extends State<DiaryViewerPage> {
  final PageController _pageController = PageController();
  final SupabaseClient _supabaseClient = SupabaseClient(
    AppSecrets.supabaseUrl,
    AppSecrets.supabaseAnonKey,
  );

  void _onDeleteButtonPressed() async {
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserLoggedIn) {
      String userId = userState.user.id;
      String diaryId = widget.diary.id;

      if (userId == widget.diary.posterId) {
        bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('삭제하기'),
              content: const Text('정말로 영구히 삭제할까요?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('삭제'),
                ),
              ],
            );
          },
        );

        if (confirmDelete == true) {
          final response =
              await _supabaseClient.from('diarys').delete().eq('id', diaryId);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DiaryPage(),
            ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('삭제 불가'),
              content: const Text('내가 쓴 게시물이 아니기에 삭제할 수 없습니다.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _onEditButtonPressed() {
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserLoggedIn) {
      String userId = userState.user.id;
      String posterId = widget.diary.posterId;
      if (userId == posterId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditDiaryPage(
              diary: widget.diary,
            ),
          ),
        );
      } else {
        _showEditNotAllowedDialog();
      }
    }
  }

  void _showEditNotAllowedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('수정 불가'),
          content: const Text('내가 쓴 게시물이 아니기에 수정할 수 없습니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 350,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: widget.diary.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.diary.imageUrls[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: widget.diary.imageUrls.length,
                        effect: const SwapEffect(
                            spacing: 8.0,
                            radius: 4.0,
                            dotWidth: 10.0,
                            dotHeight: 10.0,
                            paintStyle: PaintingStyle.stroke,
                            strokeWidth: 1.5,
                            dotColor: Colors.grey,
                            activeDotColor: Colors.indigo),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.diary.title.length > 15
                        ? '${widget.diary.title.substring(0, 15)} ...'
                        : widget.diary.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _onEditButtonPressed();
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () {
                          _onDeleteButtonPressed();
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '작성자: ${widget.diary.posterName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formatDateBydMMMYYYY(widget.diary.updatedAt),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppPallete.greyColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '약 ${calculateReadingTime(widget.diary.content)}분 분량',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppPallete.greyColor,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.diary.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
