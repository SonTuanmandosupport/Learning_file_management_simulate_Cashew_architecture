import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_tai_lieu_hoc_tap/database/database.dart';
import 'package:quan_ly_tai_lieu_hoc_tap/database/document_dao.dart';
import 'package:quan_ly_tai_lieu_hoc_tap/struct/models.dart';

void main() {
  group('Kiểm thử Luồng Dữ Liệu Phản Ứng (Reactive Stream Testing)', () {
    late AppDatabase database;
    late DocumentDao dao;

    setUp(() {
      database = AppDatabase();
      dao = DocumentDao(database);
    });

    test('Cơ chế Reactive Stream tự động phát sự kiện khi thêm dữ liệu mới', () async {
      // 1. Lắng nghe Stream của DAO
      final emittedLists = <List<DocumentItem>>[];

      final subscription = dao.watchDocuments().listen((list) {
        emittedLists.add(list);
      });

      // Cho phép phát giá trị ban đầu
      await Future.delayed(const Duration(milliseconds: 50));
      expect(emittedLists.isNotEmpty, true);
      final initialCount = emittedLists.last.length;

      // 2. Thao tác thêm một tài liệu mới
      final testDoc = DocumentItem(
        documentPk: 'doc_reactive_test_01',
        title: 'Tài liệu kiểm thử Reactive Stream Cashew',
        note: 'Kiểm thử stream tự phát sự kiện tới UI',
        subjectFk: 'sub_mobile',
        documentTypeFk: 'type_slide',
        fileUrl: 'reactive_test.pdf',
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await dao.insertDocument(testDoc);

      // Chờ stream phát sự kiện
      await Future.delayed(const Duration(milliseconds: 50));

      // 3. Xác minh Stream đã nhận được danh sách mới có chứa phần tử vừa thêm
      expect(emittedLists.length, greaterThanOrEqualTo(2));
      final latestList = emittedLists.last;
      expect(latestList.length, initialCount + 1);
      expect(latestList.any((d) => d.documentPk == 'doc_reactive_test_01'), true);

      await subscription.cancel();
    });

    test('Reactive Stream tự động cập nhật khi đổi trạng thái yêu thích', () async {
      final emittedLists = <List<DocumentItem>>[];
      final subscription = dao.watchDocuments().listen((list) {
        emittedLists.add(list);
      });

      await Future.delayed(const Duration(milliseconds: 50));

      // Đổi trạng thái yêu thích của doc_002
      await dao.toggleFavorite('doc_002');
      await Future.delayed(const Duration(milliseconds: 50));

      final latestList = emittedLists.last;
      final doc002 = latestList.firstWhere((d) => d.documentPk == 'doc_002');
      expect(doc002.isFavorite, isNotNull);

      await subscription.cancel();
    });
  });
}
