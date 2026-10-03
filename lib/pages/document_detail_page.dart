import 'package:flutter/material.dart';
import '../struct/app_state.dart';
import '../struct/models.dart';
import '../widgets/confirm_delete_dialog.dart';
import 'add_edit_document_page.dart';

/// Màn hình Xem chi tiết tài liệu học tập
class DocumentDetailPage extends StatefulWidget {
  final DocumentManagerNotifier appState;
  final String documentPk;

  const DocumentDetailPage({
    super.key,
    required this.appState,
    required this.documentPk,
  });

  @override
  State<DocumentDetailPage> createState() => _DocumentDetailPageState();
}

class _DocumentDetailPageState extends State<DocumentDetailPage> {
  String _formatDateTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} ngày ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _handleDelete(DocumentItem doc) async {
    final confirm = await ConfirmDeleteDialog.show(
      context,
      title: 'Xóa tài liệu này?',
      content: 'Tài liệu "${doc.title}" sẽ bị xóa vĩnh viễn khỏi bộ nhớ máy.',
    );

    if (confirm == true && mounted) {
      await widget.appState.deleteDocument(doc.documentPk);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa tài liệu thành công!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dùng StreamBuilder để tự động cập nhật khi tài liệu được sửa hoặc đổi trạng thái yêu thích
    return StreamBuilder<List<DocumentItem>>(
      stream: widget.appState.currentFilteredStream,
      builder: (context, snapshot) {
        // Tìm tài liệu hiện tại trong database
        final doc = widget.appState.dao.getDocumentById(widget.documentPk);

        return FutureBuilder<DocumentItem?>(
          future: doc,
          builder: (context, docSnapshot) {
            final currentDoc = docSnapshot.data;

            if (currentDoc == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Chi Tiết Tài Liệu')),
                body: const Center(
                  child: Text('Tài liệu không tồn tại hoặc đã bị xóa.'),
                ),
              );
            }

            final subject = widget.appState.getSubject(currentDoc.subjectFk);
            final documentType =
                widget.appState.getDocumentType(currentDoc.documentTypeFk);
            final subjectColor =
                subject?.colorValue ?? theme.colorScheme.primary;

            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Chi Tiết Tài Liệu',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: [
                  // Nút ghim yêu thích
                  IconButton(
                    icon: Icon(
                      currentDoc.isFavorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: currentDoc.isFavorite
                          ? const Color(0xFFFFB300)
                          : null,
                    ),
                    tooltip: currentDoc.isFavorite
                        ? 'Bỏ yêu thích'
                        : 'Thêm vào yêu thích',
                    onPressed: () async {
                      await widget.appState.toggleFavorite(currentDoc.documentPk);
                      setState(() {});
                    },
                  ),
                  // Nút chỉnh sửa
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Chỉnh sửa tài liệu',
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditDocumentPage(
                            appState: widget.appState,
                            documentToEdit: currentDoc,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                  // Nút xóa
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.red),
                    tooltip: 'Xóa tài liệu',
                    onPressed: () => _handleDelete(currentDoc),
                  ),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Huy hiệu Môn học & Loại tài liệu
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: subjectColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: subjectColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              subject?.iconData ?? Icons.school_rounded,
                              size: 16,
                              color: subjectColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${subject?.code ?? ''} • ${subject?.name ?? 'Môn học'}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: subjectColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Loại tài liệu
                  if (documentType != null) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: documentType.colorValue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                documentType.iconData,
                                size: 14,
                                color: documentType.colorValue,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                documentType.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: documentType.colorValue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tiêu đề tài liệu lớn
                  Text(
                    currentDoc.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Thẻ ghi chú tóm tắt nội dung
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.notes_rounded,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Ghi chú học tập / Tóm tắt',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            currentDoc.note.isNotEmpty
                                ? currentDoc.note
                                : 'Chưa có ghi chú tóm tắt cho tài liệu này.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: currentDoc.note.isNotEmpty
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              fontStyle: currentDoc.note.isEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Thẻ Tệp đính kèm
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.attach_file_rounded,
                                size: 18,
                                color: theme.colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Tệp đính kèm / Tài nguyên',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  currentDoc.fileUrl.isNotEmpty
                                      ? currentDoc.fileUrl
                                      : 'Không có tệp đính kèm',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: currentDoc.fileUrl.isEmpty
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                                ),
                              ),
                              if (currentDoc.fileUrl.isNotEmpty)
                                FilledButton.tonalIcon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Đang mở tệp: ${currentDoc.fileUrl}',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.open_in_new_rounded,
                                      size: 16),
                                  label: const Text('Mở tệp'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Thông tin thời gian
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tạo lúc: ${_formatDateTime(currentDoc.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cập nhật: ${_formatDateTime(currentDoc.updatedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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
}
