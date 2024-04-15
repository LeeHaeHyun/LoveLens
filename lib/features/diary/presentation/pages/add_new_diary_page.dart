import 'dart:io';
import 'dart:typed_data';

import 'package:diary_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:diary_app/core/common/widgets/loader.dart';
import 'package:diary_app/core/constants/constants.dart';
import 'package:diary_app/core/theme/app_pallete.dart';
import 'package:diary_app/core/utils/pick_image.dart';
import 'package:diary_app/core/utils/show_snackbar.dart';
import 'package:diary_app/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:diary_app/features/diary/presentation/pages/diary_page.dart';
import 'package:diary_app/features/diary/presentation/pages/last_image_page.dart';
import 'package:diary_app/features/diary/presentation/widgets/diary_editor.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:diary_app/features/diary/data/models/diary_model.dart';

class AddNewDiaryPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const AddNewDiaryPage(
          images: [],
        ),
      );
  const AddNewDiaryPage({Key? key, required this.images}) : super(key: key);

  final List<XFile> images;

  @override
  State<AddNewDiaryPage> createState() => _AddNewDiaryPageState();
}

class _AddNewDiaryPageState extends State<AddNewDiaryPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> selectedTopics = [];
  List<Uint8List> _images = [];
  final bool _isPickingImages = false;

  void uploadDiary() {
    if (formKey.currentState?.validate() == true &&
        selectedTopics.isNotEmpty &&
        _images.isNotEmpty) {
      // widget.images 대신 _images 사용
      final posterId =
          (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
      context.read<DiaryBloc>().add(
            DiaryUpload(
              diary: DiaryModel.create(
                posterId: posterId,
                title: titleController.text.trim(),
                content: contentController.text.trim(),
                topics: selectedTopics,
              ),
              posterId: posterId,
              title: titleController.text.trim(),
              content: contentController.text.trim(),
              images: widget.images
                  .map((image) => File(image.path))
                  .toList(), // _images 사용
              topics: selectedTopics,
            ),
          );
    }
  }

  @override
  void initState() {
    super.initState();
    _images.clear();
    widget.images.forEach(
      (xfile) async {
        _images.add(await xfile.readAsBytes());
        setState(() {});
      },
    );
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
        title: const Text('게시물 작성'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DiaryPage()),
              (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              uploadDiary();
            },
            icon: const Icon(Icons.done_rounded),
          ),
        ],
      ),
      body: BlocConsumer<DiaryBloc, DiaryState>(
        listener: (context, state) {
          if (state is DiaryFailure) {
            showSnackBar(context, state.error);
          } else if (state is DiaryUploadSuccess) {
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LastImage(
                                          initialImages: _images
                                              .map((image) =>
                                                  XFile.fromData(image))
                                              .toList(),
                                          onImagesSelected:
                                              (selectedImages) async {
                                            setState(() async {
                                              _images = await Future.wait(
                                                selectedImages.map((image) =>
                                                    image.readAsBytes()),
                                              );
                                            });
                                          },
                                        )),
                              );
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
                              child: ExtendedImage.memory(
                                _images[index],
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
                                              MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  15),
                                          height:
                                              MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3,
                                          child:
                                              const CircularProgressIndicator());

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
                                  widget.images.removeAt(index);
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
                DiaryEditor(
                  controller: titleController,
                  hintText: '제목(title)',
                ),
                const SizedBox(height: 10),
                DiaryEditor(
                  controller: contentController,
                  hintText: '내용(content)',
                ),
                SizedBox(
                  child: ElevatedButton(
                    onPressed: () {
                      print(_images.length);
                      print(selectedTopics.length);
                      print(titleController);
                      print(contentController);
                      print(formKey.currentState);
                      setState(() {});
                    },
                    child: const Text('가져오기'),
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
