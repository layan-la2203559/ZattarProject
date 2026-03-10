import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Fixed colours (never change with theme) ────────────────────────────────────
const kBg      = Color(0xFF0A0A0A);
const kRed     = Color(0xFFFF4444);
const kYellow  = Color(0xFFFFAA00);
const kBlack   = Color(0xFF0A0A0A);

// ── Legacy fallbacks ──────────────────────────────────────────────────────────
const kGreen   = Color(0xFF33FF33);
const kDkGreen = Color(0xFF1A8A1A);
const kDim     = Color(0xFF1A3A1A);

// ── Pip-Boy Colour Schemes ────────────────────────────────────────────────────
class PipScheme {
  final String name;
  final Color accent;
  final Color dark;
  final Color dim;

  const PipScheme({
    required this.name,
    required this.accent,
    required this.dark,
    required this.dim,
  });

  Color get activeBg {
    return Color.fromARGB(
      255,
      (accent.red   * 0.12).round().clamp(8, 30),
      (accent.green * 0.12).round().clamp(8, 30),
      (accent.blue  * 0.12).round().clamp(8, 30),
    );
  }

  Color get inputBg {
    return Color.fromARGB(
      255,
      (accent.red   * 0.06).round().clamp(10, 25),
      (accent.green * 0.06).round().clamp(10, 25),
      (accent.blue  * 0.06).round().clamp(10, 25),
    );
  }
}

const pipSchemes = <PipScheme>[
  PipScheme(name:'GREEN',  accent:Color(0xFF33FF33), dark:Color(0xFF1A8A1A), dim:Color(0xFF1A3A1A)),
  PipScheme(name:'AMBER',  accent:Color(0xFFFFAA33), dark:Color(0xFF8A5500), dim:Color(0xFF3A2800)),
  PipScheme(name:'BLUE',   accent:Color(0xFF33AAFF), dark:Color(0xFF1A5588), dim:Color(0xFF1A2E3A)),
  PipScheme(name:'VIOLET', accent:Color(0xFFCC44FF), dark:Color(0xFF661A88), dim:Color(0xFF2A1A3A)),
  PipScheme(name:'RED',    accent:Color(0xFFFF4466), dark:Color(0xFF881A2A), dim:Color(0xFF3A1A1E)),
  PipScheme(name:'TEAL',   accent:Color(0xFF00FFCC), dark:Color(0xFF008866), dim:Color(0xFF003A2E)),
];

// ── InheritedWidget ───────────────────────────────────────────────────────────
class AppPalette extends InheritedWidget {
  final PipScheme scheme;
  final int schemeIndex;
  final ValueChanged<int> onChangeScheme;

  const AppPalette({
    super.key,
    required this.scheme,
    required this.schemeIndex,
    required this.onChangeScheme,
    required super.child,
  });

  static AppPalette of(BuildContext context) {
    final p = context.dependOnInheritedWidgetOfExactType<AppPalette>();
    assert(p != null, 'No AppPalette in context');
    return p!;
  }

  @override
  bool updateShouldNotify(AppPalette old) => old.schemeIndex != schemeIndex;
}

// ── Fonts ──────────────────────────────────────────────────────────────────────
TextStyle retroStyle({
  double size = 15,
  Color color = kGreen,
  FontWeight weight = FontWeight.normal,
}) =>
    GoogleFonts.vt323(fontSize: size, color: color, fontWeight: weight);

// ── App Theme builder ─────────────────────────────────────────────────────────
ThemeData buildRetroTheme(PipScheme s) => ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kBg,
      colorScheme: ColorScheme.dark(
        primary: s.accent,
        secondary: s.dark,
        surface: kBg,
        error: kRed,
      ),
      textTheme: GoogleFonts.vt323TextTheme().apply(
        bodyColor: s.accent,
        displayColor: s.accent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: s.inputBg,
        hintStyle: retroStyle(color: s.dim),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: s.dark, width: 1.5),
          borderRadius: BorderRadius.circular(2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: s.accent, width: 2),
          borderRadius: BorderRadius.circular(2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );

// ── Colour picker modal ───────────────────────────────────────────────────────
void showColorPicker(BuildContext context) {
  final palette = AppPalette.of(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: kBg,
    shape: Border(top: BorderSide(color: palette.scheme.accent, width: 2)),
    builder: (ctx) => _ColorPickerSheet(
      currentIndex: palette.schemeIndex,
      onPick: (i) {
        palette.onChangeScheme(i);
        Navigator.pop(ctx);
      },
      scheme: palette.scheme,
    ),
  );
}

class _ColorPickerSheet extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onPick;
  final PipScheme scheme;
  const _ColorPickerSheet({
    required this.currentIndex,
    required this.onPick,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('[ PIP-BOY INTERFACE COLOR ]',
              style: retroStyle(size: 20, color: scheme.accent)),
          const SizedBox(height: 4),
          Text('SELECT DISPLAY FREQUENCY',
              style: retroStyle(size: 13, color: scheme.dark)),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(pipSchemes.length, (i) {
              final ps = pipSchemes[i];
              final active = i == currentIndex;
              return GestureDetector(
                onTap: () => onPick(i),
                child: Container(
                  decoration: BoxDecoration(
                    color: ps.activeBg,
                    border: Border.all(
                      color: ps.accent,
                      width: active ? 3 : 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (active)
                        Icon(Icons.circle, color: ps.accent, size: 10),
                      Text(ps.name,
                          style: retroStyle(size: 17, color: ps.accent)),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.dark),
                  color: scheme.activeBg,
                ),
                child: Text('[ CLOSE ]',
                    style: retroStyle(size: 16, color: scheme.dark)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────────────────────────────

class RetroBox extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color? borderColor;

  const RetroBox({
    super.key,
    required this.title,
    required this.children,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = borderColor ?? AppPalette.of(context).scheme.accent;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: kBg,
        border: Border.all(color: accent, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('[ $title ]', style: retroStyle(size: 17, color: accent)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class RetroInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool autofocus;

  const RetroInput({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppPalette.of(context).scheme.accent;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      autofocus: autofocus,
      style: retroStyle(size: 18, color: accent),
      cursorColor: accent,
      decoration: InputDecoration(hintText: hint),
    );
  }
}

class RetroButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? bgColor;
  final double fontSize;

  const RetroButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.bgColor,
    this.fontSize = 17,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context).scheme;
    final c  = color  ?? palette.accent;
    final bg = bgColor ?? palette.activeBg;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: c, width: 1.5),
        ),
        child: Center(
          child: Text(label, style: retroStyle(size: fontSize, color: c)),
        ),
      ),
    );
  }
}

class RetroBtnRow extends StatelessWidget {
  final List<Widget> buttons;
  const RetroBtnRow({super.key, required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: buttons
          .expand((b) => [Expanded(child: b), const SizedBox(width: 8)])
          .toList()
        ..removeLast(),
    );
  }
}

void showRetroToast(BuildContext context, String msg, {Color? color}) {
  final c = color ?? AppPalette.of(context).scheme.accent;
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg, style: retroStyle(size: 15, color: c)),
      backgroundColor: kBg,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: c, width: 1.5),
          borderRadius: BorderRadius.zero),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
    ),
  );
}
