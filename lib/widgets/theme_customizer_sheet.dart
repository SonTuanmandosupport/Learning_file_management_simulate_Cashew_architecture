import 'package:flutter/material.dart';
import '../struct/settings.dart';

/// BottomSheet cá nhân hóa giao diện và màu nền chủ đạo
class ThemeCustomizerSheet extends StatelessWidget {
  final AppSettings settings;

  const ThemeCustomizerSheet({super.key, required this.settings});

  static Future<void> show(BuildContext context, {required AppSettings settings}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ThemeCustomizerSheet(settings: settings),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh kéo
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: settings.primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.palette_rounded, color: settings.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Cá Nhân Hóa Giao Diện',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Chế độ Sáng / Tối
              const Text(
                'Chế độ hiển thị',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: !settings.isDarkMode
                            ? settings.primaryColor.withValues(alpha: 0.12)
                            : null,
                        side: BorderSide(
                          color: !settings.isDarkMode
                              ? settings.primaryColor
                              : Colors.grey.withValues(alpha: 0.3),
                          width: !settings.isDarkMode ? 2 : 1,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (settings.isDarkMode) settings.toggleTheme();
                      },
                      icon: Icon(
                        Icons.light_mode_rounded,
                        color: !settings.isDarkMode
                            ? settings.primaryColor
                            : null,
                      ),
                      label: Text(
                        'Chế độ Sáng',
                        style: TextStyle(
                          color: !settings.isDarkMode
                              ? settings.primaryColor
                              : null,
                          fontWeight: !settings.isDarkMode
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: settings.isDarkMode
                            ? settings.primaryColor.withValues(alpha: 0.12)
                            : null,
                        side: BorderSide(
                          color: settings.isDarkMode
                              ? settings.primaryColor
                              : Colors.grey.withValues(alpha: 0.3),
                          width: settings.isDarkMode ? 2 : 1,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (!settings.isDarkMode) settings.toggleTheme();
                      },
                      icon: Icon(
                        Icons.dark_mode_rounded,
                        color: settings.isDarkMode
                            ? settings.primaryColor
                            : null,
                      ),
                      label: Text(
                        'Chế độ Tối',
                        style: TextStyle(
                          color: settings.isDarkMode
                              ? settings.primaryColor
                              : null,
                          fontWeight: settings.isDarkMode
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bảng màu chủ đạo / màu nền
              const Text(
                'Màu nền chủ đạo (Theme Primary Color)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Tự động đồng bộ màu sắc thanh điều hướng, các nút bấm và điểm nhấn giao diện',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: AppSettings.availableColors.map((option) {
                  final isSelected = settings.primaryColor == option.color;
                  return GestureDetector(
                    onTap: () => settings.setPrimaryColor(option.color),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: option.color.withValues(alpha: isSelected ? 0.2 : 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? option.color
                              : Colors.grey.withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: option.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            option.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? option.color : null,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.check, size: 16, color: option.color),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
