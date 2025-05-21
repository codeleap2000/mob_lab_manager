import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState()) {
    // Initial state is light mode
    on<ThemeToggled>(_onThemeToggled);
    on<ThemeSet>(_onThemeSet);
  }

  void _onThemeToggled(ThemeToggled event, Emitter<ThemeState> emit) {
    emit(state.copyWith(
      themeMode:
          state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
    ));
  }

  void _onThemeSet(ThemeSet event, Emitter<ThemeState> emit) {
    emit(state.copyWith(themeMode: event.themeMode));
  }
}
