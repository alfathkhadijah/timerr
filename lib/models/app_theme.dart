import 'package:flutter/material.dart';

class AppTheme {
  final String id;
  final String name;
  final Color primary;
  final Color background;
  final Color surface;
  final Color accent;
  final Color textColor;
  final String? backgroundImagePath;
  final int cost;

  AppTheme({
    required this.id,
    required this.name,
    required this.primary,
    required this.background,
    required this.surface,
    required this.accent,
    required this.textColor,
    this.backgroundImagePath,
    required this.cost,
  });

  static List<AppTheme> allThemes = [
    AppTheme(
      id: 'dusk',
      name: 'Dusk Blue',
      primary: const Color(0xFF5C6BC0),
      background: const Color(0xFFF0F2F5),
      surface: Colors.white,
      accent: const Color(0xFF3F51B5),
      textColor: const Color(0xFF2C3E50),
      cost: 0,
    ),
    AppTheme(
      id: 'forest',
      name: 'Forest Green',
      primary: const Color(0xFF66BB6A),
      background: const Color(0xFFF1F8E9),
      surface: Colors.white,
      accent: const Color(0xFF388E3C),
      textColor: const Color(0xFF1B5E20),
      cost: 200,
    ),
    AppTheme(
      id: 'terracotta',
      name: 'Sunset Rose',
      primary: const Color(0xFFEF5350),
      background: const Color(0xFFFFEBEE),
      surface: Colors.white,
      accent: const Color(0xFFD32F2F),
      textColor: const Color(0xFF3E2723),
      cost: 300,
    ),
    AppTheme(
      id: 'midnight',
      name: 'Midnight',
      primary: const Color(0xFF90CAF9),
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
      accent: const Color(0xFF64B5F6),
      textColor: const Color(0xFFE0E0E0),
      cost: 500,
    ),
    AppTheme(
      id: 'lavender',
      name: 'Lavender Mist',
      primary: const Color(0xFF9575CD),
      background: const Color(0xFFF3E5F5),
      surface: Colors.white,
      accent: const Color(0xFF673AB7),
      textColor: const Color(0xFF311B92),
      cost: 150,
    ),
    AppTheme(
      id: 'ocean',
      name: 'Ocean Calm',
      primary: const Color(0xFF4FC3F7),
      background: const Color(0xFFE1F5FE),
      surface: Colors.white,
      accent: const Color(0xFF0288D1),
      textColor: const Color(0xFF01579B),
      cost: 250,
    ),
    AppTheme(
      id: 'ember',
      name: 'Ember Glow',
      primary: const Color(0xFFFF8A65),
      background: const Color(0xFFFBE9E7),
      surface: Colors.white,
      accent: const Color(0xFFE64A19),
      textColor: const Color(0xFFBF360C),
      cost: 350,
    ),
    AppTheme(
      id: 'charcoal',
      name: 'Deep Charcoal',
      primary: const Color(0xFFB0BEC5),
      background: const Color(0xFF263238),
      surface: const Color(0xFF37474F),
      accent: const Color(0xFF90A4AE),
      textColor: const Color(0xFFECEFF1),
      cost: 450,
    ),
    AppTheme(
      id: 'mint',
      name: 'Mint whisper',
      primary: const Color(0xFFB2DFDB),
      background: const Color(0xFFF1F8F7),
      surface: Colors.white.withOpacity(0.9),
      accent: const Color(0xFF4DB6AC),
      textColor: const Color(0xFF004D40).withOpacity(0.8),
      cost: 100,
    ),
    AppTheme(
      id: 'peach',
      name: 'Peach cloud',
      primary: const Color(0xFFFFE0B2),
      background: const Color(0xFFFFF8F1),
      surface: Colors.white.withOpacity(0.9),
      accent: const Color(0xFFFFB74D),
      textColor: const Color(0xFF795548).withOpacity(0.8),
      cost: 120,
    ),
    AppTheme(
      id: 'rose',
      name: 'Rose blush',
      primary: const Color(0xFFF8BBD0),
      background: const Color(0xFFFFF1F5),
      surface: Colors.white.withOpacity(0.9),
      accent: const Color(0xFFF06292),
      textColor: const Color(0xFF880E4F).withOpacity(0.8),
      cost: 180,
    ),
    AppTheme(
      id: 'slate',
      name: 'Slate silk',
      primary: const Color(0xFFCFD8DC),
      background: const Color(0xFFF5F7F8),
      surface: Colors.white.withOpacity(0.9),
      accent: const Color(0xFF90A4AE),
      textColor: const Color(0xFF37474F).withOpacity(0.8),
      cost: 220,
    ),
    AppTheme(
      id: 'zen',
      name: 'Studio Zen',
      primary: const Color(0xFFB0BEC5),
      background: const Color(0xFFFAFAFA),
      surface: Colors.white.withOpacity(0.9),
      accent: const Color(0xFF455A64),
      textColor: const Color(0xFF263238),
      cost: 600,
      backgroundImagePath: 'assets/images/tomato.png', // Using tomato as a placeholder 'image' for now
    ),
  ];
}
