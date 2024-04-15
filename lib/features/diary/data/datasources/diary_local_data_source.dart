import 'package:diary_app/features/diary/data/models/diary_model.dart';
import 'package:hive/hive.dart';

abstract interface class DiaryLocalDataSource {
  void uploadLocaldiarys({required List<DiaryModel> diarys});
  List<DiaryModel> loaddiarys();
}

class DiaryLocalDataSourceImpl implements DiaryLocalDataSource {
  final Box box;
  DiaryLocalDataSourceImpl(this.box);

  @override
  List<DiaryModel> loaddiarys() {
    List<DiaryModel> diarys = [];
    box.read(() {
      for (int i = 0; i < box.length; i++) {
        diarys.add(DiaryModel.fromJson(box.get(i.toString())));
      }
    });

    return diarys;
  }

  @override
  void uploadLocaldiarys({required List<DiaryModel> diarys}) {
    box.clear();

    box.write(() {
      for (int i = 0; i < diarys.length; i++) {
        box.put(i.toString(), diarys[i].toJson());
      }
    });
  }
}
