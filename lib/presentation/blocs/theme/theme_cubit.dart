import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void setLight() => emit(ThemeMode.light);
  void setDark() => emit(ThemeMode.dark);
  void setSystem() => emit(ThemeMode.system);
}
