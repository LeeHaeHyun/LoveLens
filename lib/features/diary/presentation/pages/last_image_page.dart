import 'dart:io';

import 'package:diary_app/features/diary/presentation/pages/add_new_diary_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class LastImage extends StatefulWidget {
  final List<XFile> initialImages;
  final Function(List<XFile>) onImagesSelected;

  LastImage({required this.initialImages, required this.onImagesSelected});

  @override
  _LastImageState createState() => _LastImageState();
}

class _LastImageState extends State<LastImage> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile?> _pickedImages = [];

// 사진촬영
  void getImage(ImageSource source) async {
    if (_pickedImages.length >= 9) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('잠깐!'),
          content: const Text('이미지 등록은 9개를 초과할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      final XFile? image =
          await _picker.pickImage(source: source, imageQuality: 95);

      if (image != null) {
        setState(() {
          _pickedImages.add(image);
        });
      }
    }
  }

  // 이미지 여러개 불러오기
  void getMultiImage() async {
    final List<XFile>? images = await _picker.pickMultiImage(imageQuality: 95);

    if (images != null) {
      int totalImages = _pickedImages.length + images.length;
      if (totalImages > 9) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('잠깐!'),
            content: const Text('이미지 등록은 9개를 초과할 수 없습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _pickedImages.addAll(images);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // AppBar 배경색을 검은색으로 설정
        elevation: 0, // AppBar 테두리 없애기
        centerTitle: true, // 제목을 가운데 정렬
        title: const Text(
          '이미지 등록', // AppBar 제목
          style: TextStyle(
            color: Colors.white, // 제목 글자색을 흰색으로 설정
            fontSize: 18, // 제목 글자 크기
            fontWeight: FontWeight.bold, // 제목 글자 굵기
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back, // 뒤로 가기 아이콘
            color: Colors.white, // 아이콘 색상
          ),
          onPressed: () {
            Navigator.pop(context); // 이전 화면으로 돌아가기
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1), // AppBar 하단에 구분선의 높이
          child: Container(
            height: 1, // 구분선의 높이
            color: Colors.grey[300], // 구분선 색상
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: [
              _imageLoadButtons(),
              const SizedBox(height: 20),
              _gridPhoto(),
            ],
          ),
        ),
      ),
    );
  }

  // 화면 상단 버튼
  Widget _imageLoadButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: ElevatedButton(
              onPressed: () => getImage(ImageSource.camera),
              child: const Text('사진촬영'),
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            child: ElevatedButton(
              onPressed: () {
                _handleRegistrationButton();
              },
              child: const Text('등록'),
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            child: ElevatedButton(
              onPressed: () => getMultiImage(),
              child: const Text('가져오기'),
            ),
          ),
        ],
      ),
    );
  }

  // 불러온 이미지 gridView
  Widget _gridPhoto() {
    return Expanded(
      child: _pickedImages.isNotEmpty
          ? GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              children: _pickedImages
                  .where((element) => element != null)
                  .map((e) => _gridPhotoItem(e!))
                  .toList(),
            )
          : const SizedBox(),
    );
  }

  Widget _gridPhotoItem(XFile e) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.file(
              File(e.path),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _pickedImages.remove(e);
                });
              },
              child: const Icon(
                Icons.cancel_rounded,
                color: Colors.black87,
              ),
            ),
          )
        ],
      ),
    );
  }

  // 등록버튼 눌렀을 때 처리
  void _handleRegistrationButton() {
    if (_pickedImages.isEmpty ||
        _pickedImages.any((element) => element == null)) {
      Navigator.pop(context);
    } else {
      // 선택한 이미지가 있는 경우
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddNewDiaryPage(
            images: _pickedImages.whereType<XFile>().toList(),
          ),
        ),
      ).then((_) {
        // AddNewDiaryPage에서 돌아왔을 때 실행할 코드
        _refreshAddNewDiaryPage();
      });
    }
  }

  // AddNewDiaryPage를 새로 고침하는 메서드
  void _refreshAddNewDiaryPage() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _pickedImages.addAll(widget.initialImages);
  }
}
