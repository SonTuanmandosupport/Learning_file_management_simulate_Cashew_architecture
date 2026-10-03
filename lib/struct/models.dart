import 'package:flutter/material.dart';
import 'subject_icons.dart';

/// Đại diện cho một Môn học / Học phần trong hệ thống (Tương tự Wallet trong Cashew)
class SubjectItem {
  final String subjectPk;
  final String name;
  final String code;
  final String colour;
  final String iconName;
  final DateTime createdAt;

  const SubjectItem({
    required this.subjectPk,
    required this.name,
    required this.code,
    required this.colour,
    required this.iconName,
    required this.createdAt,
  });

  Color get colorValue {
    try {
      return Color(int.parse(colour));
    } catch (_) {
      return const Color(0xFF1E88E5);
    }
  }

  IconData get iconData {
    return SubjectIcons.getIcon(iconName);
  }

  SubjectItem copyWith({
    String? subjectPk,
    String? name,
    String? code,
    String? colour,
    String? iconName,
    DateTime? createdAt,
  }) {
    return SubjectItem(
      subjectPk: subjectPk ?? this.subjectPk,
      name: name ?? this.name,
      code: code ?? this.code,
      colour: colour ?? this.colour,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subjectPk': subjectPk,
      'name': name,
      'code': code,
      'colour': colour,
      'iconName': iconName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SubjectItem.fromMap(Map<String, dynamic> map) {
    return SubjectItem(
      subjectPk: map['subjectPk'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
      colour: map['colour'] as String,
      iconName: map['iconName'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

/// Đại diện cho Loại tài liệu (Tương tự Category trong Cashew)
class DocumentTypeItem {
  final String typePk;
  final String name;
  final String colour;
  final String iconName;

  const DocumentTypeItem({
    required this.typePk,
    required this.name,
    required this.colour,
    required this.iconName,
  });

  Color get colorValue {
    try {
      return Color(int.parse(colour));
    } catch (_) {
      return const Color(0xFFFB8C00);
    }
  }

  IconData get iconData {
    switch (iconName) {
      case 'slideshow':
        return Icons.slideshow_rounded;
      case 'assignment':
        return Icons.assignment_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'quiz':
        return Icons.quiz_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'typePk': typePk,
      'name': name,
      'colour': colour,
      'iconName': iconName,
    };
  }

  factory DocumentTypeItem.fromMap(Map<String, dynamic> map) {
    return DocumentTypeItem(
      typePk: map['typePk'] as String,
      name: map['name'] as String,
      colour: map['colour'] as String,
      iconName: map['iconName'] as String,
    );
  }
}

/// Đại diện cho Thực thể Tài liệu học tập (Tương tự Transaction trong Cashew)
class DocumentItem {
  final String documentPk;
  final String title;
  final String note;
  final String subjectFk;
  final String documentTypeFk;
  final String fileUrl;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DocumentItem({
    required this.documentPk,
    required this.title,
    required this.note,
    required this.subjectFk,
    required this.documentTypeFk,
    required this.fileUrl,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  DocumentItem copyWith({
    String? documentPk,
    String? title,
    String? note,
    String? subjectFk,
    String? documentTypeFk,
    String? fileUrl,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentItem(
      documentPk: documentPk ?? this.documentPk,
      title: title ?? this.title,
      note: note ?? this.note,
      subjectFk: subjectFk ?? this.subjectFk,
      documentTypeFk: documentTypeFk ?? this.documentTypeFk,
      fileUrl: fileUrl ?? this.fileUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'documentPk': documentPk,
      'title': title,
      'note': note,
      'subjectFk': subjectFk,
      'documentTypeFk': documentTypeFk,
      'fileUrl': fileUrl,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DocumentItem.fromMap(Map<String, dynamic> map) {
    return DocumentItem(
      documentPk: map['documentPk'] as String,
      title: map['title'] as String,
      note: map['note'] as String,
      subjectFk: map['subjectFk'] as String,
      documentTypeFk: map['documentTypeFk'] as String,
      fileUrl: map['fileUrl'] as String,
      isFavorite: map['isFavorite'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
