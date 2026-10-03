import 'package:flutter/material.dart';
import '../database/document_dao.dart';
import 'models.dart';

/// Quản lý trạng thái và luồng nghiệp vụ trung tâm cho ứng dụng
/// Tuân thủ Provider / ChangeNotifier pattern như Cashew State Management.
class DocumentManagerNotifier extends ChangeNotifier {
  final DocumentDao _dao;
  bool _disposed = false;

  DocumentManagerNotifier([DocumentDao? dao]) : _dao = dao ?? DocumentDao() {
    _loadInitialMetadata();
  }

  // Danh mục Môn học & Loại tài liệu được nạp vào cache
  List<SubjectItem> _subjects = [];
  List<DocumentTypeItem> _documentTypes = [];

  // Trạng thái tìm kiếm & bộ lọc
  String _searchQuery = '';
  String _selectedSubjectId = 'all';
  String _selectedTypeId = 'all';
  bool _favoriteOnly = false;

  // Getters
  DocumentDao get dao => _dao;
  List<SubjectItem> get subjects => _subjects;
  List<DocumentTypeItem> get documentTypes => _documentTypes;
  String get searchQuery => _searchQuery;
  String get selectedSubjectId => _selectedSubjectId;
  String get selectedTypeId => _selectedTypeId;
  bool get favoriteOnly => _favoriteOnly;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  /// Nạp danh sách Môn học và Loại tài liệu ban đầu
  Future<void> _loadInitialMetadata() async {
    _subjects = await _dao.getAllSubjects();
    _documentTypes = await _dao.getAllDocumentTypes();
    notifyListeners();
  }

  /// Cập nhật từ khóa tìm kiếm
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Cập nhật bộ lọc môn học
  void setSelectedSubject(String subjectId) {
    _selectedSubjectId = subjectId;
    notifyListeners();
  }

  /// Cập nhật bộ lọc loại tài liệu
  void setSelectedType(String typeId) {
    _selectedTypeId = typeId;
    notifyListeners();
  }

  /// Bật/tắt chỉ xem tài liệu yêu thích
  void toggleFavoriteFilter() {
    _favoriteOnly = !_favoriteOnly;
    notifyListeners();
  }

  /// Xóa toàn bộ bộ lọc
  void resetFilters() {
    _searchQuery = '';
    _selectedSubjectId = 'all';
    _selectedTypeId = 'all';
    _favoriteOnly = false;
    notifyListeners();
  }

  // -------------------------------------------------------------
  // CÁC HÀNH VI NGHIỆP VỤ (BUSINESS ACTIONS)
  // -------------------------------------------------------------

  /// Thêm môn học mới và tự động cập nhật danh sách
  Future<String> addSubject(SubjectItem subject) async {
    final pk = await _dao.insertSubject(subject);
    _subjects = await _dao.getAllSubjects();
    notifyListeners();
    return pk;
  }

  /// Cập nhật thông tin môn học
  Future<bool> updateSubject(SubjectItem subject) async {
    final success = await _dao.updateSubject(subject);
    if (success) {
      _subjects = await _dao.getAllSubjects();
      notifyListeners();
    }
    return success;
  }

  /// Xóa môn học (kèm tùy chọn chuyển tài liệu sang môn học khác)
  Future<bool> deleteSubject(String subjectPk, {String? reassignToSubjectPk}) async {
    // Không cho xóa nếu chỉ còn 1 môn học duy nhất
    if (_subjects.length <= 1) {
      return false;
    }

    final success = await _dao.deleteSubject(
      subjectPk,
      reassignToSubjectPk: reassignToSubjectPk,
    );

    if (success) {
      _subjects = await _dao.getAllSubjects();
      if (_selectedSubjectId == subjectPk) {
        _selectedSubjectId = 'all';
      }
      notifyListeners();
    }
    return success;
  }

  /// Lấy số lượng tài liệu thuộc môn học
  int getDocumentCountForSubject(String subjectPk) {
    return _dao.getDocumentCountBySubject(subjectPk);
  }

  /// Lưu tài liệu (Tự động phân biệt Thêm mới hoặc Cập nhật)
  Future<bool> saveDocument(DocumentItem document) async {
    try {
      if (document.documentPk.isEmpty) {
        await _dao.insertDocument(document);
      } else {
        final existing = await _dao.getDocumentById(document.documentPk);
        if (existing == null) {
          await _dao.insertDocument(document);
        } else {
          await _dao.updateDocument(document);
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Xóa tài liệu
  Future<bool> deleteDocument(String documentPk) async {
    return await _dao.deleteDocument(documentPk);
  }

  /// Bật/tắt ghim yêu thích
  Future<bool> toggleFavorite(String documentPk) async {
    return await _dao.toggleFavorite(documentPk);
  }

  /// Luồng Stream tài liệu lọc theo trạng thái hiện tại
  Stream<List<DocumentItem>> get currentFilteredStream {
    return _dao.watchFilteredDocuments(
      query: _searchQuery,
      subjectId: _selectedSubjectId,
      typeId: _selectedTypeId,
      favoriteOnly: _favoriteOnly,
    );
  }

  /// Tìm môn học theo ID từ cache
  SubjectItem? getSubject(String id) {
    try {
      return _subjects.firstWhere((s) => s.subjectPk == id);
    } catch (_) {
      return null;
    }
  }

  /// Tìm loại tài liệu theo ID từ cache
  DocumentTypeItem? getDocumentType(String id) {
    try {
      return _documentTypes.firstWhere((t) => t.typePk == id);
    } catch (_) {
      return null;
    }
  }
}
