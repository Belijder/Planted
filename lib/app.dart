import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/addScreenBloc/add_screen_bloc.dart';
import 'package:planted/blocs/app_bloc.dart/app_bloc.dart';
import 'package:planted/blocs/app_bloc.dart/app_event.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_bloc.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_bloc.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_bloc.dart';
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
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AppBloc>(
            create: (_) => AppBloc()
              ..add(
                const AppEventInitialize(),
              ),
          ),
          BlocProvider<BrowseScreenBloc>(
            create: (_) => BrowseScreenBloc(),
          ),
          BlocProvider<AddScreenBloc>(
            create: (_) => AddScreenBloc(),
          ),
          BlocProvider<MessagesScreenBloc>(
            create: (_) => MessagesScreenBloc(),
          ),
          BlocProvider<UserProfileScreenBloc>(
            create: (_) => UserProfileScreenBloc(),
          )
        ],
        child: const NavigationBarView(),
      ),
    );
  }
}
