import 'package:flutter/material.dart';
import '../struct/models.dart';

/// Thẻ hiển thị tài liệu học tập theo phong cách Cashew Card
class DocumentCard extends StatelessWidget {
  final DocumentItem document;
  final SubjectItem? subject;
  final DocumentTypeItem? documentType;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DocumentCard({
    super.key,
    required this.document,
    this.subject,
    this.documentType,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjectColor = subject?.colorValue ?? theme.colorScheme.primary;
    final typeColor = documentType?.colorValue ?? Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hàng trên: Môn học tag & Nút yêu thích + Menu
              Row(
                children: [
                  // Tag Môn học
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: subjectColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: subjectColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          subject?.iconData ?? Icons.school_rounded,
                          size: 14,
                          color: subjectColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          subject?.code ?? 'MÔN HỌC',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: subjectColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Tag Phân loại tài liệu
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          documentType?.iconData ?? Icons.description_rounded,
                          size: 13,
                          color: typeColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          documentType?.name ?? 'Tài liệu',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: typeColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Nút ghim sao yêu thích (1-tap toggle)
                  IconButton(
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      document.isFavorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: document.isFavorite
                          ? const Color(0xFFFFB300)
                          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    onPressed: onToggleFavorite,
                    tooltip: document.isFavorite ? 'Bỏ yêu thích' : 'Yêu thích',
                  ),
                  const SizedBox(width: 4),

                  // Menu tùy chọn Sửa/Xóa nhanh
                  PopupMenuButton<String>(
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (val) {
                      if (val == 'edit') onEdit();
                      if (val == 'delete') onDelete();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa tài liệu', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Tiêu đề tài liệu
              Text(
                document.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (document.note.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  document.note,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 8),

              // Hàng dưới: Tên file đính kèm & Ngày cập nhật
              Row(
                children: [
                  Icon(
                    Icons.attach_file_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      document.fileUrl.isNotEmpty
                          ? document.fileUrl
                          : 'Chưa có file đính kèm',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                        fontStyle: document.fileUrl.isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(document.updatedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
