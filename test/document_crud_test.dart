import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_tai_lieu_hoc_tap/database/database.dart';
import 'package:quan_ly_tai_lieu_hoc_tap/database/document_dao.dart';
import 'package:quan_ly_tai_lieu_hoc_tap/struct/models.dart';

void main() {
  group('Kiểm thử Tầng Dữ Liệu (DAO) - Các thao tác CRUD & Tìm kiếm', () {
    late AppDatabase database;
    late DocumentDao dao;

    setUp(() {
      database = AppDatabase();
      dao = DocumentDao(database);
    });

    test('1. Lấy danh sách tài liệu ban đầu từ Seed Data', () async {
      final docs = await dao.getAllDocuments();
      expect(docs.isNotEmpty, true);
      expect(docs.length, greaterThanOrEqualTo(5));
    });

    test('2. Thêm mới tài liệu (Create / Insert)', () async {
      final newDoc = DocumentItem(
        documentPk: '',
        title: 'Giáo trình Kiến Trúc Phần Mềm Di Động Mới',
        note: 'Ghi chú kiến trúc Clean Architecture & Local-First',
        subjectFk: 'sub_mobile',
        documentTypeFk: 'type_book',
        fileUrl: 'software_architecture.pdf',
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final insertedId = await dao.insertDocument(newDoc);
      expect(insertedId.isNotEmpty, true);

      final retrieved = await dao.getDocumentById(insertedId);
      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Giáo trình Kiến Trúc Phần Mềm Di Động Mới');
      expect(retrieved.subjectFk, 'sub_mobile');
    });

    test('3. Chỉnh sửa tài liệu đã tồn tại (Update)', () async {
      final docId = 'doc_001';
      final existingDoc = await dao.getDocumentById(docId);
      expect(existingDoc, isNotNull);

      final updatedDoc = existingDoc!.copyWith(
        title: 'Slide Chương 3 - Cập nhật Cashew V2 & Drift',
        note: 'Nội dung đã được biên tập lại cho sinh viên K65',
      );

      final success = await dao.updateDocument(updatedDoc);
      expect(success, true);

      final verified = await dao.getDocumentById(docId);
      expect(verified!.title, 'Slide Chương 3 - Cập nhật Cashew V2 & Drift');
      expect(verified.note, 'Nội dung đã được biên tập lại cho sinh viên K65');
    });

    test('4. Đổi trạng thái Ghim yêu thích (Toggle Favorite)', () async {
      final docId = 'doc_003';
      final before = await dao.getDocumentById(docId);
      expect(before, isNotNull);
      final initialFavorite = before!.isFavorite;

      await dao.toggleFavorite(docId);

      final after = await dao.getDocumentById(docId);
      expect(after!.isFavorite, !initialFavorite);
    });

    test('5. Tìm kiếm tài liệu theo từ khóa (Search Keyword)', () async {
      // Tìm kiếm từ "Machine Learning"
      final stream = dao.watchFilteredDocuments(query: 'machine learning');
      final results = await stream.first;

      expect(results.isNotEmpty, true);
      expect(results.any((d) => d.title.toLowerCase().contains('machine learning')), true);
    });

    test('6. Lọc tài liệu theo Môn học (Subject Filter)', () async {
      // Lọc các tài liệu thuộc môn Cấu trúc dữ liệu ('sub_dsa')
      final stream = dao.watchFilteredDocuments(subjectId: 'sub_dsa');
      final results = await stream.first;

      expect(results.isNotEmpty, true);
      for (final doc in results) {
        expect(doc.subjectFk, 'sub_dsa');
      }
    });

    test('7. Xóa tài liệu khỏi bộ nhớ (Delete)', () async {
      final docId = 'doc_004';
      final existsBefore = await dao.getDocumentById(docId);
      expect(existsBefore, isNotNull);

      final success = await dao.deleteDocument(docId);
      expect(success, true);

      final existsAfter = await dao.getDocumentById(docId);
      expect(existsAfter, isNull);
    });

    test('8. Thêm môn học mới (Cá nhân hóa danh mục Môn học)', () async {
      final newSubject = SubjectItem(
        subjectPk: '',
        name: 'Kỹ Thuật Đồ Họa & Game',
        code: 'IT3090',
        colour: '0xFF8E24AA',
        iconName: 'memory',
        createdAt: DateTime.now(),
      );

      final subjectId = await dao.insertSubject(newSubject);
      expect(subjectId.isNotEmpty, true);

      final retrieved = await dao.getSubjectById(subjectId);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Kỹ Thuật Đồ Họa & Game');
      expect(retrieved.code, 'IT3090');
    });

    test('9. Chỉnh sửa môn học (Update Subject)', () async {
      final existing = await dao.getSubjectById('sub_mobile');
      expect(existing, isNotNull);

      final updated = existing!.copyWith(
        name: 'Lập trình Thiết bị Di động Nâng Cao',
        code: 'IT4441',
      );

      final success = await dao.updateSubject(updated);
      expect(success, true);

      final verified = await dao.getSubjectById('sub_mobile');
      expect(verified!.name, 'Lập trình Thiết bị Di động Nâng Cao');
      expect(verified.code, 'IT4441');
    });

    test('10. Xóa môn học và chuyển tài liệu sang môn khác (Reassign Data Integrity)', () async {
      // sub_network đang có doc_004 (hoặc tài liệu khác)
      final docsBefore = (await dao.getAllDocuments())
          .where((d) => d.subjectFk == 'sub_network')
          .toList();

      // Nếu không còn tài liệu ở sub_network thì thêm 1 tài liệu để test
      String testDocId = '';
      if (docsBefore.isEmpty) {
        testDocId = await dao.insertDocument(
          DocumentItem(
            documentPk: '',
            title: 'Tài liệu test mạng máy tính',
            note: '',
            subjectFk: 'sub_network',
            documentTypeFk: 'type_slide',
            fileUrl: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }

      // Xóa sub_network và chuyển toàn bộ tài liệu sang sub_mobile
      final success = await dao.deleteSubject('sub_network', reassignToSubjectPk: 'sub_mobile');
      expect(success, true);

      // Môn sub_network không còn tồn tại
      final deletedSubject = await dao.getSubjectById('sub_network');
      expect(deletedSubject, isNull);

      // Tài liệu cũ phải được chuyển sang sub_mobile
      if (testDocId.isNotEmpty) {
        final reassignedDoc = await dao.getDocumentById(testDocId);
        expect(reassignedDoc, isNotNull);
        expect(reassignedDoc!.subjectFk, 'sub_mobile');
      }
    });
  });
}
