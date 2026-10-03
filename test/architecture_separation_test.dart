import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_tai_lieu_hoc_tap/database/database.dart';
import 'package:quan_ly_tai_lieu_hoc_tap/database/document_dao.dart';
import 'package:quan_ly_tai_lieu_hoc_tap/struct/app_state.dart';
import 'package:quan_ly_tai_lieu_hoc_tap/struct/models.dart';

void main() {
  group('Kiểm thử Tính Phân Tách Kiến Trúc (Architecture Separation & Decoupling)', () {
    test('1. Tầng Model hoàn toàn thuần túy (Pure Data Class, không phụ thuộc UI Context)', () {
      final now = DateTime.now();
      final doc = DocumentItem(
        documentPk: 'doc_arch_01',
        title: 'Thực thể thuần túy',
        note: 'Không chứa bất kỳ ràng buộc nào với Flutter Widget',
        subjectFk: 'sub_mobile',
        documentTypeFk: 'type_slide',
        fileUrl: '',
        createdAt: now,
        updatedAt: now,
      );

      final map = doc.toMap();
      expect(map['title'], 'Thực thể thuần túy');
      final recreated = DocumentItem.fromMap(map);
      expect(recreated.title, doc.title);
      expect(recreated.documentPk, doc.documentPk);
    });

    test('2. Tầng DAO & Database độc lập hoàn toàn với BuildContext', () async {
      // Có thể chạy trực tiếp DAO trong môi trường test mà không cần khởi tạo widget hay MaterialApp
      final db = AppDatabase();
      final dao = DocumentDao(db);

      final subjects = await dao.getAllSubjects();
      final types = await dao.getAllDocumentTypes();

      expect(subjects.isNotEmpty, true);
      expect(types.isNotEmpty, true);
    });

    test('3. Tầng State Management (Notifier) quản lý nghiệp vụ không cần giả lập màn hình UI', () async {
      final db = AppDatabase();
      final dao = DocumentDao(db);
      final notifier = DocumentManagerNotifier(dao);

      // Kiểm thử hành vi tìm kiếm tại tầng State
      notifier.setSearchQuery('Kiến Trúc');
      expect(notifier.searchQuery, 'Kiến Trúc');

      // Kiểm thử hành vi lọc môn học tại tầng State
      notifier.setSelectedSubject('sub_mobile');
      expect(notifier.selectedSubjectId, 'sub_mobile');

      // Kiểm thử hành vi Reset bộ lọc
      notifier.resetFilters();
      expect(notifier.searchQuery, '');
      expect(notifier.selectedSubjectId, 'all');

      notifier.dispose();
    });
  });
}
