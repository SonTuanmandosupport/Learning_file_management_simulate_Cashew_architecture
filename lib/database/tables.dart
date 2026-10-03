/// Định nghĩa cấu trúc bảng và tên cột dữ liệu trong hệ thống (Tương tự Drift Tables của Cashew)
library;

class SubjectTable {
  static const String tableName = 'subjects';
  static const String columnSubjectPk = 'subjectPk';
  static const String columnName = 'name';
  static const String columnCode = 'code';
  static const String columnColour = 'colour';
  static const String columnIconName = 'iconName';
  static const String columnCreatedAt = 'createdAt';
}

class DocumentTypeTable {
  static const String tableName = 'document_types';
  static const String columnTypePk = 'typePk';
  static const String columnName = 'name';
  static const String columnColour = 'colour';
  static const String columnIconName = 'iconName';
}

class DocumentTable {
  static const String tableName = 'documents';
  static const String columnDocumentPk = 'documentPk';
  static const String columnTitle = 'title';
  static const String columnNote = 'note';
  static const String columnSubjectFk = 'subjectFk';
  static const String columnDocumentTypeFk = 'documentTypeFk';
  static const String columnFileUrl = 'fileUrl';
  static const String columnIsFavorite = 'isFavorite';
  static const String columnCreatedAt = 'createdAt';
  static const String columnUpdatedAt = 'updatedAt';
}
