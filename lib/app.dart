import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/addScreenBloc/add_screen_bloc.dart';
import 'package:planted/blocs/authBloc/auth_bloc.dart';
import 'package:planted/blocs/authBloc/auth_event.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_bloc.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/navigation_bar_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
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
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc()
              ..add(
                const AuthEventInitialize(),
              ),
          ),
          BlocProvider<BrowseScreenBloc>(
            create: (_) => BrowseScreenBloc()
              ..add(
                const BrowseScreenEventInitialize(),
              ),
          ),
          BlocProvider<AddScreenBloc>(
            create: (_) => AddScreenBloc(),
          ),
        ],
        child: const NavigationBarView(),
      ),
    );
  }
}
