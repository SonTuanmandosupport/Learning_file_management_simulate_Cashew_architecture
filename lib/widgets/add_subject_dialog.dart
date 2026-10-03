import 'package:flutter/material.dart';
import '../colors.dart';
import '../struct/app_state.dart';
import '../struct/models.dart';
import '../struct/subject_icons.dart';

/// Hộp thoại Thêm mới hoặc Chỉnh sửa môn học với 50+ biểu tượng chuyên ngành
class AddSubjectDialog extends StatefulWidget {
  final DocumentManagerNotifier appState;
  final SubjectItem? subjectToEdit;

  const AddSubjectDialog({
    super.key,
    required this.appState,
    this.subjectToEdit,
  });

  static Future<bool?> show(
    BuildContext context, {
    required DocumentManagerNotifier appState,
    SubjectItem? subjectToEdit,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AddSubjectDialog(
        appState: appState,
        subjectToEdit: subjectToEdit,
      ),
    );
  }

  @override
  State<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;

  late Color _selectedColor;
  late String _selectedIconName;

  bool get isEditing => widget.subjectToEdit != null;

  @override
  void initState() {
    super.initState();
    final subject = widget.subjectToEdit;

    _nameController = TextEditingController(text: subject?.name ?? '');
    _codeController = TextEditingController(text: subject?.code ?? '');

    _selectedColor = subject?.colorValue ?? AppColors.subjectColors.first;
    _selectedIconName = subject?.iconName ?? 'school';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final colorHex =
        '0x${_selectedColor.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0')}';

    if (isEditing) {
      final updated = widget.subjectToEdit!.copyWith(
        name: _nameController.text.trim(),
        code: _codeController.text.trim().toUpperCase(),
        colour: colorHex,
        iconName: _selectedIconName,
      );
      await widget.appState.updateSubject(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật môn học "${updated.name}" thành công!'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } else {
      final newSubject = SubjectItem(
        subjectPk: '',
        name: _nameController.text.trim(),
        code: _codeController.text.trim().toUpperCase(),
        colour: colorHex,
        iconName: _selectedIconName,
        createdAt: DateTime.now(),
      );
      await widget.appState.addSubject(newSubject);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm môn học "${newSubject.name}" thành công!'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      }
    }
  }

  void _showIconPickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.category_rounded, color: _selectedColor),
                        const SizedBox(width: 10),
                        const Text(
                          'Chọn Biểu Tượng Ngành Học (50+ icons)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: SubjectIcons.categories.length,
                      itemBuilder: (context, catIndex) {
                        final cat = SubjectIcons.categories[catIndex];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                cat.categoryName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1.1,
                              ),
                              itemCount: cat.icons.length,
                              itemBuilder: (context, iconIndex) {
                                final iconInfo = cat.icons[iconIndex];
                                final isSelected = _selectedIconName == iconInfo.name;

                                return InkWell(
                                  onTap: () {
                                    setState(() => _selectedIconName = iconInfo.name);
                                    Navigator.of(ctx).pop();
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _selectedColor.withValues(alpha: 0.15)
                                          : Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest
                                              .withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? _selectedColor
                                            : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          iconInfo.icon,
                                          color: isSelected
                                              ? _selectedColor
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                          size: 24,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          iconInfo.label.split(' / ').first,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIconData = SubjectIcons.getIcon(_selectedIconName);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _selectedColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              currentIconData,
              color: _selectedColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEditing ? 'Chỉnh Sửa Môn Học' : 'Thêm Môn Học Mới',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên môn học
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên môn học *',
                  hintText: 'ví dụ: Kinh tế vi mô, Giải tích 1...',
                  prefixIcon: const Icon(Icons.menu_book_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập tên môn học';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Mã môn học
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Mã học phần *',
                  hintText: 'ví dụ: ECO101, MAT109...',
                  prefixIcon: const Icon(Icons.tag_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập mã học phần';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Chọn biểu tượng icon (Kho 50+ icons)
              const Text(
                'Biểu tượng chuyên ngành:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _showIconPickerModal(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _selectedColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(currentIconData, color: _selectedColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Biểu tượng: $_selectedIconName',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              'Nhấn để chọn từ 50+ biểu tượng nhiều lĩnh vực',
                              style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_right_rounded),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Chọn màu sắc nhận diện
              const Text(
                'Màu nhận diện môn học:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppColors.subjectColors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: theme.colorScheme.onSurface,
                                width: 2.5,
                              )
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _selectedColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _handleSubmit,
          child: Text(isEditing ? 'Lưu Thay Đổi' : 'Tạo Môn Học'),
        ),
      ],
    );
  }
}
