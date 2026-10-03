import 'package:flutter/material.dart';
import '../struct/app_state.dart';
import '../struct/models.dart';

/// Màn hình Thêm mới / Chỉnh sửa tài liệu học tập
class AddEditDocumentPage extends StatefulWidget {
  final DocumentManagerNotifier appState;
  final DocumentItem? documentToEdit;

  const AddEditDocumentPage({
    super.key,
    required this.appState,
    this.documentToEdit,
  });

  @override
  State<AddEditDocumentPage> createState() => _AddEditDocumentPageState();
}

class _AddEditDocumentPageState extends State<AddEditDocumentPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late TextEditingController _fileUrlController;

  late String _selectedSubjectFk;
  late String _selectedDocumentTypeFk;
  late bool _isFavorite;

  bool get isEditing => widget.documentToEdit != null;

  @override
  void initState() {
    super.initState();
    final doc = widget.documentToEdit;

    _titleController = TextEditingController(text: doc?.title ?? '');
    _noteController = TextEditingController(text: doc?.note ?? '');
    _fileUrlController = TextEditingController(text: doc?.fileUrl ?? '');

    // Khởi tạo môn học được chọn
    final availableSubjects = widget.appState.subjects;
    if (doc != null && availableSubjects.any((s) => s.subjectPk == doc.subjectFk)) {
      _selectedSubjectFk = doc.subjectFk;
    } else {
      _selectedSubjectFk = availableSubjects.isNotEmpty
          ? availableSubjects.first.subjectPk
          : '';
    }

    // Khởi tạo loại tài liệu được chọn
    final availableTypes = widget.appState.documentTypes;
    if (doc != null && availableTypes.any((t) => t.typePk == doc.documentTypeFk)) {
      _selectedDocumentTypeFk = doc.documentTypeFk;
    } else {
      _selectedDocumentTypeFk = availableTypes.isNotEmpty
          ? availableTypes.first.typePk
          : '';
    }

    _isFavorite = doc?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _fileUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final doc = DocumentItem(
      documentPk: widget.documentToEdit?.documentPk ?? '',
      title: _titleController.text.trim(),
      note: _noteController.text.trim(),
      subjectFk: _selectedSubjectFk,
      documentTypeFk: _selectedDocumentTypeFk,
      fileUrl: _fileUrlController.text.trim(),
      isFavorite: _isFavorite,
      createdAt: widget.documentToEdit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await widget.appState.saveDocument(doc);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Đã cập nhật tài liệu thành công!'
                  : 'Đã thêm tài liệu học tập mới!',
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra, vui lòng thử lại!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = widget.appState.subjects;
    final documentTypes = widget.appState.documentTypes;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Chỉnh Sửa Tài Liệu' : 'Thêm Tài Liệu Mới',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: _isFavorite ? const Color(0xFFFFB300) : null,
            ),
            tooltip: 'Đánh dấu yêu thích',
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Tiêu đề tài liệu
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Tiêu đề tài liệu *',
                hintText: 'Nhập tiêu đề bài giảng, bài tập, giáo trình...',
                prefixIcon: const Icon(Icons.title_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tiêu đề tài liệu';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Chọn Môn học
            DropdownButtonFormField<String>(
              initialValue: _selectedSubjectFk.isNotEmpty ? _selectedSubjectFk : null,
              decoration: InputDecoration(
                labelText: 'Môn học / Học phần *',
                prefixIcon: const Icon(Icons.school_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: subjects.map((subject) {
                return DropdownMenuItem<String>(
                  value: subject.subjectPk,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: subject.colorValue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('${subject.code} - ${subject.name}'),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedSubjectFk = val);
              },
            ),
            const SizedBox(height: 18),

            // Chọn Loại tài liệu
            DropdownButtonFormField<String>(
              initialValue: _selectedDocumentTypeFk.isNotEmpty
                  ? _selectedDocumentTypeFk
                  : null,
              decoration: InputDecoration(
                labelText: 'Loại tài liệu *',
                prefixIcon: const Icon(Icons.category_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: documentTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type.typePk,
                  child: Row(
                    children: [
                      Icon(type.iconData, size: 18, color: type.colorValue),
                      const SizedBox(width: 10),
                      Text(type.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedDocumentTypeFk = val);
              },
            ),
            const SizedBox(height: 18),

            // Ghi chú tóm tắt bài học
            TextFormField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Ghi chú tóm tắt nội dung',
                hintText: 'Nhập tóm tắt bài giảng, điểm lưu ý cần ôn thi...',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: Icon(Icons.notes_rounded),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // File đính kèm hoặc URL tham khảo
            TextFormField(
              controller: _fileUrlController,
              decoration: InputDecoration(
                labelText: 'Tệp đính kèm / Liên kết (URL)',
                hintText: 'ví dụ: slide_bai_3.pdf hoặc https://...',
                prefixIcon: const Icon(Icons.attach_file_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Switch đánh dấu yêu thích
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: const Text(
                'Ghim vào tài liệu yêu thích',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Ưu tiên hiển thị trên đầu danh sách'),
              value: _isFavorite,
              activeThumbColor: const Color(0xFFFFB300),
              onChanged: (val) => setState(() => _isFavorite = val),
            ),
            const SizedBox(height: 24),

            // Nút Lưu
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _handleSave,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text(
                isEditing ? 'Cập Nhật Tài Liệu' : 'Lưu Tài Liệu Học Tập',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
