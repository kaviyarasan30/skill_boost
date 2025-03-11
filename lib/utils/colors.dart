import 'package:flutter/material.dart';

// Premium educational app color scheme
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF4A55A2); // Deep blue
  static const Color primaryDark = Color(0xFF364278); // Darker blue
  static const Color primaryLight = Color(0xFF7986CB); // Lighter blue

  // Accent colors
  static const Color accent = Color(0xFF4ECDC4); // Teal
  static const Color accentLight = Color(0xFF80DEEA); // Light teal

  // Text colors
  static const Color textPrimary = Color(0xFF2C3E50); // Dark blue-gray
  static const Color textSecondary = Color(0xFF7F8C8D); // Medium gray
  static const Color textLight = Color(0xFFBDC3C7); // Light gray

  // Background colors
  static const Color background = Color(0xFFF8F9FA); // Off-white
  static const Color surface = Colors.white; // Pure white
  static const Color cardBg = Colors.white; // Card background

  // Difficulty level colors
  static const Color basicLevel = Color(0xFF4ECDC4); // Teal
  static const Color intermediateLevel = Color(0xFFFFA41B); // Orange
  static const Color advancedLevel = Color(0xFFFF6B6B); // Red-pink

  // Status colors
  static const Color success = Color(0xFF2ECC71); // Green
  static const Color warning = Color(0xFFF39C12); // Amber
  static const Color error = Color(0xFFE74C3C); // Red
  static const Color info = Color(0xFF3498DB); // Blue

  // Shadow and overlay
  static const Color shadow = Color(0x1A000000); // Black with 10% opacity
  static const Color overlay = Color(0x80000000);
  static const Color dark = Color(0xFF000000);
}

// Text styles for the app
class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: AppColors.dark,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );
}

// App theme data
// class AppTheme {
//   static ThemeData get lightTheme {
//     return ThemeData(
//       primaryColor: AppColors.primary,
//       primaryColorDark: AppColors.primaryDark,
//       primaryColorLight: AppColors.primaryLight,
//       colorScheme: const ColorScheme.light(
//         primary: AppColors.primary,
//         secondary: AppColors.accent,
//         surface: AppColors.surface,
//         background: AppColors.background,
//         error: AppColors.error,
//       ),
//       scaffoldBackgroundColor: AppColors.background,
//       appBarTheme: const AppBarTheme(
//         backgroundColor: AppColors.surface,
//         elevation: 0,
//         centerTitle: false,
//         iconTheme: IconThemeData(color: AppColors.textPrimary),
//         titleTextStyle: AppTextStyles.headline3,
//       ),
//       textTheme: const TextTheme(
//         headlineLarge: AppTextStyles.headline1,
//         headlineMedium: AppTextStyles.headline2,
//         headlineSmall: AppTextStyles.headline3,
//         titleLarge: AppTextStyles.subtitle1,
//         titleMedium: AppTextStyles.subtitle2,
//         bodyLarge: AppTextStyles.bodyText1,
//         bodyMedium: AppTextStyles.bodyText2,
//         labelLarge: AppTextStyles.button,
//         bodySmall: AppTextStyles.caption,
//       ),
//       cardTheme: CardTheme(
//         color: AppColors.surface,
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         shadowColor: AppColors.shadow,
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.accent,
//           foregroundColor: Colors.white,
//           elevation: 2,
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           textStyle: AppTextStyles.button,
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: AppColors.surface,
//         hintStyle: AppTextStyles.bodyText2,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: AppColors.textLight.withOpacity(0.5)),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: AppColors.textLight.withOpacity(0.5)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: AppColors.accent, width: 2),
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       ),
//     );
//   }
// }
