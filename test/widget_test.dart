import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/presentation/blocs/theme/theme_cubit.dart';

void main() {
  group('ThemeCubit Tests', () {
    test('initial state is ThemeMode.system', () {
      final themeCubit = ThemeCubit();
      expect(themeCubit.state, ThemeMode.system);
      themeCubit.close();
    });

    test('setLight emits ThemeMode.light', () {
      final themeCubit = ThemeCubit();
      themeCubit.setLight();
      expect(themeCubit.state, ThemeMode.light);
      themeCubit.close();
    });

    test('setDark emits ThemeMode.dark', () {
      final themeCubit = ThemeCubit();
      themeCubit.setDark();
      expect(themeCubit.state, ThemeMode.dark);
      themeCubit.close();
    });

    test('setSystem emits ThemeMode.system', () {
      final themeCubit = ThemeCubit();
      themeCubit.setLight();
      themeCubit.setSystem();
      expect(themeCubit.state, ThemeMode.system);
      themeCubit.close();
    });
  });
}