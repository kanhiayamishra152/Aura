import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // --- Dark Theme ---
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.primaryGreen,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryGreen,
      secondary: AppColors.accentGreen,
      surface: AppColors.darkSurface,
      error: AppColors.error,
      onPrimary: AppColors.darkBackground,
      onSecondary: AppColors.darkBackground,
      onSurface: AppColors.darkTextPrimary,
      onError: Colors.white,
    ),
    fontFamily: 'PoppinsRegular',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      titleTextStyle: TextStyle(
        fontFamily: 'PoppinsBold',
        fontSize: 20,
        color: AppColors.darkTextPrimary,
        fontWeight: FontWeight.w700,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.darkBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: AppColors.darkTextHint,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontFamily: 'PoppinsMedium',
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'PoppinsRegular',
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.darkBackground,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontFamily: 'PoppinsBold',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontFamily: 'PoppinsMedium',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        textStyle: const TextStyle(
          fontFamily: 'PoppinsMedium',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: const TextStyle(
        fontFamily: 'PoppinsRegular',
        color: AppColors.darkTextHint,
        fontSize: 14,
      ),
      labelStyle: const TextStyle(
        fontFamily: 'PoppinsRegular',
        color: AppColors.darkTextSecondary,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 0.5,
      space: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryGreen;
        }
        return AppColors.darkTextHint;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryGreen.withOpacity(0.3);
        }
        return AppColors.darkCard;
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkCard,
      contentTextStyle: const TextStyle(
        fontFamily: 'PoppinsRegular',
        color: AppColors.darkTextPrimary,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: 'PoppinsBold',
        fontSize: 18,
        color: AppColors.darkTextPrimary,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: 'PoppinsRegular',
        fontSize: 14,
        color: AppColors.darkTextSecondary,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryGreen,
      linearTrackColor: AppColors.darkCard,
      circularTrackColor: AppColors.darkCard,
    ),
  );

  // --- Light Theme ---
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.primaryGreen,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryGreen,
      secondary: AppColors.accentGreen,
      surface: AppColors.lightSurface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.lightTextPrimary,
      onError: Colors.white,
    ),
    fontFamily: 'PoppinsRegular',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
      titleTextStyle: TextStyle(
        fontFamily: 'PoppinsBold',
        fontSize: 20,
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.w700,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.lightBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.darkGreen,
      unselectedItemColor: AppColors.lightTextHint,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontFamily: 'PoppinsMedium',
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'PoppinsRegular',
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightDivider, width: 0.5),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontFamily: 'PoppinsBold',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkGreen,
        side: const BorderSide(color: AppColors.darkGreen, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontFamily: 'PoppinsMedium',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.darkGreen,
        textStyle: const TextStyle(
          fontFamily: 'PoppinsMedium',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightCardLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: const TextStyle(
        fontFamily: 'PoppinsRegular',
        color: AppColors.lightTextHint,
        fontSize: 14,
      ),
      labelStyle: const TextStyle(
        fontFamily: 'PoppinsRegular',
        color: AppColors.lightTextSecondary,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightDivider, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightDivider, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightDivider,
      thickness: 0.5,
      space: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryGreen;
        }
        return AppColors.lightTextHint;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryGreen.withOpacity(0.3);
        }
        return AppColors.lightDivider;
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.lightTextPrimary,
      contentTextStyle: const TextStyle(
        fontFamily: 'PoppinsRegular',
        color: Colors.white,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: 'PoppinsBold',
        fontSize: 18,
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: 'PoppinsRegular',
        fontSize: 14,
        color: AppColors.lightTextSecondary,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryGreen,
      linearTrackColor: AppColors.lightDivider,
      circularTrackColor: AppColors.lightDivider,
    ),
  );
}
