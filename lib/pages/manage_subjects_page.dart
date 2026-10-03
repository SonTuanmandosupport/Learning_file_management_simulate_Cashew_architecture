import 'package:flutter/material.dart';
import '../struct/app_state.dart';
import '../struct/models.dart';
import '../widgets/add_subject_dialog.dart';

/// Màn hình Quản Lý Môn Học (Tương tự editWalletsPage trong Cashew)
class ManageSubjectsPage extends StatefulWidget {
  final DocumentManagerNotifier appState;

  const ManageSubjectsPage({super.key, required this.appState});

  @override
  State<ManageSubjectsPage> createState() => _ManageSubjectsPageState();
}

class _ManageSubjectsPageState extends State<ManageSubjectsPage> {
  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  Future<void> _handleDeleteSubject(SubjectItem subject) async {
    final appState = widget.appState;

    // 1. Ràng buộc: Phải có ít nhất 1 môn học trong hệ thống
    if (appState.subjects.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xóa! Hệ thống phải có ít nhất 1 môn học.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final docCount = appState.getDocumentCountForSubject(subject.subjectPk);

    // 2. Kịch bản A: Môn học không có tài liệu nào -> Xóa trực tiếp sau khi xác nhận
    if (docCount == 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Xác nhận xóa môn học?'),
          content: Text(
            'Môn "${subject.name}" hiện chưa có tài liệu nào. Bạn có chắc muốn xóa?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Xác nhận Xóa'),
            ),
          ],
        ),
      );

      if (confirm == true && mounted) {
        await appState.deleteSubject(subject.subjectPk);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa môn học "${subject.name}" thành công!'),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      return;
    }

    // 3. Kịch bản B: Môn học đang có tài liệu -> Yêu cầu chuyển tài liệu sang môn khác (Cashew Merge & Reassign)
    final otherSubjects =
        appState.subjects.where((s) => s.subjectPk != subject.subjectPk).toList();

    String selectedTargetSubjectPk = otherSubjects.first.subjectPk;

    final shouldReassignAndDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Chuyển Tài Liệu Trước Khi Xóa',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      const TextSpan(text: 'Môn học '),
                      TextSpan(
                        text: '"${subject.name}"',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' đang chứa '),
                      TextSpan(
                        text: '$docCount tài liệu',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const TextSpan(
                        text: '.\nĐể đảm bảo an toàn, vui lòng chọn môn học tiếp nhận toàn bộ các tài liệu này trước khi xóa:',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedTargetSubjectPk,
                  decoration: InputDecoration(
                    labelText: 'Chuyển toàn bộ tài liệu sang môn *',
                    prefixIcon: const Icon(Icons.drive_file_move_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: otherSubjects.map((s) {
                    return DropdownMenuItem<String>(
                      value: s.subjectPk,
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: s.colorValue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${s.code} - ${s.name}'),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedTargetSubjectPk = val);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Hủy'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                icon: const Icon(Icons.drive_file_move_outline, size: 18),
                label: const Text('Chuyển & Xóa Môn'),
              ),
            ],
          );
        },
      ),
    );

    if (shouldReassignAndDelete == true && mounted) {
      await appState.deleteSubject(
        subject.subjectPk,
        reassignToSubjectPk: selectedTargetSubjectPk,
      );

      final targetName =
          appState.getSubject(selectedTargetSubjectPk)?.name ?? 'môn học mới';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã chuyển $docCount tài liệu sang môn "$targetName" và xóa môn cũ thành công!',
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjects = widget.appState.subjects;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản Lý Môn Học',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Thêm môn học mới',
            onPressed: () => AddSubjectDialog.show(context, appState: widget.appState),
          ),
        ],
      ),
      body: subjects.isEmpty
          ? const Center(child: Text('Chưa có môn học nào'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final docCount =
                    widget.appState.getDocumentCountForSubject(subject.subjectPk);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Icon môn học tròn
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: subject.colorValue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: subject.colorValue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            subject.iconData,
                            color: subject.colorValue,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Thông tin môn học
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: subject.colorValue.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      subject.code,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: subject.colorValue,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$docCount tài liệu',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: docCount > 0
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurfaceVariant,
                                      fontWeight: docCount > 0
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                subject.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Nút Chỉnh sửa
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          tooltip: 'Chỉnh sửa môn học',
                          onPressed: () {
                            AddSubjectDialog.show(
                              context,
                              appState: widget.appState,
                              subjectToEdit: subject,
                            );
                          },
                        ),

                        // Nút Xóa
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 20, color: Colors.red),
                          tooltip: 'Xóa môn học',
                          onPressed: () => _handleDeleteSubject(subject),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddSubjectDialog.show(context, appState: widget.appState),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm môn học mới'),
      ),
    );
  }
}
