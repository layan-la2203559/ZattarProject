import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colours ────────────────────────────────────────────────────────────────────
const kBg      = Color(0xFF0A0A0A);
const kGreen   = Color(0xFF33FF33);
const kDkGreen = Color(0xFF1A8A1A);
const kDim     = Color(0xFF1A3A1A);
const kRed     = Color(0xFFFF4444);
const kYellow  = Color(0xFFFFAA00);
const kBlack   = Color(0xFF0A0A0A);

// ── Fonts ──────────────────────────────────────────────────────────────────────
TextStyle retroStyle({
  double size = 15,
  Color color = kGreen,
  FontWeight weight = FontWeight.normal,
}) =>
    GoogleFonts.vt323(fontSize: size, color: color, fontWeight: weight);

// ── App Theme ──────────────────────────────────────────────────────────────────
ThemeData buildRetroTheme() => ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kBg,
      colorScheme: const ColorScheme.dark(
        primary: kGreen,
        secondary: kDkGreen,
        surface: kBg,
        error: kRed,
      ),
      textTheme: GoogleFonts.vt323TextTheme().apply(
        bodyColor: kGreen,
        displayColor: kGreen,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F150F),
        hintStyle: retroStyle(color: kDim),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kDkGreen, width: 1.5),
          borderRadius: BorderRadius.circular(2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kGreen, width: 2),
          borderRadius: BorderRadius.circular(2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );

// ── Shared Widgets ─────────────────────────────────────────────────────────────

/// Green-bordered section card with a title label.
class RetroBox extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color borderColor;

  const RetroBox({
    super.key,
    required this.title,
    required this.children,
    this.borderColor = kGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: kBg,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('[ $title ]',
                style: retroStyle(size: 17, color: borderColor)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Retro styled text input.
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
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      autofocus: autofocus,
      style: retroStyle(size: 18),
      cursorColor: kGreen,
      decoration: InputDecoration(hintText: hint),
    );
  }
}

/// Retro styled button.
class RetroButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color bgColor;
  final double fontSize;

  const RetroButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = kGreen,
    this.bgColor = const Color(0xFF0A1A0A),
    this.fontSize = 17,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: color, width: 1.5),
        ),
        child: Center(
          child: Text(label, style: retroStyle(size: fontSize, color: color)),
        ),
      ),
    );
  }
}

/// Horizontal pair of buttons.
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

/// Snackbar-style toast notification.
void showRetroToast(BuildContext context, String msg,
    {Color color = kGreen}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg, style: retroStyle(size: 15, color: color)),
      backgroundColor: kBg,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: color, width: 1.5),
          borderRadius: BorderRadius.zero),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
    ),
  );
}
