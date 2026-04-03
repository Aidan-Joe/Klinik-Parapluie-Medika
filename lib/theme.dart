import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  CLINIC PARAPLUIE MEDIKA — DESIGN SYSTEM
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Brand palette
  static const Color darkGreen = Color(0xFF00261B);
  static const Color midGreen = Color(0xFF0A3D2E);
  static const Color accentGreen = Color(0xFF6BFF8F);

  // Surface
  static const Color background = Color(0xFFF5F7F5);
  static const Color cardWhite = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF1A3A2A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textOnDark = Colors.white;
  static const Color textOnDarkMuted = Color(0x99FFFFFF); // white60

  // Status
  static const Color statusScheduled = Color(0xFF3B82F6); // blue
  static const Color statusCompleted = Color(0xFF22C55E); // green
  static const Color statusCancelled = Color(0xFFEF4444); // red
  static const Color statusDefault = Color(0xFFF97316); // orange

  // Accent icons
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentPurple = Color(0xFFA855F7);
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color accentRed = Color(0xFFEF4444);
}

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGreen,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGreen,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGreen,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.darkGreen,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    color: AppColors.textMuted,
  );

  // On-dark variants
  static const TextStyle headingOnDark = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textOnDark,
  );

  static const TextStyle captionOnDark = TextStyle(
    fontSize: 13,
    color: AppColors.textOnDarkMuted,
  );
}

class AppDecorations {
  AppDecorations._();

  static BoxDecoration card = BoxDecoration(
    color: AppColors.cardWhite,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.07),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration cardFlat = BoxDecoration(
    color: AppColors.cardWhite,
    borderRadius: BorderRadius.circular(14),
  );

  static BoxDecoration darkCard = BoxDecoration(
    color: AppColors.darkGreen,
    borderRadius: BorderRadius.circular(18),
  );

  static BoxDecoration headerGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.darkGreen, AppColors.midGreen],
    ),
  );

  static BoxDecoration iconBadge(Color color) => BoxDecoration(
    color: color.withOpacity(0.12),
    borderRadius: BorderRadius.circular(10),
  );

  static BoxDecoration statusBadge(Color color) => BoxDecoration(
    color: color.withOpacity(0.15),
    borderRadius: BorderRadius.circular(20),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATUS HELPERS
// ─────────────────────────────────────────────────────────────────────────────

Color appointmentStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'scheduled':
      return AppColors.statusScheduled;
    case 'completed':
      return AppColors.statusCompleted;
    case 'cancelled':
      return AppColors.statusCancelled;
    default:
      return AppColors.statusDefault;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PHOTO URL HELPER
// ─────────────────────────────────────────────────────────────────────────────

String? photoUrl(String? filename) {
  if (filename == null || filename.trim().isEmpty) return null;
  // Remove trailing "/api" (with optional slash) to get the bare server root.
  final serverRoot = ApiService.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
  return '$serverRoot/uploads/avatars/$filename';
}

// ─────────────────────────────────────────────────────────────────────────────
//  MATERIALAPP THEME
// ─────────────────────────────────────────────────────────────────────────────

ThemeData get appTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: AppColors.darkGreen,
    secondary: AppColors.accentGreen,
    surface: AppColors.background,
  ),
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.darkGreen,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkGreen,
      foregroundColor: AppColors.accentGreen,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.darkGreen,
      side: BorderSide(color: AppColors.darkGreen.withOpacity(0.4)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.darkGreen,
    foregroundColor: AppColors.accentGreen,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  tabBarTheme: TabBarThemeData(
    indicatorColor: AppColors.accentGreen,
    labelColor: AppColors.accentGreen,
    unselectedLabelColor: Color(0x99FFFFFF),
    labelStyle: TextStyle(fontWeight: FontWeight.w600),
  ),
  dividerTheme: DividerThemeData(
    color: Color(0xFFF0F0F0),
    thickness: 1,
    space: 0,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
);
