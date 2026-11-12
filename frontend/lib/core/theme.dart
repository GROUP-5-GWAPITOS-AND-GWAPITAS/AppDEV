import 'package:flutter/material.dart';

const Color primaryNavy = Color(0xFF1A2B56);
const Color accentOrange = Color(0xFFF28500);
const Color bgGray = Color(0xFFF5F7FA);
const Color textGray = Color(0xFF6B7280);

ThemeData get appTheme => ThemeData(
  scaffoldBackgroundColor: bgGray,
  primaryColor: primaryNavy,
  fontFamily: 'Roboto', 
  useMaterial3: true,
);