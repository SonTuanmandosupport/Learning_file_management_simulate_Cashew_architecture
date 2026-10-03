import 'package:flutter/material.dart';

/// Lựa chọn màu sắc cá nhân hóa
class ColorOption {
  final String name;
  final Color color;

  const ColorOption({required this.name, required this.color});
}

/// Quản lý cấu hình người dùng và cá nhân hóa giao diện (Tương tự struct/settings.dart trong Cashew)
class AppSettings extends ChangeNotifier {
  // Singleton pattern
  static final AppSettings _instance = AppSettings._internal();
  factory AppSettings() => _instance;

  AppSettings._internal();

  bool _isDarkMode = false;
  bool _isGridView = false;
  String _sortBy = 'updatedAt'; // 'updatedAt' hoặc 'title'
  Color _primaryColor = const Color(0xFF1E88E5); // Mặc định xanh dương Cashew

  // Danh sách các bảng màu cá nhân hóa có sẵn
  static const List<ColorOption> availableColors = [
    ColorOption(name: 'Xanh Dương', color: Color(0xFF1E88E5)),
    ColorOption(name: 'Tím Hoàng Gia', color: Color(0xFF8E24AA)),
    ColorOption(name: 'Xanh Ngọc (Teal)', color: Color(0xFF00897B)),
    ColorOption(name: 'Cam Hoàng Hôn', color: Color(0xFFFB8C00)),
    ColorOption(name: 'Đỏ Ruby', color: Color(0xFFE53935)),
    ColorOption(name: 'Xanh Chàm (Indigo)', color: Color(0xFF3949AB)),
    ColorOption(name: 'Xanh Lá Tươi', color: Color(0xFF43A047)),
    ColorOption(name: 'Hồng Fuchsia', color: Color(0xFFD81B60)),
  ];

  bool get isDarkMode => _isDarkMode;
  bool get isGridView => _isGridView;
  String get sortBy => _sortBy;
  Color get primaryColor => _primaryColor;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    if (_primaryColor != color) {
      _primaryColor = color;
      notifyListeners();
    }
  }

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }
}
