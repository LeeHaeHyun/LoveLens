import 'dart:io';
import 'dart:typed_data';

import 'package:diary_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:diary_app/core/common/widgets/loader.dart';
import 'package:diary_app/core/constants/constants.dart';
import 'package:diary_app/core/theme/app_pallete.dart';
import 'package:diary_app/core/utils/show_snackbar.dart';
import 'package:diary_app/features/diary/domain/entities/diary.dart';
import 'package:diary_app/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:diary_app/features/diary/presentation/pages/diary_page.dart';
import 'package:diary_app/features/diary/presentation/pages/last_edit_page.dart';
import 'package:diary_app/features/diary/presentation/pages/last_image_page.dart';
import 'package:diary_app/init_dependencies.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditDiaryPage extends StatefulWidget {
  final Diary diary;

  const EditDiaryPage({Key? key, required this.diary}) : super(key: key);

  @override
  State<EditDiaryPage> createState() => _EditDiaryPageState();
}

class _EditDiaryPageState extends State<EditDiaryPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  final formKey = GlobalKey<FormState>();
  List<String> selectedTopics = [];
  List<XFile> _images = [];
  final bool _isPickingImages = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.diary.title);
    contentController = TextEditingController(text: widget.diary.content);
    selectedTopics = List<String>.from(widget.diary.topics);
    _initializeImages();
  }

  Future<void> _initializeImages() async {
    final List<XFile> xFiles = [];
    for (var imageUrl in widget.diary.imageUrls) {
      final file = await _urlToFile(imageUrl);
      if (file != null) {
        xFiles.add(XFile(file.path));
      }
    }
    setState(() {
      _images = xFiles;
    });
  }

  Future<File?> _urlToFile(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/${basename(imageUrl)}')
          .writeAsBytes(bytes);
      return file;
    } catch (e) {
      return null;
    }
  }

  void updateDiary(BuildContext context) async {
    if (formKey.currentState?.validate() == true &&
        selectedTopics.isNotEmpty &&
        _images.isNotEmpty) {
      // 이미지 파일을 Supabase 스토리지에 저장
      final List<String> updatedImageUrls = await _uploadImagesToSupabase();

      final updatedDiary = widget.diary.copyWith(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        imageUrls: updatedImageUrls,
        topics: selectedTopics,
      );

      BlocProvider.of<DiaryBloc>(context).add(DiaryUpdate(diary: updatedDiary));
    }
  }

  Future<List<String>> _uploadImagesToSupabase() async {
    final List<String> updatedImageUrls = [];

    for (final image in _images) {
      final fileName = basename(image.path);
      final imageUrl = Supabase.instance.client.storage
          .from('diary_images')
          .getPublicUrl(fileName);

      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 404 || response.statusCode == 400) {
        // 이미지가 스토리지에 존재하지 않는 경우에만 업로드
        final bytes = await image.readAsBytes();
        final uploadResponse = await Supabase.instance.client.storage
            .from('diary_images')
            .uploadBinary(fileName, bytes);

        if (uploadResponse != null) {
          updatedImageUrls.add(imageUrl);
        }
      } else {
        // 이미지가 이미 스토리지에 존재하는 경우에는 URL만 추가
        updatedImageUrls.add(imageUrl);
      }
    }

    return updatedImageUrls;
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    contentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물 수정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              updateDiary(context);
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: BlocConsumer<DiaryBloc, DiaryState>(
        listener: (context, state) {
          if (state is DiaryFailure) {
            showSnackBar(context, state.error);
          } else if (state is DiaryUpdateSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              DiaryPage.route(),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is DiaryLoading) {
            return const Loader();
          }

          return Form(
            key: formKey,
            child: ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.width / 3,
                  width: MediaQuery.of(context).size.width / 3,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: InkWell(
                          onTap: () async {
                            if (_images.length < 9) {
                              final selectedImages =
                                  await Navigator.push<List<XFile>>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LastEdit(
                                    initialImages: _images,
                                    onImagesSelected: (selectedImages) {
                                      setState(() {
                                        _images = selectedImages;
                                      });
                                    },
                                  ),
                                ),
                              );
                              if (selectedImages != null) {
                                setState(() {
                                  _images = selectedImages;
                                });
                              }
                            } else {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('잠깐!'),
                                  content:
                                      const Text('이미지는 최대 9장까지 첨부할 수 있어요.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('확인'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey, width: 2),
                            ),
                            child: _isPickingImages
                                ? const Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: CircularProgressIndicator(),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.camera_alt_rounded,
                                          color: Colors.grey),
                                      Text('${_images.length}/9',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      ...List.generate(
                        _images.length,
                        (index) => Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 16, bottom: 16, right: 16),
                              child: ExtendedImage.file(
                                File(_images[index].path),
                                fit: BoxFit.cover,
                                height: MediaQuery.of(context).size.width / 3,
                                width: MediaQuery.of(context).size.width / 3,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(16),
                                loadStateChanged: (state) {
                                  switch (state.extendedImageLoadState) {
                                    case LoadState.loading:
                                      return Container(
                                        padding: EdgeInsets.all(
                                            MediaQuery.of(context).size.width /
                                                15),
                                        height:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        child:
                                            const CircularProgressIndicator(),
                                      );
                                    case LoadState.completed:
                                      return null;
                                    case LoadState.failed:
                                      return const Icon(Icons.cancel);
                                  }
                                },
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              width: 40,
                              height: 40,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  _images.removeAt(index);
                                  setState(() {});
                                },
                                icon: Icon(Icons.remove_circle,
                                    size: 30, color: Colors.red[300]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: Constants.topics
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: GestureDetector(
                              onTap: () {
                                if (selectedTopics.contains(e)) {
                                  selectedTopics.remove(e);
                                } else {
                                  selectedTopics.add(e);
                                }
                                setState(() {});
                              },
                              child: Chip(
                                label: Text(e),
                                color: selectedTopics.contains(e)
                                    ? const MaterialStatePropertyAll(
                                        AppPallete.gradient1,
                                      )
                                    : null,
                                side: selectedTopics.contains(e)
                                    ? null
                                    : const BorderSide(
                                        color: AppPallete.borderColor,
                                      ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const Divider(
                  height: 1,
                  color: Colors.grey,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '제목을 입력하세요.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: '제목(title)',
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: contentController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '내용을 입력하세요.';
                    }
                    return null;
                  },
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: '내용(content)',
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
