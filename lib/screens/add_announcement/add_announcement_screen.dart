import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/auth_views/confirm_email_view.dart';
import 'package:planted/auth_views/login_view.dart';
import 'package:planted/auth_views/register_view.dart';
import 'package:planted/blocs/app_bloc.dart/app_bloc.dart';
import 'package:planted/blocs/app_bloc.dart/app_state.dart';
import 'package:planted/screens/add_announcement/add_announcement_view.dart';
import 'package:planted/utilities/dialogs/show_auth_dialog.dart';
import 'package:planted/utilities/dialogs/show_database_error_dialog.dart';
import 'package:planted/utilities/loading/loading_screen.dart';

class AddAnnouncementScreen extends HookWidget {
  const AddAnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, appState) {
        if (appState.isLoading) {
          LoadingScreen.instance().show(context: context, text: 'Ładuję...');
        } else {
          LoadingScreen.instance().hide();
        }

        final authError = appState.authError;
        if (authError != null) {
          showAuthError(
            context: context,
            authError: authError,
          );
        }

        final databaseError = appState.databaseError;
        if (databaseError != null) {
          showDatabaseErrorDialog(
            context: context,
            databaseError: databaseError,
          );
        }

        final message = appState.snackbarMessage;
        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text(message),
            ),
          );
        }
      },
      builder: (context, appState) {
        if (appState is AppStateLoggedIn) {
          return const AddAnnouncementView();
        } else if (appState is AppStateLoggedOut) {
          return const LoginView();
        } else if (appState is AppStateIsInRegistrationView) {
          return const RegisterView();
        } else if (appState is AppStateIsInConfirmationEmailView) {
          return const ConfrimEmailView();
        } else {
          return Container();
        }
      },
    );
  }
}
