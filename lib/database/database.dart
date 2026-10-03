import 'dart:async';
import '../struct/models.dart';

/// Database trung tâm quản lý dữ liệu cục bộ (Local-First Database)
/// Triển khai theo mẫu Cashew Drift Database & Reactive Streams.
class AppDatabase {
  // Singleton pattern
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;

  AppDatabase._internal() {
    _initSeedData();
  }

  // Bộ lưu trữ dữ liệu cục bộ trong bộ nhớ (In-Memory Local Storage)
  final Map<String, SubjectItem> _subjects = {};
  final Map<String, DocumentTypeItem> _documentTypes = {};
  final Map<String, DocumentItem> _documents = {};

  // StreamController để phát sự kiện thay đổi dữ liệu theo thời gian thực (Reactive Stream)
  final StreamController<List<DocumentItem>> _documentsStreamController =
      StreamController<List<DocumentItem>>.broadcast();

  Stream<List<DocumentItem>> get documentsStream =>
      _documentsStreamController.stream;

  /// Phát tín hiệu cập nhật danh sách tài liệu mới nhất đến toàn bộ người nghe (Subscribers)
  void notifyDataChanged() {
    final list = _documents.values.toList()
      ..sort((a, b) {
        // Tài liệu yêu thích ưu tiên lên đầu, sau đó sắp xếp theo thời gian mới nhất
        if (a.isFavorite != b.isFavorite) {
          return a.isFavorite ? -1 : 1;
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });
    _documentsStreamController.add(list);
  }

  /// Khởi tạo dữ liệu mẫu ban đầu (Mock Seed Data)
  void _initSeedData() {
    // 1. Khởi tạo danh sách Môn học (Subjects)
    final subjectsSeed = [
      SubjectItem(
        subjectPk: 'sub_mobile',
        name: 'Lập trình Thiết bị Di động',
        code: 'IT4440',
        colour: '0xFF1E88E5', // Blue
        iconName: 'phone_android',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      SubjectItem(
        subjectPk: 'sub_dsa',
        name: 'Cấu trúc Dữ liệu & Giải thuật',
        code: 'IT3011',
        colour: '0xFF8E24AA', // Purple
        iconName: 'code',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      SubjectItem(
        subjectPk: 'sub_network',
        name: 'Mạng Máy Tính & Truyền thông',
        code: 'IT3080',
        colour: '0xFF00897B', // Teal
        iconName: 'hub',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      SubjectItem(
        subjectPk: 'sub_ai',
        name: 'Nhập môn Trí Tuệ Nhân Tạo',
        code: 'IT4040',
        colour: '0xFFFB8C00', // Orange
        iconName: 'psychology',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    for (final s in subjectsSeed) {
      _subjects[s.subjectPk] = s;
    }

    // 2. Khởi tạo danh sách Loại tài liệu (DocumentTypes)
    final typesSeed = [
      const DocumentTypeItem(
        typePk: 'type_slide',
        name: 'Bài Giảng / Slide',
        colour: '0xFFFB8C00',
        iconName: 'slideshow',
      ),
      const DocumentTypeItem(
        typePk: 'type_lab',
        name: 'Bài Tập / Thực Hành',
        colour: '0xFF1E88E5',
        iconName: 'assignment',
      ),
      const DocumentTypeItem(
        typePk: 'type_book',
        name: 'Sách / Tài Liệu Tham Khảo',
        colour: '0xFF8E24AA',
        iconName: 'menu_book',
      ),
      const DocumentTypeItem(
        typePk: 'type_exam',
        name: 'Đề Thi & Ôn Tập',
        colour: '0xFFE53935',
        iconName: 'quiz',
      ),
    ];

    for (final t in typesSeed) {
      _documentTypes[t.typePk] = t;
    }

    // 3. Khởi tạo danh sách Tài liệu học tập ban đầu (Documents)
    final now = DateTime.now();
    final documentsSeed = [
      DocumentItem(
        documentPk: 'doc_001',
        title: 'Slide Chương 3 - Kiến Trúc Cashew & Drift ORM',
        note: 'Ôn tập mô hình Local-First, tách lớp Data/State/UI và các Stream phản ứng thời gian thực.',
        subjectFk: 'sub_mobile',
        documentTypeFk: 'type_slide',
        fileUrl: 'slide_chuong_3_cashew.pdf',
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      DocumentItem(
        documentPk: 'doc_002',
        title: 'Lab 04 - Xây dựng Ứng Dụng Flutter Đa Nền Tảng',
        note: 'Yêu cầu: Viết ứng dụng quản lý tài liệu học tập, viết Unit Test kiểm thử DAO.',
        subjectFk: 'sub_mobile',
        documentTypeFk: 'type_lab',
        fileUrl: 'de_bai_lab_04_flutter.docx',
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
      DocumentItem(
        documentPk: 'doc_003',
        title: 'Cây Nhị Phân & Cây AVL Toàn Tập',
        note: 'Lý thuyết cân bằng cây, các thao tác quay trái quay phải, độ phức tạp O(log N).',
        subjectFk: 'sub_dsa',
        documentTypeFk: 'type_book',
        fileUrl: 'giao_trinh_dsa_full.pdf',
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      DocumentItem(
        documentPk: 'doc_004',
        title: 'Bộ Đề Thi Cuối Kỳ Mạng Máy Tính K65',
        note: 'Gồm 40 câu hỏi trắc nghiệm mô hình OSI, TCP/IP, thuật toán định tuyến Dijkstra.',
        subjectFk: 'sub_network',
        documentTypeFk: 'type_exam',
        fileUrl: 'de_thi_mmt_k65.pdf',
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      DocumentItem(
        documentPk: 'doc_005',
        title: 'Bài Giảng Machine Learning Cơ Bản',
        note: 'Hồi quy tuyến tính, Logistic Regression, Gradient Descent và phương pháp tối ưu hóa.',
        subjectFk: 'sub_ai',
        documentTypeFk: 'type_slide',
        fileUrl: 'ml_intro_lecture_01.pptx',
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ];

    for (final doc in documentsSeed) {
      _documents[doc.documentPk] = doc;
    }
  }

  // Getters truy xuất dữ liệu thô nội bộ
  Map<String, SubjectItem> get rawSubjects => _subjects;
  Map<String, DocumentTypeItem> get rawDocumentTypes => _documentTypes;
  Map<String, DocumentItem> get rawDocuments => _documents;
}
