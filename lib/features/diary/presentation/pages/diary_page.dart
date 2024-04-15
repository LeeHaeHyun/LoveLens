import 'package:diary_app/core/common/widgets/loader.dart';
import 'package:diary_app/core/theme/app_pallete.dart';
import 'package:diary_app/core/utils/show_snackbar.dart';
import 'package:diary_app/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:diary_app/features/diary/presentation/pages/add_new_diary_page.dart';
import 'package:diary_app/features/diary/presentation/widgets/diary_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class DiaryPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const DiaryPage(),
      );
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<DiaryBloc>().add(DiaryFetchAlldiarys());
  }

  Future<void> _launchURL() async {
    const url = 'https://open.kakao.com/o/s4kRirig';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw '연결할 수 없습니다. $url로 문의주세요!';
    }
  }

  void _refreshPage() {
    context.read<DiaryBloc>().add(DiaryFetchAlldiarys());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
              '러브렌즈 ${DateTime.now().difference(DateTime(2023, 3, 17)).inDays + 1}일✿'),
          actions: [
            IconButton(
              onPressed: _launchURL,
              icon: const Icon(Icons.link),
            ),
            IconButton(
              onPressed: _refreshPage,
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(context, AddNewDiaryPage.route());
              },
              icon: const Icon(
                CupertinoIcons.add_circled,
              ),
            ),
          ],
        ),
        body: BlocConsumer<DiaryBloc, DiaryState>(
          listener: (context, state) {
            if (state is DiaryFailure) {
              showSnackBar(context, state.error);
            }
          },
          builder: (context, state) {
            if (state is DiaryLoading) {
              return const Loader();
            }
            if (state is DiarysDisplaySuccess) {
              final sortedDiaries = state.diarys.toList()
                ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
              return ListView.builder(
                itemCount: state.diarys.length,
                itemBuilder: (context, index) {
                  return DiaryCard(
                    diary: sortedDiaries[index],
                    color: index % 2 == 0
                        ? AppPallete.gradient1
                        : AppPallete.gradient2,
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
