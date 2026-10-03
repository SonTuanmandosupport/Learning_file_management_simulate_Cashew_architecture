import 'package:flutter/material.dart';
import '../struct/models.dart';

/// Chip lọc môn học cuộn ngang kèm nút thêm môn học nhanh
class SubjectFilterChipList extends StatelessWidget {
  final List<SubjectItem> subjects;
  final String selectedSubjectId;
  final ValueChanged<String> onSelected;
  final VoidCallback? onAddSubject;

  const SubjectFilterChipList({
    super.key,
    required this.subjects,
    required this.selectedSubjectId,
    required this.onSelected,
    this.onAddSubject,
  });

  @override
  Widget build(BuildContext context) {
    final extraItems = 1 + (onAddSubject != null ? 1 : 0); // Chip "Tất cả" + Chip "+ Thêm môn"

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: subjects.length + extraItems,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          // 1. Chip "Tất cả môn"
          if (index == 0) {
            final isSelected = selectedSubjectId == 'all';
            return FilterChip(
              avatar: Icon(
                Icons.grid_view_rounded,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              label: const Text('Tất cả môn'),
              selected: isSelected,
              onSelected: (_) => onSelected('all'),
              showCheckmark: false,
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
            );
          }

          // 2. Chip "+ Thêm môn" ở cuối danh sách
          if (onAddSubject != null && index == subjects.length + 1) {
            return ActionChip(
              avatar: Icon(
                Icons.add_circle_outline_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: const Text('Thêm môn'),
              onPressed: onAddSubject,
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                ),
              ),
            );
          }

          // 3. Các Chip Môn học cụ thể
          final subject = subjects[index - 1];
          final isSelected = selectedSubjectId == subject.subjectPk;

          return FilterChip(
            avatar: Icon(
              subject.iconData,
              size: 16,
              color: isSelected ? Colors.white : subject.colorValue,
            ),
            label: Text(subject.code),
            tooltip: subject.name,
            selected: isSelected,
            onSelected: (_) => onSelected(subject.subjectPk),
            showCheckmark: false,
            selectedColor: subject.colorValue,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : subject.colorValue.withValues(alpha: 0.4),
              ),
            ),
          );
        },
      ),
    );
  }
}
