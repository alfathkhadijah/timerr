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
      name: 'Midnight Bloom',
      primary: const Color(0xFF7986CB),
      background: const Color(0xFF0F172A),
      surface: const Color(0xFF1E293B),
      accent: const Color(0xFF818CF8),
      textColor: const Color(0xFFF1F5F9),
      cost: 500,
    ),
    AppTheme(
      id: 'lavender',
      name: 'Lavender Silk',
      primary: const Color(0xFF9575CD),
      background: const Color(0xFFF8F7FF),
      surface: Colors.white,
      accent: const Color(0xFF7C4DFF),
      textColor: const Color(0xFF4A148C),
      cost: 150,
    ),
    AppTheme(
      id: 'ocean',
      name: 'Ocean Pearl',
      primary: const Color(0xFF4FC3F7),
      background: const Color(0xFFF0F9FF),
      surface: Colors.white,
      accent: const Color(0xFF0EA5E9),
      textColor: const Color(0xFF0C4A6E),
      cost: 250,
    ),
    AppTheme(
      id: 'ember',
      name: 'Autumn Ember',
      primary: const Color(0xFFFF8A65),
      background: const Color(0xFFFFF7ED),
      surface: Colors.white,
      accent: const Color(0xFFF97316),
      textColor: const Color(0xFF7C2D12),
      cost: 350,
    ),
    AppTheme(
      id: 'charcoal',
      name: 'Deep Graphite',
      primary: const Color(0xFF94A3B8),
      background: const Color(0xFF1E293B),
      surface: const Color(0xFF334155),
      accent: const Color(0xFF64748B),
      textColor: const Color(0xFFF8FAFC),
      cost: 450,
    ),
    AppTheme(
      id: 'mint',
      name: 'Mint Breeze',
      primary: const Color(0xFF80CBC4),
      background: const Color(0xFFF0FDFA),
      surface: Colors.white.withOpacity(0.9),
      accent: const Color(0xFF2DD4BF),
      textColor: const Color(0xFF134E48),
      cost: 100,
    ),
    AppTheme(
      id: 'peach',
      name: 'Peach Sorbet',
      primary: const Color(0xFFFFCC80),
      background: const Color(0xFFFFF7ED),
      surface: Colors.white.withOpacity(0.9),
      accent: const Color(0xFFFB923C),
      textColor: const Color(0xFF7C2D12),
      cost: 120,
    ),
    AppTheme(
      id: 'pearl',
      name: 'Silky Pearl',
      primary: const Color(0xFFE2E8F0),
      background: const Color(0xFFF8FAFC),
      surface: Colors.white,
      accent: const Color(0xFF94A3B8),
      textColor: const Color(0xFF475569),
      cost: 400,
    ),
    AppTheme(
      id: 'gold',
      name: 'Champagne Gold',
      primary: const Color(0xFFFDE68A),
      background: const Color(0xFFFFFBEB),
      surface: Colors.white,
      accent: const Color(0xFFF59E0B),
      textColor: const Color(0xFF78350F),
      cost: 800,
    ),
    AppTheme(
      id: 'matcha',
      name: 'Matcha Latte',
      primary: const Color(0xFFA7F3D0),
      background: const Color(0xFFF0FDF4),
      surface: Colors.white,
      accent: const Color(0xFF10B981),
      textColor: const Color(0xFF064E3B),
      cost: 300,
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
      backgroundImagePath: null,
    ),
  ];
}
