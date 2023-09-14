import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/app_bloc.dart/app_bloc.dart';
import 'package:planted/blocs/app_bloc.dart/app_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/navigation_bar_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        navigationBarTheme: const NavigationBarThemeData(
          labelTextStyle: MaterialStatePropertyAll(
            TextStyle(
              color: colorSepia,
              fontSize: 12,
            ),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorSepia,
          background: colorEggsheel,
          shadow: colorSepia,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) => AppBloc()..add(const AppEventInitialize()),
        child: const NavigationBarView(),
      ),
    );
  }
}