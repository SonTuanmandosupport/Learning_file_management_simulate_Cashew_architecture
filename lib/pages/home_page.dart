import 'package:flutter/material.dart';
import '../struct/app_state.dart';
import '../struct/models.dart';
import '../struct/settings.dart';
import '../widgets/add_subject_dialog.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/document_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/subject_chip.dart';
import '../widgets/theme_customizer_sheet.dart';
import 'add_edit_document_page.dart';
import 'document_detail_page.dart';
import 'manage_subjects_page.dart';

/// Trang chính Dashboard quản lý tài liệu học tập
class HomePage extends StatefulWidget {
  final DocumentManagerNotifier appState;
  final AppSettings settings;

  const HomePage({
    super.key,
    required this.appState,
    required this.settings,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = widget.appState;
    final settings = widget.settings;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.menu_book_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            const Text(
              'Tài Liệu Học Tập',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ],
        ),
        actions: [
          // Nút lọc nhanh tài liệu yêu thích
          IconButton(
            icon: Icon(
              appState.favoriteOnly
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: appState.favoriteOnly ? const Color(0xFFFFB300) : null,
            ),
            tooltip: appState.favoriteOnly ? 'Xem tất cả' : 'Chỉ xem Yêu thích',
            onPressed: () => appState.toggleFavoriteFilter(),
          ),

          // Nút Quản lý Môn học
          IconButton(
            icon: const Icon(Icons.school_outlined),
            tooltip: 'Quản lý môn học',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ManageSubjectsPage(appState: appState),
                ),
              );
            },
          ),

          // Nút cá nhân hóa màu sắc & giao diện
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Đổi màu giao diện & Cá nhân hóa',
            onPressed: () => ThemeCustomizerSheet.show(context, settings: settings),
          ),

          // Nút chuyển chế độ Sáng / Tối
          IconButton(
            icon: Icon(
              settings.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            tooltip: settings.isDarkMode ? 'Chế độ Sáng' : 'Chế độ Tối',
            onPressed: () => settings.toggleTheme(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Thanh tìm kiếm thời gian thực
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: SearchBarWidget(
              initialValue: appState.searchQuery,
              onChanged: (val) => appState.setSearchQuery(val),
              onClear: () => appState.setSearchQuery(''),
            ),
          ),

          // 2. Bộ lọc môn học dạng chip cuộn ngang kèm nút "+ Thêm môn"
          SubjectFilterChipList(
            subjects: appState.subjects,
            selectedSubjectId: appState.selectedSubjectId,
            onSelected: (id) => appState.setSelectedSubject(id),
            onAddSubject: () => AddSubjectDialog.show(context, appState: appState),
          ),

          const SizedBox(height: 8),

          // 3. Thanh thông tin tóm tắt & reset bộ lọc nếu có
          if (appState.searchQuery.isNotEmpty ||
              appState.selectedSubjectId != 'all' ||
              appState.favoriteOnly)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt_outlined, size: 16, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(
                    'Đang áp dụng bộ lọc',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => appState.resetFilters(),
                    child: Text(
                      'Xóa bộ lọc',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 4. Danh sách tài liệu phản ứng thời gian thực qua StreamBuilder
          Expanded(
            child: StreamBuilder<List<DocumentItem>>(
              stream: appState.currentFilteredStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final documents = snapshot.data ?? [];

                if (documents.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.search_off_rounded,
                              size: 56,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không tìm thấy tài liệu nào',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            appState.searchQuery.isNotEmpty ||
                                    appState.selectedSubjectId != 'all'
                                ? 'Thử thay đổi từ khóa hoặc xóa bớt bộ lọc.'
                                : 'Nhấn nút "+" bên dưới để tạo tài liệu mới.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 6, bottom: 84),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    final subject = appState.getSubject(doc.subjectFk);
                    final documentType =
                        appState.getDocumentType(doc.documentTypeFk);

                    return DocumentCard(
                      document: doc,
                      subject: subject,
                      documentType: documentType,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DocumentDetailPage(
                              appState: appState,
                              documentPk: doc.documentPk,
                            ),
                          ),
                        );
                      },
                      onToggleFavorite: () {
                        appState.toggleFavorite(doc.documentPk);
                      },
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddEditDocumentPage(
                              appState: appState,
                              documentToEdit: doc,
                            ),
                          ),
                        );
                      },
                      onDelete: () => _handleDelete(doc),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddEditDocumentPage(appState: appState),
            ),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Thêm tài liệu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
