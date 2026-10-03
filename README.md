# Ứng Dụng Quản Lý Tài Liệu Học Tập (Study Document Manager)
### Kiến Trúc Tham Chiếu: Cashew Mobile Architecture (Local-First & Reactive Streams)

Ứng dụng Flutter quản lý tài liệu học tập (Bài giảng, Bài tập, Slide thuyết trình, Sách giáo trình, Đề thi cũ) dành cho sinh viên, được thiết kế theo đúng nguyên lý phân tách 3 lớp của kiến trúc **Cashew**.

---

## 🌟 Tính Năng Nổi Bật

- ⚡ **Local-First & Phản Hồi Tức Thì (< 30ms):** Dữ liệu lưu trữ và truy vấn trực tiếp trên thiết bị, hoạt động hoàn hảo khi không có mạng (Offline-Ready).
- 🔄 **Reactive Data Streams:** Giao diện tự động cập nhật thời gian thực khi dữ liệu thay đổi qua `StreamBuilder` mà không cần reload thủ công.
- 📚 **Quản Lý Toàn Diện 4 Chức Năng Cốt Lõi:** Thêm mới (Create), Chỉnh sửa (Update), Xóa an toàn (Delete), và Tìm kiếm tức thì (Search).
- 🏷️ **Phân Loại & Lọc Linh Hoạt:** Lọc theo Môn học (Subjects) và Loại tài liệu (DocumentTypes) với màu sắc nhận diện trực quan.
- ⭐ **Ghim Tài Liệu Yêu Thích:** Đánh dấu ưu tiên các tài liệu ôn thi quan trọng.
- 🌓 **Hỗ Trợ Giao Diện Sáng / Tối (Material 3 Theme):** Chuyển đổi linh hoạt Dark / Light mode.

---

## 🏗️ Cấu Trúc Thư Mục Chuẩn Cashew

```text
quan_ly_tai_lieu_hoc_tap/
├── lib/
│   ├── database/                    # [DATA LAYER - LOCAL STORAGE]
│   │   ├── tables.dart              # Đặc tả Schema các bảng dữ liệu
│   │   ├── database.dart            # Singleton AppDatabase & Mock Seed Data
│   │   └── document_dao.dart        # Data Access Object (CRUD & Reactive Streams)
│   ├── struct/                      # [STATE & BUSINESS LOGIC LAYER]
│   │   ├── models.dart              # Thực thể Domain (DocumentItem, SubjectItem, DocumentTypeItem)
│   │   ├── app_state.dart           # DocumentManagerNotifier (ChangeNotifier)
│   │   └── settings.dart            # Cài đặt Theme Sáng/Tối và View Mode
│   ├── widgets/                     # [REUSABLE PRESENTATION LAYER]
│   │   ├── document_card.dart       # Thẻ tài liệu hiển thị tag môn, loại tệp, sao yêu thích
│   │   ├── search_bar_widget.dart   # Thanh tìm kiếm thời gian thực
│   │   ├── subject_chip.dart        # Bộ lọc môn học dạng chip cuộn ngang
│   │   └── confirm_delete_dialog.dart # Hộp thoại xác nhận an toàn trước khi xóa
│   ├── pages/                       # [PRESENTATION SCREENS]
│   │   ├── home_page.dart           # Màn hình chính Dashboard & danh sách Stream
│   │   ├── add_edit_document_page.dart # Form Thêm / Sửa tài liệu có validation
│   │   └── document_detail_page.dart # Màn hình xem chi tiết tài liệu & tóm tắt
│   ├── colors.dart                  # Bảng màu chuẩn Material 3 theo môn học
│   └── main.dart                    # Điểm khởi chạy ứng dụng & liên kết hệ thống
├── test/                            # [AUTOMATED TESTING SUITE]
│   ├── document_crud_test.dart      # Kiểm thử chức năng CRUD & Tìm kiếm
│   ├── reactive_stream_test.dart    # Kiểm thử cơ chế tự phát sự kiện của Reactive Stream
│   └── architecture_separation_test.dart # Kiểm thử tính độc lập giữa Model, DAO và UI
├── SO_DO_KIEN_TRUC_LUONG_DU_LIEU.md # Tài liệu thiết kế ERD & Luồng dữ liệu (Checklist 1)
├── TAI_LIEU_PROMPT_THUC_HIEN.md    # Tài liệu hướng dẫn Prompt theo Checklist
└── BAO_CAO_GIAI_TRINH_KIEN_TRUC_CASHEW.md # Báo cáo giải trình học thuật nộp bài (Checklist 5)
```

---

## 🚀 Hướng Dẫn Chạy Ứng Dụng

### 1. Khởi chạy ứng dụng
```bash
cd quan_ly_tai_lieu_hoc_tap
flutter run
```

### 2. Chạy toàn bộ các bài kiểm thử tự động
```bash
flutter test
```
