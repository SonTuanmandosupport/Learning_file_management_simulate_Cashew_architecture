import 'package:flutter/material.dart';

/// Bảng màu và phong cách chuẩn Material 3 theo thiết kế Cashew
class AppColors {
  // Màu chủ đạo
  static const Color primary = Color(0xFF1E88E5); // Xanh dương tươi sáng
  static const Color primaryContainer = Color(0xFFD2E4FF);
  static const Color secondary = Color(0xFF5E5CE6);
  static const Color accent = Color(0xFF00B0FF);

  // Màu trạng thái
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFB8C00);
  static const Color error = Color(0xFFE53935);
  static const Color favorite = Color(0xFFFFB300); // Vàng ghim sao

  // Bảng màu cho các môn học (Subjects)
  static const List<Color> subjectColors = [
    Color(0xFF1E88E5), // Blue
    Color(0xFF8E24AA), // Purple
    Color(0xFF00897B), // Teal
    Color(0xFFFB8C00), // Orange
    Color(0xFFE53935), // Red
    Color(0xFF3949AB), // Indigo
    Color(0xFF43A047), // Green
  ];

  // Bảng màu cho các loại tài liệu (DocumentTypes)
  static const Map<String, Color> typeColors = {
    'slide': Color(0xFFFB8C00), // Cam (Bài giảng/Slide)
    'lab': Color(0xFF1E88E5),   // Xanh (Bài tập/Lab)
    'book': Color(0xFF8E24AA),  // Tím (Sách/Ebook)
    'exam': Color(0xFFE53935),  // Đỏ (Đề thi)
  };
}
