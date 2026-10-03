import 'package:flutter/material.dart';

/// Danh mục icon chuyên ngành học thuật
class SubjectIconCategory {
  final String categoryName;
  final List<SubjectIconInfo> icons;

  const SubjectIconCategory({
    required this.categoryName,
    required this.icons,
  });
}

class SubjectIconInfo {
  final String name;
  final String label;
  final IconData icon;

  const SubjectIconInfo({
    required this.name,
    required this.label,
    required this.icon,
  });
}

/// Kho 50+ biểu tượng chuyên ngành đa dạng theo các lĩnh vực học thuật
class SubjectIcons {
  static const List<SubjectIconCategory> categories = [
    // 1. Kinh tế, Tài chính & Quản trị kinh doanh
    SubjectIconCategory(
      categoryName: 'Kinh Tế & Tài Chính',
      icons: [
        SubjectIconInfo(name: 'account_balance', label: 'Ngân hàng / Tài chính', icon: Icons.account_balance_rounded),
        SubjectIconInfo(name: 'trending_up', label: 'Tăng trưởng / Chứng khoán', icon: Icons.trending_up_rounded),
        SubjectIconInfo(name: 'attach_money', label: 'Tiền tệ / Ngân sách', icon: Icons.attach_money_rounded),
        SubjectIconInfo(name: 'bar_chart', label: 'Kinh tế lượng / Biểu đồ', icon: Icons.bar_chart_rounded),
        SubjectIconInfo(name: 'pie_chart', label: 'Thị phần / Phân tích', icon: Icons.pie_chart_rounded),
        SubjectIconInfo(name: 'store', label: 'Thương mại / Bán lẻ', icon: Icons.store_rounded),
        SubjectIconInfo(name: 'analytics', label: 'Kinh doanh / Analytics', icon: Icons.analytics_rounded),
        SubjectIconInfo(name: 'payments', label: 'Kế toán / Thanh toán', icon: Icons.payments_rounded),
      ],
    ),

    // 2. Toán học & Thống kê
    SubjectIconCategory(
      categoryName: 'Toán Học & Thống Kê',
      icons: [
        SubjectIconInfo(name: 'calculate', label: 'Toán cao cấp / Đại số', icon: Icons.calculate_rounded),
        SubjectIconInfo(name: 'functions', label: 'Giải tích / Hàm số', icon: Icons.functions_rounded),
        SubjectIconInfo(name: 'percent', label: 'Xác suất / Tỷ lệ', icon: Icons.percent_rounded),
        SubjectIconInfo(name: 'square_foot', label: 'Hình học không gian', icon: Icons.square_foot_rounded),
        SubjectIconInfo(name: 'timeline', label: 'Chuỗi thời gian / Đồ thị', icon: Icons.timeline_rounded),
        SubjectIconInfo(name: 'iso', label: 'Đồng cấu / Tối ưu hóa', icon: Icons.iso_rounded),
        SubjectIconInfo(name: 'straighten', label: 'Đo lường / Giải thuật số', icon: Icons.straighten_rounded),
      ],
    ),

    // 3. Hóa học, Sinh học & Y Dược
    SubjectIconCategory(
      categoryName: 'Hóa Học & Y Sinh',
      icons: [
        SubjectIconInfo(name: 'science', label: 'Hóa học / Thí nghiệm', icon: Icons.science_rounded),
        SubjectIconInfo(name: 'biotech', label: 'Công nghệ sinh học / DNA', icon: Icons.biotech_rounded),
        SubjectIconInfo(name: 'bubble_chart', label: 'Cấu trúc phân tử', icon: Icons.bubble_chart_rounded),
        SubjectIconInfo(name: 'sanitizer', label: 'Dược phẩm / Hóa sinh', icon: Icons.sanitizer_rounded),
        SubjectIconInfo(name: 'eco', label: 'Sinh thái học / Thực vật', icon: Icons.eco_rounded),
        SubjectIconInfo(name: 'water_drop', label: 'Hóa lỏng / Môi trường', icon: Icons.water_drop_rounded),
        SubjectIconInfo(name: 'local_hospital', label: 'Y học lâm sàng', icon: Icons.local_hospital_rounded),
        SubjectIconInfo(name: 'medical_services', label: 'Dịch tễ học / Y tế', icon: Icons.medical_services_rounded),
      ],
    ),

    // 4. Triết học, Xã hội, Luật & Ngôn ngữ
    SubjectIconCategory(
      categoryName: 'Triết Học, Luật & Xã Hội',
      icons: [
        SubjectIconInfo(name: 'psychology', label: 'Triết học / Tâm lý học', icon: Icons.psychology_rounded),
        SubjectIconInfo(name: 'gavel', label: 'Luật học / Pháp chế', icon: Icons.gavel_rounded),
        SubjectIconInfo(name: 'balance', label: 'Công lý / Đạo đức học', icon: Icons.balance_rounded),
        SubjectIconInfo(name: 'history_edu', label: 'Lịch sử văn minh', icon: Icons.history_edu_rounded),
        SubjectIconInfo(name: 'auto_stories', label: 'Văn học / Ngữ văn', icon: Icons.auto_stories_rounded),
        SubjectIconInfo(name: 'record_voice_over', label: 'Hùng biện / Truyền thông', icon: Icons.record_voice_over_rounded),
        SubjectIconInfo(name: 'translate', label: 'Ngôn ngữ học / Ngoại ngữ', icon: Icons.translate_rounded),
        SubjectIconInfo(name: 'lightbulb', label: 'Tư duy logic / Ý tưởng', icon: Icons.lightbulb_rounded),
      ],
    ),

    // 5. Vật lý & Kỹ thuật công nghiệp
    SubjectIconCategory(
      categoryName: 'Vật Lý & Kỹ Thuật',
      icons: [
        SubjectIconInfo(name: 'electric_bolt', label: 'Vật lý điện tử', icon: Icons.electric_bolt_rounded),
        SubjectIconInfo(name: 'bolt', label: 'Điện từ trường', icon: Icons.bolt_rounded),
        SubjectIconInfo(name: 'precision_manufacturing', label: 'Cơ khí chính xác', icon: Icons.precision_manufacturing_rounded),
        SubjectIconInfo(name: 'engineering', label: 'Kỹ thuật công nghiệp', icon: Icons.engineering_rounded),
        SubjectIconInfo(name: 'hardware', label: 'Vật liệu bán dẫn', icon: Icons.hardware_rounded),
        SubjectIconInfo(name: 'speed', label: 'Cơ học chất lưu / Động lực', icon: Icons.speed_rounded),
        SubjectIconInfo(name: 'thermostat', label: 'Nhiệt động lực học', icon: Icons.thermostat_rounded),
        SubjectIconInfo(name: 'waves', label: 'Vật lý sóng / Quang học', icon: Icons.waves_rounded),
      ],
    ),

    // 6. Vũ trụ học, Thiên văn & Địa lý
    SubjectIconCategory(
      categoryName: 'Vũ Trụ & Địa Lý',
      icons: [
        SubjectIconInfo(name: 'rocket_launch', label: 'Vũ trụ học / Hàng không', icon: Icons.rocket_launch_rounded),
        SubjectIconInfo(name: 'public', label: 'Địa lý thế giới / Bản đồ', icon: Icons.public_rounded),
        SubjectIconInfo(name: 'satellite_alt', label: 'Viễn thám / Vệ tinh', icon: Icons.satellite_alt_rounded),
        SubjectIconInfo(name: 'nights_stay', label: 'Thiên văn học / Ban đêm', icon: Icons.nights_stay_rounded),
        SubjectIconInfo(name: 'wb_sunny', label: 'Vật lý mặt trời / Bức xạ', icon: Icons.wb_sunny_rounded),
        SubjectIconInfo(name: 'terrain', label: 'Địa chất học / Khoáng sản', icon: Icons.terrain_rounded),
        SubjectIconInfo(name: 'explore', label: 'Khảo sát địa hình', icon: Icons.explore_rounded),
        SubjectIconInfo(name: 'travel_explore', label: 'Hải dương học / Khám phá', icon: Icons.travel_explore_rounded),
      ],
    ),

    // 7. Khoa học Máy tính & Công nghệ thông tin
    SubjectIconCategory(
      categoryName: 'Khoa Học Máy Tính & CNTT',
      icons: [
        SubjectIconInfo(name: 'code', label: 'Lập trình / Cấu trúc dữ liệu', icon: Icons.code_rounded),
        SubjectIconInfo(name: 'phone_android', label: 'Lập trình di động', icon: Icons.phone_android_rounded),
        SubjectIconInfo(name: 'computer', label: 'Kiến trúc máy tính', icon: Icons.computer_rounded),
        SubjectIconInfo(name: 'terminal', label: 'Hệ điều hành / Linux', icon: Icons.terminal_rounded),
        SubjectIconInfo(name: 'hub', label: 'Mạng máy tính & Viễn thông', icon: Icons.hub_rounded),
        SubjectIconInfo(name: 'memory', label: 'Hệ thống nhúng / IoT', icon: Icons.memory_rounded),
        SubjectIconInfo(name: 'cloud', label: 'Điện toán đám mây', icon: Icons.cloud_rounded),
        SubjectIconInfo(name: 'security', label: 'An toàn thông tin / Bảo mật', icon: Icons.security_rounded),
      ],
    ),

    // 8. Nghệ thuật, Thiết kế & Giáo dục
    SubjectIconCategory(
      categoryName: 'Nghệ Thuật & Giáo Dục',
      icons: [
        SubjectIconInfo(name: 'palette', label: 'Mỹ thuật / Thiết kế đồ họa', icon: Icons.palette_rounded),
        SubjectIconInfo(name: 'music_note', label: 'Âm nhạc / Lý thuyết nhạc', icon: Icons.music_note_rounded),
        SubjectIconInfo(name: 'school', label: 'Giáo dục học / Sư phạm', icon: Icons.school_rounded),
        SubjectIconInfo(name: 'menu_book', label: 'Nghiên cứu tài liệu chung', icon: Icons.menu_book_rounded),
      ],
    ),
  ];

  /// Tra cứu IconData theo mã tên icon
  static IconData getIcon(String name) {
    for (final cat in categories) {
      for (final item in cat.icons) {
        if (item.name == name) return item.icon;
      }
    }
    return Icons.school_rounded; // Default fallback
  }
}
