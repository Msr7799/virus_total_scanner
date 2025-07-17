// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/scan_result.dart';

class AppTheme {
  // الألوان الأساسية
  static const Color primaryColor = Color(Constants.primaryColor);
  static const Color secondaryColor = Color(Constants.secondaryColor);
  static const Color errorColor = Color(Constants.errorColor);
  static const Color warningColor = Color(Constants.warningColor);
  static const Color successColor = Color(Constants.successColor);

  // الثيم الفاتح
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // نظام الألوان
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        error: errorColor,
      ),
      
      // شريط التطبيق
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      
      // الكروت - استخدام CardThemeData بدلاً من CardTheme
      cardTheme: CardThemeData(
        elevation: Constants.defaultElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
        ),
        margin: const EdgeInsets.all(Constants.defaultPadding / 2),
      ),
      
      // الأزرار المرفوعة
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: Constants.defaultElevation,
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.defaultPadding * 1.5,
            vertical: Constants.defaultPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // الأزرار المحددة
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.defaultPadding * 1.5,
            vertical: Constants.defaultPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
          ),
        ),
      ),
      
      // الأزرار النصية
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.defaultPadding,
            vertical: Constants.defaultPadding / 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Constants.defaultBorderRadius / 2),
          ),
        ),
      ),
      
      // حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(Constants.defaultPadding),
      ),
      
      // مفاتيح التبديل
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.grey[400];
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return Colors.grey[300];
        }),
      ),
      
      // أشرطة التقدم
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: Colors.grey,
      ),
      
      // أنماط النص
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.black54,
        ),
      ),
      
      // أيقونات
      iconTheme: const IconThemeData(
        color: Colors.black87,
        size: 24,
      ),
      
      // قوائم البلاط
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: Constants.defaultPadding,
          vertical: Constants.defaultPadding / 2,
        ),
        iconColor: primaryColor,
      ),
      
      // أشرطة التمرير
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(primaryColor.withOpacity(0.5)),
        trackColor: WidgetStateProperty.all(Colors.grey[200]),
        radius: const Radius.circular(Constants.defaultBorderRadius / 2),
      ),
    );
  }

  // الثيم الداكن
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // نظام الألوان الداكن
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        error: errorColor,
      ),
      
      // شريط التطبيق الداكن
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      
      // الكروت الداكنة
      cardTheme: CardThemeData(
        elevation: Constants.defaultElevation,
        color: Colors.grey[850],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
        ),
        margin: const EdgeInsets.all(Constants.defaultPadding / 2),
      ),
      
      // الأزرار المرفوعة الداكنة
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: Constants.defaultElevation,
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.defaultPadding * 1.5,
            vertical: Constants.defaultPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // حقول الإدخال الداكنة
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(Constants.defaultPadding),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
      ),
      
      // أنماط النص الداكنة
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.white70,
        ),
      ),
      
      // أيقونات داكنة
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
    );
  }

  // ألوان مخصصة للتهديدات
  static const Map<ThreatLevel, Color> threatColors = {
    ThreatLevel.safe: successColor,
    ThreatLevel.medium: warningColor,
    ThreatLevel.high: errorColor,
  };

  // أيقونات مخصصة للتهديدات
  static const Map<ThreatLevel, IconData> threatIcons = {
    ThreatLevel.safe: Icons.verified_user,
    ThreatLevel.medium: Icons.warning,
    ThreatLevel.high: Icons.dangerous,
  };

  // أنماط مخصصة للكروت
  static BoxDecoration cardDecoration(BuildContext context, {Color? borderColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BoxDecoration(
      color: isDark ? Colors.grey[850] : Colors.white,
      borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
      border: borderColor != null 
          ? Border.all(color: borderColor, width: 1)
          : null,
      boxShadow: [
        BoxShadow(
          color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
          blurRadius: Constants.defaultElevation,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // أنماط التدرج
  static LinearGradient get primaryGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor,
        primaryColor.withOpacity(0.8),
      ],
    );
  }

  static LinearGradient get dangerGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        errorColor,
        errorColor.withOpacity(0.8),
      ],
    );
  }

  static LinearGradient get warningGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        warningColor,
        warningColor.withOpacity(0.8),
      ],
    );
  }

  static LinearGradient get successGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        successColor,
        successColor.withOpacity(0.8),
      ],
    );
  }

  // أنماط النصوص المخصصة
  static TextStyle get titleStyle {
    return const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );
  }

  static TextStyle get subtitleStyle {
    return const TextStyle(
      fontSize: 14,
      color: Colors.black54,
    );
  }

  static TextStyle get captionStyle {
    return const TextStyle(
      fontSize: 12,
      color: Colors.black45,
    );
  }

  // أنماط الأزرار المخصصة
  static ButtonStyle get dangerButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: errorColor,
      foregroundColor: Colors.white,
      elevation: Constants.defaultElevation,
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.defaultPadding * 1.5,
        vertical: Constants.defaultPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
      ),
    );
  }

  static ButtonStyle get warningButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: warningColor,
      foregroundColor: Colors.white,
      elevation: Constants.defaultElevation,
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.defaultPadding * 1.5,
        vertical: Constants.defaultPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
      ),
    );
  }

  static ButtonStyle get successButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: successColor,
      foregroundColor: Colors.white,
      elevation: Constants.defaultElevation,
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.defaultPadding * 1.5,
        vertical: Constants.defaultPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
      ),
    );
  }

  // مساحات ثابتة
  static const SizedBox smallVerticalSpace = SizedBox(height: 8);
  static const SizedBox mediumVerticalSpace = SizedBox(height: 16);
  static const SizedBox largeVerticalSpace = SizedBox(height: 24);
  
  static const SizedBox smallHorizontalSpace = SizedBox(width: 8);
  static const SizedBox mediumHorizontalSpace = SizedBox(width: 16);
  static const SizedBox largeHorizontalSpace = SizedBox(width: 24);
}