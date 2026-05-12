import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// VoiceBox-inspired editorial design system.
/// Bold, opinionated, magazine-style: flat surfaces, thick borders,
/// stark black-on-white with a single red accent.
class TereTheme {
  TereTheme._();

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color ink = Color(0xFF0A0A0A);        // primary / headlines
  static const Color paper = Color(0xFFFAFAFA);      // primary background
  static const Color accent = Color(0xFFEF4444);     // red — scalpel, not paintbrush
  static const Color accentDeep = Color(0xFFDC2626); // active state
  static const Color accentDeeper = Color(0xFFB91C1C);

  // ── Surfaces ─────────────────────────────────────────────────────────────
  static const Color surface = Color(0xFFF5F5F5);
  static const Color surfaceRaised = Color(0xFFE5E5E5);

  // ── Content ──────────────────────────────────────────────────────────────
  static const Color textPrimary = ink;
  static const Color textSecondary = Color(0xFF525252);
  static const Color textTertiary = Color(0xFFA3A3A3);

  // ── Borders ──────────────────────────────────────────────────────────────
  static const Color borderSubtle = Color(0xFFE5E5E5);
  static const Color borderMedium = Color(0xFFD4D4D4);
  static const Color borderStrong = ink;

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFCA8A04);
  static const Color error = accent;
  static const Color info = ink;

  // Semantic chip surface tints (specced).
  static const Color successSurface = Color(0xFFF0FDF4);
  static const Color warningSurface = Color(0xFFFEFCE8);
  static const Color errorSurface = Color(0xFFFEF2F2);

  // ── Type stacks ──────────────────────────────────────────────────────────
  // Archivo Black / Work Sans aren't bundled — we lean on the spec's fallbacks
  // so the layout still gets editorial weight on any platform.
  static const List<String> _displayFallback = <String>[
    'Impact',
    'Arial Black',
    'Oswald',
    'Bebas Neue',
  ];
  static const List<String> _bodyFallback = <String>[
    'Segoe UI',
    'Helvetica',
    'Arial',
    'Roboto',
  ];

  static const String _displayFamily = 'Impact';
  static const String _bodyFamily = 'Segoe UI';

  static TextStyle display({double size = 56, Color? color}) => TextStyle(
        fontFamily: _displayFamily,
        fontFamilyFallback: _displayFallback,
        fontSize: size,
        fontWeight: FontWeight.w900,
        height: 1.05,
        letterSpacing: -0.03 * size,
        color: color ?? textPrimary,
      );

  static TextStyle headline({double size = 38, Color? color}) => TextStyle(
        fontFamily: _displayFamily,
        fontFamilyFallback: _displayFallback,
        fontSize: size,
        fontWeight: FontWeight.w900,
        height: 1.1,
        letterSpacing: -0.02 * size,
        color: color ?? textPrimary,
      );

  static TextStyle subhead({double size = 24, Color? color}) => TextStyle(
        fontFamily: _displayFamily,
        fontFamilyFallback: _displayFallback,
        fontSize: size,
        fontWeight: FontWeight.w900,
        height: 1.2,
        letterSpacing: -0.01 * size,
        color: color ?? textPrimary,
      );

  static TextStyle body({double size = 16, FontWeight weight = FontWeight.w400, Color? color}) => TextStyle(
        fontFamily: _bodyFamily,
        fontFamilyFallback: _bodyFallback,
        fontSize: size,
        fontWeight: weight,
        height: 1.7,
        color: color ?? textPrimary,
      );

  static TextStyle caption({Color? color}) => TextStyle(
        fontFamily: _bodyFamily,
        fontFamilyFallback: _bodyFallback,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0.01 * 12,
        color: color ?? textSecondary,
      );

  /// Uppercase rubric label. Used everywhere editorial: nav sections,
  /// form labels, chips, eyebrow text above titles.
  static TextStyle overline({double size = 11, Color? color}) => TextStyle(
        fontFamily: _bodyFamily,
        fontFamilyFallback: _bodyFallback,
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.4,
        letterSpacing: 0.12 * size,
        color: color ?? textPrimary,
      );

  // ── Theme builders ───────────────────────────────────────────────────────
  static ThemeData light() => _build();
  static ThemeData dark() => _build(); // VoiceBox is intentionally always light.

  static ThemeData _build() {
    const scheme = ColorScheme.light(
      primary: ink,
      onPrimary: paper,
      secondary: accent,
      onSecondary: paper,
      surface: paper,
      onSurface: ink,
      error: accent,
      onError: paper,
      outline: borderMedium,
      outlineVariant: borderSubtle,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: paper,
      canvasColor: paper,
      dividerColor: borderSubtle,
      splashFactory: NoSplash.splashFactory,
      highlightColor: surfaceRaised,
      hoverColor: surface,
      visualDensity: VisualDensity.standard,
    );

    return base.copyWith(
      textTheme: TextTheme(
        displayLarge: display(),
        displayMedium: display(size: 48),
        displaySmall: display(size: 42),
        headlineLarge: headline(size: 44),
        headlineMedium: headline(),
        headlineSmall: headline(size: 30),
        titleLarge: subhead(),
        titleMedium: subhead(size: 18),
        titleSmall: overline(size: 12),
        bodyLarge: body(size: 18),
        bodyMedium: body(),
        bodySmall: body(size: 14, color: textSecondary),
        labelLarge: overline(size: 13),
        labelMedium: overline(),
        labelSmall: overline(size: 10),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: subhead(size: 22),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: ink),
      ),
      cardTheme: const CardThemeData(
        color: paper,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: borderSubtle, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderSubtle,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.disabled)) return ink.withValues(alpha: 0.35);
            if (s.contains(WidgetState.pressed)) return accentDeep;
            if (s.contains(WidgetState.hovered)) return accent;
            return ink;
          }),
          foregroundColor: WidgetStatePropertyAll(paper),
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: ink, width: 2),
          )),
          side: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.hovered) || s.contains(WidgetState.pressed)) {
              return const BorderSide(color: accent, width: 2);
            }
            return const BorderSide(color: ink, width: 2);
          }),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
          textStyle: WidgetStatePropertyAll(overline(size: 13)),
          minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
          elevation: const WidgetStatePropertyAll(0),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.hovered)) return paper;
            return ink;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.pressed)) return const Color(0xFF262626);
            if (s.contains(WidgetState.hovered)) return ink;
            return Colors.transparent;
          }),
          side: const WidgetStatePropertyAll(BorderSide(color: ink, width: 2)),
          shape: const WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
          textStyle: WidgetStatePropertyAll(overline(size: 13)),
          minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.pressed)) return accentDeep;
            if (s.contains(WidgetState.hovered)) return accent;
            return ink;
          }),
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: const WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
          textStyle: WidgetStatePropertyAll(overline(size: 13)),
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.hovered)) return accent;
            return ink;
          }),
          shape: const WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ink,
        foregroundColor: paper,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: ink, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: paper,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: borderMedium, width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: borderMedium, width: 2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: ink, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: accent, width: 2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: accent, width: 2),
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: borderSubtle, width: 2),
        ),
        labelStyle: overline(size: 12, color: ink),
        floatingLabelStyle: overline(size: 12, color: ink),
        hintStyle: body(color: textTertiary),
        helperStyle: caption(),
        errorStyle: caption(color: accent),
        prefixIconColor: ink,
        suffixIconColor: ink,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: ink,
        side: const BorderSide(color: borderMedium, width: 2),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        labelStyle: overline(size: 11, color: textSecondary),
        secondaryLabelStyle: overline(size: 11, color: paper),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        showCheckmark: false,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: paper,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: ink, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: body(color: paper),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        behavior: SnackBarBehavior.floating,
        actionTextColor: accent,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: borderSubtle,
        circularTrackColor: borderSubtle,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: const BoxDecoration(color: ink),
        textStyle: body(size: 12, weight: FontWeight.w600, color: paper),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        waitDuration: const Duration(milliseconds: 250),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: paper,
        indicatorColor: ink,
        indicatorShape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return const IconThemeData(color: paper);
          return const IconThemeData(color: textSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return overline(size: 11, color: ink);
          return overline(size: 11, color: textSecondary);
        }),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: paper,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: const WidgetStatePropertyAll(surface),
        headingTextStyle: overline(size: 11, color: ink),
        dataTextStyle: body(size: 14),
        dividerThickness: 1,
        decoration: const BoxDecoration(color: paper),
      ),
      checkboxTheme: CheckboxThemeData(
        side: const BorderSide(color: ink, width: 2),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        fillColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return ink;
          return paper;
        }),
        checkColor: const WidgetStatePropertyAll(paper),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return ink;
          return ink;
        }),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: ink,
        unselectedLabelColor: textSecondary,
        indicatorColor: accent,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: overline(size: 12),
        unselectedLabelStyle: overline(size: 12, color: textSecondary),
        dividerColor: borderSubtle,
      ),
    );
  }

  // Backwards-compatible aliases so older direct-token references keep working.
  static const Color primaryCyan = accent;
  static const Color backgroundNavy = paper;
  static const Color surfaceNavy = surface;
  static const Color textMain = textPrimary;
  static const Color textMuted = textSecondary;
}
