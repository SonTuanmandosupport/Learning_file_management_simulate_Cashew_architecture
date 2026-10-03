# TÀI LIỆU THIẾT KẾ KIẾN TRÚC & SƠ ĐỒ LUỒNG DỮ LIỆU
## DỰ ÁN: ỨNG DỤNG QUẢN LÝ TÀI LIỆU HỌC TẬP (LOCAL-FIRST CASHEW PATTERN)
**Mã checklist thực hiện:** Checklist 1 / 5  
**Dự án:** `quan_ly_tai_lieu_hoc_tap`  
**Kiến trúc tham chiếu:** Cashew Mobile Architecture (Local-First, Reactive Data Streams, 3-Layer Separation)

---

## 1. PHÂN TÍCH YÊU CẦU CHỨC NĂNG (FUNCTIONAL REQUIREMENTS)

Hệ thống được thiết kế để phục vụ nhu cầu học tập của sinh viên, cho phép quản lý toàn diện các dạng tài liệu (Bài giảng, Bài tập, Slide thuyết trình, Tài liệu tham khảo, Đề thi cũ) mà không phụ thuộc vào kết nối mạng Internet liên tục.

### 1.1. Ma Trận Yêu Cầu Chức Năng Cốt Lõi

| Mã YC | Tên chức năng | Mô tả chi tiết | Tiêu chí chấp nhận (Acceptance Criteria) |
| :--- | :--- | :--- | :--- |
| **FR-01** | **Thêm tài liệu mới (Create)** | Cho phép sinh viên tạo bản ghi tài liệu học tập mới kèm thông tin: Tiêu đề, Môn học, Loại tài liệu, Ghi chú, Đường dẫn/Tên file đính kèm. | - Dữ liệu được xác thực hợp lệ (tiêu đề không để trống).<br>- Tự sinh mã định danh duy nhất (`documentPk`).<br>- Ghi tức thì vào cơ sở dữ liệu cục bộ (< 30ms). |
| **FR-02** | **Xem danh sách & chi tiết (Read)** | Hiển thị danh sách tài liệu trực quan dạng thẻ (Card), hỗ trợ xem toàn bộ thông tin chi tiết của tài liệu. | - Tự động cập nhật danh sách qua Reactive Stream khi DB biến động.<br>- Hiển thị nhãn môn học và loại tài liệu với màu sắc nhận diện. |
| **FR-03** | **Chỉnh sửa tài liệu (Update)** | Cập nhật thông tin tiêu đề, môn học, ghi chú, trạng thái yêu thích của tài liệu đã tồn tại. | - Bản ghi được cập nhật với `updatedAt` mới nhất.<br>- Màn hình chi tiết và màn hình chính tự đồng bộ trạng thái mới. |
| **FR-04** | **Xóa tài liệu (Delete)** | Xóa tài liệu không còn sử dụng ra khỏi bộ nhớ cục bộ. | - Có hộp thoại cảnh báo xác nhận trước khi xóa.<br>- Danh sách tự loại bỏ tài liệu ngay sau khi xác nhận. |
| **FR-05** | **Tìm kiếm thời gian thực (Search)** | Tìm kiếm tài liệu theo từ khóa tiêu đề hoặc nội dung ghi chú. | - Tìm kiếm phản hồi ngay khi người dùng gõ phím.<br>- Không phân biệt chữ hoa/thường (Case-insensitive). |
| **FR-06** | **Lọc theo Môn học & Loại tài liệu** | Lọc nhanh danh sách theo môn học (ví dụ: Lập trình di động, Mạng máy tính) và loại tài liệu. | - Chọn "Tất cả" hoặc từng môn học cụ thể qua Filter Chip.<br>- Kết hợp đồng thời vừa tìm kiếm từ khóa vừa lọc theo môn. |
| **FR-07** | **Đánh dấu Yêu thích (Favorite)** | Ghim các tài liệu quan trọng lên đầu danh sách để truy cập nhanh. | - Chạm 1 chạm vào biểu tượng ngôi sao để bật/tắt yêu thích. |

---

## 2. THIẾT KẾ LƯỢC ĐỒ DỮ LIỆU THỰC THỂ (ERD)

Kiến trúc Cashew sử dụng mô hình cơ sở dữ liệu quan hệ cục bộ (SQLite/Drift). Dưới đây là thiết kế 3 bảng dữ liệu chính của ứng dụng Quản lý tài liệu học tập:

```mermaid
erDiagram
    SUBJECTS ||--o{ DOCUMENTS : "chứa"
    DOCUMENT_TYPES ||--o{ DOCUMENTS : "phân loại"

    SUBJECTS {
        string subjectPk PK "Khóa chính (vd: sub_mobile_01)"
        string name "Tên môn học (vd: Lập trình Di động)"
        string code "Mã môn (vd: IT3040)"
        string colour "Mã màu HEX hiển thị (vd: 0xFF1E88E5)"
        string iconName "Tên icon đại diện"
        datetime createdAt "Ngày tạo"
    }

    DOCUMENT_TYPES {
        string typePk PK "Khóa chính (vd: type_slide_01)"
        string name "Tên phân loại (vd: Bài giảng Slide)"
        string colour "Mã màu HEX (vd: 0xFF43A047)"
        string iconName "Tên icon đại diện"
    }

    DOCUMENTS {
        string documentPk PK "Khóa chính (vd: doc_flutter_001)"
        string title "Tiêu đề tài liệu"
        string note "Ghi chú tóm tắt bài học"
        string subjectFk FK "Khóa ngoại trỏ về SUBJECTS"
        string documentTypeFk FK "Khóa ngoại trỏ về DOCUMENT_TYPES"
        string fileUrl "Đường dẫn file hoặc URL tham khảo"
        boolean isFavorite "Đánh dấu tài liệu ưu tiên / sao"
        datetime createdAt "Thời điểm tạo tài liệu"
        datetime updatedAt "Thời điểm cập nhật gần nhất"
    }
```

### Chi tiết các trường dữ liệu và mẫu bản ghi:

#### 1. Bảng `Documents` (Tài liệu học tập)
| Tên trường | Kiểu dữ liệu | Ý nghĩa | Ví dụ bản ghi |
| :--- | :--- | :--- | :--- |
| `documentPk` | String (Primary Key) | Mã định danh duy nhất UUID | `"doc_1701234567_abc"` |
| `title` | String | Tiêu đề tài liệu | `"Slide Kiến Trúc Flutter & Drift ORM"` |
| `note` | String | Ghi chú nội dung trọng tâm | `"Ôn tập kỹ mô hình Local-First và Reactive Stream"` |
| `subjectFk` | String (Foreign Key) | Mã môn học liên kết | `"sub_mobile_dev"` |
| `documentTypeFk`| String (Foreign Key) | Mã phân loại tài liệu | `"type_lecture_slide"` |
| `fileUrl` | String | Tên tệp hoặc liên kết | `"assets/docs/flutter_arch.pdf"` |
| `isFavorite` | Boolean | Trạng thái yêu thích | `true` |
| `createdAt` | DateTime | Thời gian tạo | `"2026-10-03T10:00:00Z"` |
| `updatedAt` | DateTime | Thời gian sửa đổi | `"2026-10-03T10:15:00Z"` |

#### 2. Bảng `Subjects` (Môn học)
| Tên trường | Kiểu dữ liệu | Ý nghĩa | Ví dụ bản ghi |
| :--- | :--- | :--- | :--- |
| `subjectPk` | String (Primary Key) | Mã định danh môn học | `"sub_mobile_dev"` |
| `name` | String | Tên môn học | `"Lập trình Thiết bị Di động"` |
| `code` | String | Mã học phần | `"IT4440"` |
| `colour` | String | Màu nhận diện hex | `"0xFF1E88E5"` (Xanh lam) |
| `iconName` | String | Tên biểu tượng | `"phone_android"` |

#### 3. Bảng `DocumentTypes` (Phân loại tài liệu)
| Tên trường | Kiểu dữ liệu | Ý nghĩa | Ví dụ bản ghi |
| :--- | :--- | :--- | :--- |
| `typePk` | String (Primary Key) | Mã phân loại | `"type_lecture_slide"` |
| `name` | String | Tên loại | `"Bài Giảng / Slide"` |
| `colour` | String | Màu nhận diện hex | `"0xFFFB8C00"` (Màu cam) |
| `iconName` | String | Tên biểu tượng | `"slideshow"` |

---

## 3. THIẾT KẾ SƠ ĐỒ LUỒNG DỮ LIỆU TỔNG THỂ (SYSTEM ARCHITECTURE)

Ứng dụng tuân thủ mô hình 3 lớp phân tách của Cashew: **Presentation Layer $\leftrightarrow$ Business Logic / State Layer $\leftrightarrow$ Data Layer**:

```mermaid
graph TD
    subgraph Presentation_Layer ["1. Tầng Giao Diện (Presentation Layer)"]
        HomePage["HomePage<br/>(Dashboard, List tài liệu, Thống kê)"]
        AddEditPage["AddEditDocumentPage<br/>(Form nhập liệu & Validation)"]
        DetailPage["DocumentDetailPage<br/>(Xem chi tiết & Thao tác)"]
        Widgets["Reusable Widgets<br/>(DocumentCard, SearchBar, SubjectChips)"]
    end

    subgraph State_Layer ["2. Tầng Nghiệp Vụ & Trạng Thái (State / Business Logic)"]
        AppState["DocumentManagerNotifier<br/>(ChangeNotifier / State Management)"]
        FilterLogic["Filter & Search Controller<br/>(Lọc đa tiêu chí: text, subject, type)"]
    end

    subgraph Data_Layer ["3. Tầng Dữ Liệu Cục Bộ (Local-First Data Layer)"]
        DocDAO["DocumentDao<br/>(Data Access Object: CRUD & Queries)"]
        ReactiveStream["Reactive Stream Controller<br/>(Phát event khi có biến động DB)"]
        AppDB[("Local Database Storage<br/>(Documents, Subjects, Types)")]
    end

    %% Tương tác luồng
    HomePage -->|Người dùng gõ tìm kiếm/chọn môn| FilterLogic
    AddEditPage -->|Gửi form tạo/sửa tài liệu| AppState
    DetailPage -->|Gửi yêu cầu Xóa / Đổi trạng thái Sao| AppState

    FilterLogic --> AppState
    AppState -->|Gọi hàm nghiệp vụ| DocDAO
    DocDAO -->|Ghi / Đọc dữ liệu SQL| AppDB
    AppDB -->>|Dữ liệu đã lưu| DocDAO
    DocDAO -->>|Bắn sự kiện Stream mới| ReactiveStream
    ReactiveStream -->>|StreamBuilder tự vẽ lại UI (< 30ms)| HomePage
    ReactiveStream -->>|StreamBuilder tự vẽ lại UI| DetailPage
```

---

## 4. SƠ ĐỒ TUẦN TỰ CÁC LUỒNG TƯƠNG TÁC CỐT LÕI (SEQUENCE DIAGRAMS)

### 4.1. Luồng 1: Thêm / Sửa Tài Liệu Cục Bộ (Offline-First Document Creation)
> **Kịch bản:** Người dùng nhấn nút "+" trên trang chủ, điền thông tin bài giảng "Kiến trúc phần mềm" và bấm "Lưu".

```mermaid
sequenceDiagram
    autonumber
    actor User as Sinh viên
    participant UI as AddEditDocumentPage
    participant Notifier as DocumentManagerNotifier
    participant DAO as DocumentDao
    participant DB as Local Database (Đĩa cứng)
    participant Stream as Reactive Stream Event
    participant Home as HomePage (StreamBuilder)

    User->>UI: 1. Nhập tiêu đề, chọn môn "Di động", bấm "Lưu"
    UI->>UI: 2. Kiểm tra tính hợp lệ dữ liệu (Form Validation)
    UI->>Notifier: 3. Gọi saveDocument(documentItem)
    Notifier->>DAO: 4. Gọi insertDocument(document)
    DAO->>DB: 5. Ghi bản ghi vào bảng Documents
    DB-->>DAO: 6. Xác nhận ghi thành công (Success ID)
    DAO-->>Stream: 7. Bắn sự kiện (Event): "Bảng Documents vừa thay đổi"
    Stream-->>Home: 8. Stream lắng nghe, tự động tải lại danh sách mới
    Home-->>User: 9. Màn hình tự xuất hiện tài liệu mới lập tức (< 30ms)
    UI-->>User: 10. Đóng form và hiển thị thông báo Snackbar thành công
```

---

### 4.2. Luồng 2: Tìm Kiếm & Lọc Tài Liệu Thời Gian Thực (Debounced Realtime Search)
> **Kịch bản:** Người dùng gõ từ khóa "kiến trúc" và nhấn chọn lọc môn "Lập trình Di động".

```mermaid
sequenceDiagram
    autonumber
    actor User as Sinh viên
    participant SearchUI as SearchBarWidget & SubjectChips
    participant Notifier as DocumentManagerNotifier
    participant DAO as DocumentDao
    participant HomeUI as Danh sách hiển thị (StreamBuilder)

    User->>SearchUI: 1. Gõ chữ "kiến trúc" và chọn môn "Lập trình Di động"
    SearchUI->>Notifier: 2. Cập nhật state: searchKeyword="kiến trúc", selectedSubject="sub_mobile_dev"
    Notifier->>DAO: 3. Gọi watchFilteredDocuments(query: "kiến trúc", subjectId: "sub_mobile_dev")
    DAO->>DAO: 4. Lọc dữ liệu trong bộ nhớ: LIKE %kiến trúc% AND subjectFk == sub_mobile_dev
    DAO-->>HomeUI: 5. Trả về Stream danh sách các tài liệu thỏa mãn điều kiện
    HomeUI-->>User: 6. Giao diện lọc lại kết quả mượt mà không bị giật lag
```

---

### 4.3. Luồng 3: Xóa Tài Liệu Có Xác Nhận An Toàn (Safe Deletion Flow)
> **Kịch bản:** Người dùng xóa một tài liệu đã học xong.

```mermaid
sequenceDiagram
    autonumber
    actor User as Sinh viên
    participant UI as DocumentDetailPage
    participant Dialog as ConfirmDeleteDialog
    participant Notifier as DocumentManagerNotifier
    participant DAO as DocumentDao
    participant Stream as Reactive Stream Event

    User->>UI: 1. Nhấn nút "Xóa tài liệu"
    UI->>Dialog: 2. Hiển thị hộp thoại xác nhận: "Bạn có chắc chắn muốn xóa?"
    User->>Dialog: 3. Nhấn "Xác nhận Xóa"
    Dialog->>Notifier: 4. Gọi deleteDocument(documentPk)
    Notifier->>DAO: 5. Gọi deleteDocumentById(documentPk)
    DAO->>DAO: 6. Xóa bản ghi khỏi bảng Documents
    DAO-->>Stream: 7. Phát sự kiện: "Dữ liệu đã xóa"
    Stream-->>UI: 8. Pop chuyển hướng về HomePage
    UI-->>User: 9. Hiển thị Snackbar "Đã xóa tài liệu thành công"
```

---

## 5. KẾT LUẬN & ĐÁNH GIÁ CHUẨN KIẾN TRÚC CASHEW (CHECKLIST 1 COMPLETED)

1. **Tính độc lập giữa các tầng:**
   - Tầng UI (`Pages`, `Widgets`) **hoàn toàn không chứa mã SQL/Database**, chỉ giao tiếp qua `DocumentManagerNotifier` và lắng nghe `Stream`.
   - Tầng Data (`DAO`, `Database`) hoàn toàn độc lập, không phụ thuộc vào `BuildContext` hay thư viện giao diện Flutter, giúp việc kiểm thử tự động (Unit Test) diễn ra độc lập và nhanh chóng.
2. **Khả năng mở rộng trong tương lai:**
   - Hệ thống sẵn sàng mở rộng thêm tính năng đính kèm tệp PDF, đọc file nội bộ hoặc đồng bộ đám mây (Cloud Sync) tương tự như Sync Engine của Cashew mà không cần viết lại tầng giao diện.

> **Trạng thái:** Checklist 1 đã hoàn thành đầy đủ. Sẵn sàng chuyển tiếp sang **Checklist 2: Thiết lập cấu trúc thư mục & Tầng Dữ Liệu (Data Layer)**.
