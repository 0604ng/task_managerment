// lib/const/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const primary = Color(0xFF6366F1); // Indigo
  static const primaryLight = Color(0xFF818CF8);
  static const secondary = Color(0xFF8B5CF6); // Violet
  static const secondaryLight = Color(0xFFA78BFA);

  // Status colors
  static const success = Color(0xFF10B981); // Emerald
  static const error = Color(0xFFEF4444); // Rose
  static const warning = Color(0xFFF59E0B); // Amber
  static const info = Color(0xFF3B82F6); // Blue

  // Neutrals (Light Theme)
  static const background = Color(0xFFF8FAFC); // Slate 50
  static const surface = Colors.white;
  static const onPrimary = Colors.white;
  static const textPrimary = Color(0xFF0F172A); // Slate 900
  static const textSecondary = Color(0xFF64748B); // Slate 500
  static const border = Color(0xFFE2E8F0); // Slate 200

  // Neutrals (Dark Theme)
  static const darkBackground = Color(0xFF090D16); // Obsidian Navy
  static const darkSurface = Color(0xFF151C2C); // Deep Slate Card
  static const darkTextPrimary = Color(0xFFF1F5F9); // Slate 100
  static const darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const darkBorder = Color(0xFF1E293B); // Slate 800

  // Category colors (soft glass pastel with high contrast text)
  static const projectBg = Color(0xFFFEE2E2); // Soft Red
  static const projectText = Color(0xFF991B1B);
  
  static const educationBg = Color(0xFFFEF3C7); // Soft Amber
  static const educationText = Color(0xFF92400E);
  
  static const workoutBg = Color(0xFFD1FAE5); // Soft Emerald
  static const workoutText = Color(0xFF065F46);
  
  static const meetingsBg = Color(0xFFE0F2FE); // Soft Blue
  static const meetingsText = Color(0xFF075985);

  static const familyBg = Color(0xFFFCE7F3); // Soft Pink
  static const familyText = Color(0xFF9D174D);

  static const sportBg = Color(0xFFECFDF5); // Soft Green
  static const sportText = Color(0xFF065F46);

  static const gameBg = Color(0xFFF3E8FF); // Soft Purple
  static const gameText = Color(0xFF6B21A8);

  static const shoppingBg = Color(0xFFFFEDD5); // Soft Orange
  static const shoppingText = Color(0xFF9A3412);

  static const learningBg = Color(0xFFE0E7FF); // Soft Indigo
  static const learningText = Color(0xFF3730A3);

  static const hobbyBg = Color(0xFFE2F8F8); // Soft Teal
  static const hobbyText = Color(0xFF047857);

  // Helper for backward compatibility
  static Color get bg => background;
}

