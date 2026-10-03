# BỘ TÀI LIỆU PROMPT THIẾT KẾ & TRIỂN KHAI DỰ ÁN
## ỨNG DỤNG QUẢN LÝ TÀI LIỆU HỌC TẬP THEO KIẾN TRÚC CASHEW

---

## 1. TỔNG QUAN KIẾN TRÚC & MAPPING DỰ ÁN

Hệ thống được thiết kế theo đúng kiến trúc **Local-First & Reactive Data Stream** của ứng dụng **Cashew** (tham khảo từ [`NGHIEN_CUU_KIEN_TRUC_CASHEW.md`](file:///e:/Mobile%20Dev/cashew_app_demo/NGHIEN_CUU_KIEN_TRUC_CASHEW.md)).

### 1.1. Bảng Đối Chiếu Thành Phần (Cashew vs. Study Document Manager)

| Thành phần Cashew Finance | Thành phần Quản Lý Tài Liệu Học Tập | Ý nghĩa & Trách nhiệm kiến trúc |
| :--- | :--- | :--- |
| **`Transactions`** (Giao dịch) | **`Documents`** (Tài liệu học tập) | Thực thể cốt lõi (Tiêu đề, Mô tả, Loại file/Đường dẫn, Môn học, Ngày tạo, Đánh dấu sao). |
| **`Wallets`** (Ví tiền / Tài khoản) | **`Subjects / Courses`** (Môn học / Khóa học) | Đơn vị gom nhóm chính (Toán, Lập trình, Triết học, v.v.). |
| **`Categories`** (Danh mục chi tiêu) | **`DocumentTypes / Tags`** (Loại tài liệu: Bài giảng, Bài tập, Slide, Sách tham khảo) | Nhãn phân loại và định dạng dữ liệu có mã màu & icon riêng biệt. |
| **`Drift DAO / Reactive Stream`** | **`DocumentDatabase & DAOs`** | Tầng lưu trữ cục bộ, phát sự kiện Stream khi dữ liệu thay đổi để UI tự cập nhật dưới 50ms. |
| **`struct/settings.dart`** | **`struct/appSettings.dart`** | Quản lý cấu hình (Dark mode, Sắp xếp mặc định, Chế độ xem Lưới/Danh sách). |
| **`widgets/navigationFramework.dart`** | **`widgets/navigationFramework.dart`** | Quản lý điều hướng BottomBar / Responsive SideBar. |

---

### 1.2. Cấu Trúc Thư Mục Chuẩn Cashew Phân Tách Lớp

```text
quan_ly_tai_lieu_hoc_tap/
├── lib/
│   ├── database/                    # [DATA LAYER - LOCAL STORAGE]
│   │   ├── tables.dart              # Định nghĩa Schema: Documents, Subjects, DocumentTypes
│   │   ├── database.dart            # Khởi tạo DB, Migration & Reactive Stream
│   │   └── document_dao.dart        # Data Access Object xử lý CRUD & Search
│   ├── struct/                      # [STATE & BUSINESS LOGIC LAYER]
│   │   ├── models.dart              # Thực thể Domain (Document, Subject, DocumentType)
│   │   ├── app_state.dart           # Quản lý trạng thái bằng ChangeNotifier / StreamProvider
│   │   └── settings.dart            # Cài đặt người dùng (Theme, Layout, Sắp xếp)
│   ├── widgets/                     # [REUSABLE PRESENTATION LAYER]
│   │   ├── document_card.dart       # Thẻ hiển thị tài liệu
│   │   ├── search_bar_widget.dart   # Thanh tìm kiếm thời gian thực
│   │   ├── category_chip.dart       # Chip lọc danh mục/môn học có màu sắc
│   │   └── confirm_delete_dialog.dart # Hộp thoại xác nhận an toàn
│   ├── pages/                       # [SCREENS / PAGES]
│   │   ├── home_page.dart           # Trang chủ: Thống kê nhanh, tài liệu gần đây, danh sách môn
│   │   ├── add_edit_document_page.dart # Màn hình thêm/sửa tài liệu
│   │   ├── search_page.dart         # Màn hình tìm kiếm nâng cao & bộ lọc
│   │   └── document_detail_page.dart # Xem chi tiết, ghi chú bài giảng & mở tệp
│   ├── colors.dart                  # Bảng màu Material 3, phân loại màu môn học
│   └── main.dart                    # Điểm khởi chạy ứng dụng & Dependency Injection
└── test/                            # [TESTING LAYER]
    ├── database_test.dart           # Kiểm thử CRUD & Search độc lập tại DAO
    └── logic_separation_test.dart   # Kiểm thử việc UI không gọi trực tiếp SQL/DB
```

---

## 2. BỘ PROMPT THỰC THI THEO 5 MỤC CHECKLIST

Bạn có thể sao chép lần lượt từng Prompt dưới đây vào chat để AI thực hiện tuần tự từng mục, hoặc sử dụng **Master Prompt** ở phần 3 để triển khai trọn gói.

---

### 📌 PROMPT 1: Checklist 1 - Phân Tích Chức Năng & Sơ Đồ Luồng Dữ Liệu
> **Mục tiêu:** Tạo tài liệu phân tích nghiệp vụ, ERD và sơ đồ luồng dữ liệu (Data Flow Diagram / Sequence Diagram) theo mô hình Local-First của Cashew.

```markdown
Hãy đóng vai trò Kiến trúc sư phần mềm di động (Mobile System Architect).
Dựa trên kiến trúc của ứng dụng Cashew (Local-First, Reactive Data Stream) và yêu cầu xây dựng ứng dụng "Quản lý tài liệu học tập" (lưu trữ bài giảng, bài tập, tài liệu tham khảo), hãy:

1. Phân tích chi tiết yêu cầu chức năng (Thêm, Sửa, Xóa, Tìm kiếm, Phân loại môn học, Đánh dấu yêu thích).
2. Thiết kế lược đồ thực thể (Entity Relationship Diagram - ERD) gồm 3 bảng:
   - `Documents` (documentPk, title, note, documentTypeFk, subjectFk, fileUrl, isFavorite, createdAt, updatedAt)
   - `Subjects` (subjectPk, name, code, colour, iconName)
   - `DocumentTypes` (typePk, name, colour, iconName)
3. Vẽ sơ đồ luồng dữ liệu (Mermaid Sequence Diagram) cho 2 luồng cốt lõi:
   - Luồng 1: Người dùng thêm tài liệu mới (UI -> AppState -> DAO/Database -> Reactive Stream -> UI phản hồi tự động).
   - Luồng 2: Tìm kiếm và lọc tài liệu theo từ khóa và môn học (Debounced Search -> DAO Query -> Stream Result).
4. Xuất toàn bộ nội dung thành file `SO_DO_KIEN_TRUC_LUONG_DU_LIEU.md` trong dự án.
```

---

### 📌 PROMPT 2: Checklist 2 - Cấu Trúc Thư Mục & Thiết Lập Tầng Dữ Liệu
> **Mục tiêu:** Xây dựng cấu trúc thư mục chuẩn Cashew, cài đặt mô hình dữ liệu (Database / DAO) với cơ chế Reactive Stream.

```markdown
Hãy đóng vai trò Kỹ sư Flutter cấp cao. Hãy xây dựng Tầng Dữ Liệu (Data Layer) cho dự án `quan_ly_tai_lieu_hoc_tap` tuân thủ nghiêm ngặt nguyên lý kiến trúc Cashew:

1. Tạo cấu trúc thư mục: `lib/database/`, `lib/struct/`, `lib/widgets/`, `lib/pages/`.
2. Trong `lib/struct/models.dart`: Tạo các Data Class: `DocumentItem`, `SubjectItem`, `DocumentTypeItem` hỗ trợ `toMap()`, `fromMap()`, `copyWith()`.
3. Trong `lib/database/database.dart`: 
   - Xây dựng lớp cơ sở dữ liệu `AppDatabase` (sử dụng mẫu Singleton & In-Memory / SQLite DAO Reactive Pattern).
   - Cung cấp dữ liệu mẫu khởi tạo (Mock Seed Data): Các môn học như "Lập trình Di động", "Cấu trúc dữ liệu", "Mạng máy tính"; các loại tài liệu như "Bài giảng Slide", "Bài tập lớn", "Đề cương ôn thi".
4. Trong `lib/database/document_dao.dart`:
   - Viết các phương thức CRUD bất đồng bộ: `insertDocument()`, `updateDocument()`, `deleteDocument()`, `getDocumentById()`.
   - Cung cấp `Stream<List<DocumentItem>> watchDocuments()` và `Stream<List<DocumentItem>> watchFilteredDocuments({String query, String subjectId, String typeId})` phát sự kiện mỗi khi dữ liệu thay đổi.
5. Đảm bảo toàn bộ mã nguồn không có cảnh báo lint, có tài liệu ghi chú rõ vai trò của từng lớp.
```

---

### 📌 PROMPT 3: Checklist 3 - Triển Khai Nghiệp Vụ & Giao Diện 4 Chức Năng Cốt Lõi
> **Mục tiêu:** Hoàn thiện tầng State Management, Widgets và các màn hình: Thêm, Sửa, Xóa và Tìm kiếm tài liệu.

```markdown
Hãy triển khai Tầng Nghiệp Vụ & Giao Diện (Business Logic & UI Presentation Layer) cho dự án `quan_ly_tai_lieu_hoc_tap` theo tiêu chuẩn giao diện Cashew (Material 3, Bo góc hiện đại, Dark/Light Mode, Phản hồi thao tác tức thì):

1. Trong `lib/struct/app_state.dart`:
   - Xây dựng `DocumentManagerNotifier` kế thừa `ChangeNotifier` kết nối trực tiếp với `DocumentDao`.
   - Quản lý trạng thái: bộ lọc môn học đang chọn, từ khóa tìm kiếm, chế độ xem.
2. Trong `lib/widgets/`:
   - `document_card.dart`: Hiển thị thẻ tài liệu với icon loại tệp, tag môn học có màu riêng, nút ghim sao yêu thích, menu pop-up sửa/xóa.
   - `search_bar_widget.dart`: Thanh tìm kiếm bo tròn với icon kính lúp và nút xóa nhanh nội dung.
   - `subject_filter_list.dart`: Danh sách cuộn ngang các môn học dạng FilterChip.
3. Trong `lib/pages/`:
   - `home_page.dart`: Thanh AppBar hiển thị số lượng tài liệu, thanh tìm kiếm nhanh, bộ lọc môn học, danh sách tài liệu phản ứng thời gian thực qua `StreamBuilder`, nút FloatingActionButton tròn nổi bật.
   - `add_edit_document_page.dart`: Form nhập liệu có validation (Tiêu đề, Môn học, Loại tài liệu, Ghi chú tóm tắt, URL/Tên tệp đính kèm). Hỗ trợ cả thêm mới và chỉnh sửa.
   - `document_detail_page.dart`: Xem đầy đủ thông tin, ngày cập nhật, ghi chú nội dung và các hành động tiện ích.
4. Tích hợp thông báo Snackbar xác nhận hoàn tất thao tác sau mỗi lần Thêm/Sửa/Xóa.
5. Cập nhật `lib/main.dart` để liên kết toàn bộ ứng dụng.
```

---

### 📌 PROMPT 4: Checklist 4 - Kiểm Thử Tính Độc Lập Giữa Các Tầng Kiến Trúc
> **Mục tiêu:** Viết bộ Unit Test và Architecture Test đảm bảo việc phân tách logic tuân thủ nguyên tắc Modularization của Cashew.

```markdown
Hãy đóng vai trò Kỹ sư Đảm bảo chất lượng (QA/Software Engineer). Viết bộ kiểm thử tự động cho dự án `quan_ly_tai_lieu_hoc_tap` trong thư mục `test/`:

1. `test/database_crud_test.dart`:
   - Kiểm thử việc thêm một tài liệu mới vào DAO và kiểm tra ID tự sinh.
   - Kiểm thử việc sửa tài liệu và xác nhận dữ liệu được cập nhật chính xác.
   - Kiểm thử việc xóa tài liệu và xác minh tài liệu không còn tồn tại trong DB.
   - Kiểm thử hàm tìm kiếm tài liệu theo từ khóa và lọc theo môn học.
2. `test/reactive_stream_test.dart`:
   - Kiểm thử cơ chế Reactive Stream: Đăng ký lắng nghe `watchDocuments()`, sau đó gọi `insertDocument()`, xác nhận Stream phát ra danh sách mới có chứa phần tử vừa thêm mà không cần truy vấn lại thủ công.
3. `test/architecture_separation_test.dart`:
   - Kiểm tra xác nhận: Model không chứa mã UI, DAO không phụ thuộc vào `BuildContext` hay Widget, đảm bảo tính mô-đun hóa độc lập có thể kiểm thử không cần giả lập màn hình.
4. Đảm bảo toàn bộ các bài test đều vượt qua khi chạy lệnh `flutter test`.
```

---

### 📌 PROMPT 5: Checklist 5 - Đóng Gói Mã Nguồn & Viết Báo Cáo Giải Trình Kiến Trúc
> **Mục tiêu:** Viết bản báo cáo học thuật hoàn chỉnh giải trình cách áp dụng kiến trúc Cashew vào dự án để nộp giảng viên.

```markdown
Hãy đóng vai trò Sinh viên phát triển phần mềm, biên soạn bản BÁO CÁO GIẢI TRÌNH KIẾN TRÚC KỸ THUẬT DỰ ÁN dạng Markdown lưu tại file `BAO_CAO_GIAI_TRINH_KIEN_TRUC_CASHEW.md`.

Nội dung báo cáo phải bao gồm đầy đủ các chương:
1. Đặt vấn đề và Mục tiêu dự án.
2. Cơ sở lý thuyết về Kiến trúc Cashew (Mô hình Local-First, Reactive Stream, Phân tách 3 lớp Data - Domain/State - Presentation).
3. Bản đồ ánh xạ thành phần giữa Cashew Finance và Quản lý tài liệu học tập.
4. Sơ đồ kiến trúc hệ thống và Sơ đồ tuần tự các luồng xử lý (sử dụng Mermaid).
5. Chi tiết cài đặt 4 chức năng cốt lõi (Thêm, Sửa, Xóa, Tìm kiếm).
6. Bằng chứng kiểm thử tính đúng đắn và độc lập giữa các lớp.
7. Đánh giá ưu điểm, hạn chế và hướng phát triển mở rộng (Đồng bộ Google Drive / Firebase Storage cho tệp PDF lớn).
8. Hướng dẫn cài đặt và chạy thử mã nguồn.
```

---

## 3. MASTER PROMPT (TRIỂN KHAI TOÀN DIỆN MỘT LẦN - ALL-IN-ONE)

Nếu bạn muốn yêu cầu AI thực hiện toàn bộ ứng dụng từ đầu đến cuối chỉ bằng **một prompt duy nhất**, hãy sử dụng đoạn lệnh dưới đây:

````markdown
Bạn là chuyên gia lập trình di động Flutter và Kiến trúc sư phần mềm. Hãy nâng cấp toàn diện dự án Flutter hiện tại `quan_ly_tai_lieu_hoc_tap` thành ứng dụng "Quản Lý Tài Liệu Học Tập" hoàn chỉnh, áp dụng chuẩn xác kiến trúc Cashew (Local-First, Phân tách lớp dữ liệu Reactive, Không ghép trộn UI với Database) theo đúng 5 mục checklist sau:

1. [Phân tích & Luồng dữ liệu]: Tạo file `SO_DO_KIEN_TRUC_LUONG_DU_LIEU.md` chứa ERD và sơ đồ Mermaid mô tả luồng thêm/sửa/xóa và tìm kiếm tài liệu phản ứng thời gian thực.
2. [Cấu trúc thư mục & Data Layer]: 
   - `lib/struct/models.dart`: Định nghĩa `DocumentItem`, `SubjectItem`, `DocumentTypeItem`.
   - `lib/database/database.dart`: Quản lý bộ dữ liệu cục bộ với Seed data phong phú (các môn học CNTT/Toán/Văn, các loại tài liệu Slide, Đề thi, Sách).
   - `lib/database/document_dao.dart`: Xử lý CRUD và cung cấp Reactive `Stream` cho dữ liệu tài liệu.
3. [Core Logic & UI Presentation]:
   - `lib/struct/app_state.dart`: Quản lý trạng thái tìm kiếm, lọc theo môn học, sắp xếp.
   - `lib/widgets/`: Xây dựng `DocumentCard`, `SearchBarWidget`, `SubjectFilterChip` theo phong cách Material 3 hiện đại, bo góc 16px, bảng màu tinh tế.
   - `lib/pages/`: 
     + `home_page.dart`: Trang chủ với thống kê số tài liệu, tìm kiếm tức thì, lọc môn học, danh sách tài liệu phản ứng Stream, FloatingActionButton.
     + `add_edit_document_page.dart`: Form nhập liệu có validation đầy đủ.
     + `document_detail_page.dart`: Màn hình xem chi tiết tài liệu, ghi chú học tập.
   - `lib/main.dart`: Kết nối toàn bộ hệ sinh thái ứng dụng.
4. [Kiểm thử]: Tạo các bài unit test trong `test/document_flow_test.dart` kiểm tra tính độc lập của DAO, phản ứng của Stream và nghiệp vụ CRUD.
5. [Báo cáo]: Viết file `BAO_CAO_GIAI_TRINH_KIEN_TRUC_CASHEW.md` giải trình chi tiết cách áp dụng kiến trúc Cashew vào bài tập lớn.

Hãy thực hiện trọn vẹn, không dùng mã giữ chỗ (no placeholders), đảm bảo ứng dụng chạy mượt mà không lỗi.
````
