import 'dart:async';
import '../struct/models.dart';
import 'database.dart';

/// Data Access Object (DAO) xử lý toàn bộ truy vấn dữ liệu tài liệu học tập
/// Tương tự các DAO của Drift trong kiến trúc Cashew.
class DocumentDao {
  final AppDatabase _db;

  DocumentDao([AppDatabase? db]) : _db = db ?? AppDatabase();

  // -------------------------------------------------------------
  // TRUY VẤN MÔN HỌC & LOẠI TÀI LIỆU (SUBJECTS & DOCUMENT TYPES)
  // -------------------------------------------------------------

  /// Lấy toàn bộ danh sách Môn học
  Future<List<SubjectItem>> getAllSubjects() async {
    return _db.rawSubjects.values.toList();
  }

  /// Tìm môn học theo ID
  Future<SubjectItem?> getSubjectById(String id) async {
    return _db.rawSubjects[id];
  }

  /// Thêm môn học mới (Tương tự tạo Wallet mới trong Cashew)
  Future<String> insertSubject(SubjectItem subject) async {
    final String pk = subject.subjectPk.isNotEmpty
        ? subject.subjectPk
        : 'sub_${DateTime.now().millisecondsSinceEpoch}';

    final newSubject = subject.copyWith(
      subjectPk: pk,
      createdAt: DateTime.now(),
    );

    _db.rawSubjects[pk] = newSubject;
    return pk;
  }

  /// Cập nhật thông tin môn học (Tên, mã môn, màu sắc, icon)
  Future<bool> updateSubject(SubjectItem subject) async {
    if (!_db.rawSubjects.containsKey(subject.subjectPk)) {
      return false;
    }
    _db.rawSubjects[subject.subjectPk] = subject;
    _db.notifyDataChanged();
    return true;
  }

  /// Đếm số lượng tài liệu thuộc về môn học
  int getDocumentCountBySubject(String subjectPk) {
    return _db.rawDocuments.values.where((d) => d.subjectFk == subjectPk).length;
  }

  /// Xóa môn học và xử lý tính toàn vẹn dữ liệu (Data Integrity)
  /// Nếu reassignToSubjectPk != null: Chuyển toàn bộ tài liệu sang môn học mới trước khi xóa môn cũ.
  Future<bool> deleteSubject(String subjectPk, {String? reassignToSubjectPk}) async {
    if (!_db.rawSubjects.containsKey(subjectPk)) {
      return false;
    }

    // 1. Chuyển tài liệu sang môn khác nếu được chỉ định
    if (reassignToSubjectPk != null && reassignToSubjectPk.isNotEmpty) {
      final documentsToReassign = _db.rawDocuments.values
          .where((doc) => doc.subjectFk == subjectPk)
          .toList();

      for (final doc in documentsToReassign) {
        _db.rawDocuments[doc.documentPk] = doc.copyWith(
          subjectFk: reassignToSubjectPk,
          updatedAt: DateTime.now(),
        );
      }
    }

    // 2. Xóa môn học khỏi cơ sở dữ liệu
    _db.rawSubjects.remove(subjectPk);
    _db.notifyDataChanged();
    return true;
  }

  /// Lấy toàn bộ danh sách Loại tài liệu
  Future<List<DocumentTypeItem>> getAllDocumentTypes() async {
    return _db.rawDocumentTypes.values.toList();
  }

  /// Tìm loại tài liệu theo ID
  Future<DocumentTypeItem?> getDocumentTypeById(String id) async {
    return _db.rawDocumentTypes[id];
  }

  // -------------------------------------------------------------
  // CÁC THAO TÁC CRUD TRÊN TÀI LIỆU HỌC TẬP (DOCUMENTS CRUD)
  // -------------------------------------------------------------

  /// Lấy danh sách toàn bộ tài liệu (Snapshot)
  Future<List<DocumentItem>> getAllDocuments() async {
    final list = _db.rawDocuments.values.toList()
      ..sort((a, b) {
        if (a.isFavorite != b.isFavorite) {
          return a.isFavorite ? -1 : 1;
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });
    return list;
  }

  /// Lấy chi tiết tài liệu theo ID
  Future<DocumentItem?> getDocumentById(String documentPk) async {
    return _db.rawDocuments[documentPk];
  }

  /// Thêm tài liệu mới (Insert)
  Future<String> insertDocument(DocumentItem document) async {
    final String pk = document.documentPk.isNotEmpty
        ? document.documentPk
        : 'doc_${DateTime.now().millisecondsSinceEpoch}';

    final newDoc = document.copyWith(
      documentPk: pk,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _db.rawDocuments[pk] = newDoc;
    _db.notifyDataChanged();
    return pk;
  }

  /// Chỉnh sửa tài liệu đã có (Update)
  Future<bool> updateDocument(DocumentItem document) async {
    if (!_db.rawDocuments.containsKey(document.documentPk)) {
      return false;
    }

    final updatedDoc = document.copyWith(
      updatedAt: DateTime.now(),
    );

    _db.rawDocuments[document.documentPk] = updatedDoc;
    _db.notifyDataChanged();
    return true;
  }

  /// Xóa tài liệu theo ID (Delete)
  Future<bool> deleteDocument(String documentPk) async {
    if (!_db.rawDocuments.containsKey(documentPk)) {
      return false;
    }

    _db.rawDocuments.remove(documentPk);
    _db.notifyDataChanged();
    return true;
  }

  /// Đổi nhanh trạng thái yêu thích (Toggle Favorite)
  Future<bool> toggleFavorite(String documentPk) async {
    final doc = _db.rawDocuments[documentPk];
    if (doc == null) return false;

    final updated = doc.copyWith(isFavorite: !doc.isFavorite);
    _db.rawDocuments[documentPk] = updated;
    _db.notifyDataChanged();
    return true;
  }

  // -------------------------------------------------------------
  // LUỒNG DỮ LIỆU PHẢN ỨNG THỜI GIAN THỰC (REACTIVE STREAMS)
  // -------------------------------------------------------------

  /// Lắng nghe Stream danh sách tài liệu toàn cục
  Stream<List<DocumentItem>> watchDocuments() async* {
    // Phát ngay lập tức giá trị hiện có ban đầu
    yield await getAllDocuments();
    // Sau đó phát tiếp mỗi khi có sự kiện thay đổi
    yield* _db.documentsStream;
  }

  /// Lắng nghe Stream danh sách tài liệu có áp dụng bộ lọc (Tìm kiếm & Phân loại)
  Stream<List<DocumentItem>> watchFilteredDocuments({
    String? query,
    String? subjectId,
    String? typeId,
    bool? favoriteOnly,
  }) async* {
    // Hàm phụ trợ lọc dữ liệu
    List<DocumentItem> applyFilter(List<DocumentItem> source) {
      return source.where((doc) {
        // Lọc theo từ khóa tìm kiếm (tiêu đề hoặc ghi chú)
        if (query != null && query.trim().isNotEmpty) {
          final q = query.trim().toLowerCase();
          final matchTitle = doc.title.toLowerCase().contains(q);
          final matchNote = doc.note.toLowerCase().contains(q);
          if (!matchTitle && !matchNote) return false;
        }

        // Lọc theo môn học
        if (subjectId != null && subjectId.isNotEmpty && subjectId != 'all') {
          if (doc.subjectFk != subjectId) return false;
        }

        // Lọc theo loại tài liệu
        if (typeId != null && typeId.isNotEmpty && typeId != 'all') {
          if (doc.documentTypeFk != typeId) return false;
        }

        // Lọc chỉ tài liệu yêu thích
        if (favoriteOnly == true) {
          if (!doc.isFavorite) return false;
        }

        return true;
      }).toList();
    }

    // Giá trị ban đầu
    final initialList = await getAllDocuments();
    yield applyFilter(initialList);

    // Lắng nghe tiếp diễn
    await for (final list in _db.documentsStream) {
      yield applyFilter(list);
    }
  }
}
