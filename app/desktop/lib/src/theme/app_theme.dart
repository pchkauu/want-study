import 'package:flutter/material.dart';

abstract final class WantStudyColor {
  static const background = Color(0xFF0B0D10);
  static const surface = Color(0xFF14161A);
  static const surfaceElevated = Color(0xFF1B1E24);
  static const surfaceHighest = Color(0xFF222630);
  static const outline = Color(0xFF2A2F3A);
  static const text = Color(0xFFF2F4F8);
  static const textMuted = Color(0xFF9097AA);
  static const accent = Color(0xFF3454F5);
  static const success = Color(0xFF72DF8B);
  static const warning = Color(0xFFF2B35F);
  static const error = Color(0xFFFF5D7A);
}

ThemeData buildWantStudyTheme() {
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: WantStudyColor.accent,
        brightness: Brightness.dark,
        surface: WantStudyColor.surface,
      ).copyWith(
        primary: WantStudyColor.accent,
        onPrimary: WantStudyColor.text,
        primaryContainer: const Color(0xFF1D2E82),
        onPrimaryContainer: WantStudyColor.text,
        secondary: const Color(0xFF8294FF),
        onSecondary: WantStudyColor.background,
        tertiary: WantStudyColor.success,
        onTertiary: WantStudyColor.background,
        tertiaryContainer: const Color(0xFF183B24),
        onTertiaryContainer: const Color(0xFFB9F6C7),
        surface: WantStudyColor.surface,
        surfaceContainerLowest: WantStudyColor.background,
        surfaceContainerLow: const Color(0xFF111318),
        surfaceContainer: WantStudyColor.surface,
        surfaceContainerHigh: WantStudyColor.surfaceElevated,
        surfaceContainerHighest: WantStudyColor.surfaceHighest,
        onSurface: WantStudyColor.text,
        onSurfaceVariant: WantStudyColor.textMuted,
        outline: WantStudyColor.outline,
        outlineVariant: const Color(0xFF20242C),
        error: WantStudyColor.error,
        onError: WantStudyColor.background,
        surfaceTint: Colors.transparent,
      );
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: WantStudyColor.background,
    canvasColor: WantStudyColor.background,
    dividerColor: colorScheme.outlineVariant,
  );
  final textTheme = base.textTheme
      .copyWith(
        displaySmall: base.textTheme.displaySmall?.copyWith(
          color: WantStudyColor.text,
          fontSize: 38,
          fontWeight: FontWeight.w600,
          letterSpacing: -1.4,
          height: 1.05,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          color: WantStudyColor.text,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.8,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          color: WantStudyColor.text,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.35,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          color: WantStudyColor.text,
          fontSize: 19,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          color: WantStudyColor.text,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: WantStudyColor.text,
          height: 1.45,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: WantStudyColor.text,
          height: 1.4,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          color: WantStudyColor.textMuted,
          height: 1.35,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          color: WantStudyColor.text,
          fontWeight: FontWeight.w600,
        ),
      )
      .apply(fontFamilyFallback: const ['SF Pro Display', 'Segoe UI Variable']);

  final roundedControl = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  );
  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: WantStudyColor.background,
      foregroundColor: WantStudyColor.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: textTheme.titleLarge,
      surfaceTintColor: Colors.transparent,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: const Color(0xFF0E1014),
      elevation: 0,
      indicatorColor: WantStudyColor.accent,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      selectedIconTheme: const IconThemeData(
        color: WantStudyColor.text,
        size: 22,
      ),
      unselectedIconTheme: const IconThemeData(
        color: WantStudyColor.textMuted,
        size: 22,
      ),
      selectedLabelTextStyle: textTheme.labelLarge,
      unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
        color: WantStudyColor.textMuted,
      ),
    ),
    cardTheme: CardThemeData(
      color: WantStudyColor.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: WantStudyColor.outline),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: WantStudyColor.surfaceElevated,
      surfaceTintColor: Colors.transparent,
      elevation: 18,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: textTheme.headlineSmall,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: WantStudyColor.textMuted,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WantStudyColor.surfaceElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      labelStyle: const TextStyle(color: WantStudyColor.textMuted),
      hintStyle: const TextStyle(color: WantStudyColor.textMuted),
      helperStyle: const TextStyle(color: WantStudyColor.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: WantStudyColor.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: WantStudyColor.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: WantStudyColor.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: WantStudyColor.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: WantStudyColor.error, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: WantStudyColor.accent,
        foregroundColor: WantStudyColor.text,
        disabledBackgroundColor: WantStudyColor.surfaceHighest,
        disabledForegroundColor: WantStudyColor.textMuted,
        minimumSize: const Size(0, 46),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        shape: roundedControl,
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: WantStudyColor.text,
        minimumSize: const Size(0, 46),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        side: const BorderSide(color: WantStudyColor.outline),
        shape: roundedControl,
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFAAB5FF),
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: roundedControl,
        textStyle: textTheme.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: WantStudyColor.textMuted,
        hoverColor: WantStudyColor.surfaceHighest,
        focusColor: WantStudyColor.accent.withValues(alpha: 0.24),
        highlightColor: WantStudyColor.accent.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: WantStudyColor.surfaceElevated,
      selectedColor: WantStudyColor.accent.withValues(alpha: 0.28),
      side: const BorderSide(color: WantStudyColor.outline),
      shape: const StadiumBorder(),
      labelStyle: textTheme.labelMedium?.copyWith(color: WantStudyColor.text),
      secondaryLabelStyle: textTheme.labelMedium?.copyWith(
        color: WantStudyColor.text,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF20242C),
      space: 1,
      thickness: 1,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: WantStudyColor.surfaceElevated,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: textTheme.bodyMedium,
    ),
    tabBarTheme: TabBarThemeData(
      dividerColor: Colors.transparent,
      indicatorColor: WantStudyColor.accent,
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: WantStudyColor.text,
      unselectedLabelColor: WantStudyColor.textMuted,
      labelStyle: textTheme.labelLarge,
      unselectedLabelStyle: textTheme.labelLarge,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: WantStudyColor.accent,
      linearTrackColor: WantStudyColor.surfaceHighest,
      circularTrackColor: WantStudyColor.surfaceHighest,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: WantStudyColor.surfaceHighest,
      contentTextStyle: textTheme.bodyMedium,
      behavior: SnackBarBehavior.floating,
      shape: roundedControl,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: WantStudyColor.surfaceHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WantStudyColor.outline),
      ),
      textStyle: textTheme.bodySmall?.copyWith(color: WantStudyColor.text),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: WantStudyColor.accent,
      selectionColor: Color(0x663454F5),
      selectionHandleColor: WantStudyColor.accent,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      },
    ),
    extensions: const [WantStudySemanticColor()],
  );
}

@immutable
final class WantStudySemanticColor
    extends ThemeExtension<WantStudySemanticColor> {
  final Color success;
  final Color warning;

  const WantStudySemanticColor({
    this.success = WantStudyColor.success,
    this.warning = WantStudyColor.warning,
  });

  @override
  WantStudySemanticColor copyWith({Color? success, Color? warning}) =>
      WantStudySemanticColor(
        success: success ?? this.success,
        warning: warning ?? this.warning,
      );

  @override
  WantStudySemanticColor lerp(
    covariant WantStudySemanticColor? other,
    double t,
  ) {
    if (other == null) {
      return this;
    }
    return WantStudySemanticColor(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

TextStyle tabularNumberStyle(BuildContext context, TextStyle? base) =>
    (base ?? const TextStyle()).copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
