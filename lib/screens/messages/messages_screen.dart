import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_bloc.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_event.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/screens/views/authViews/complete_profile_view.dart';
import 'package:planted/screens/views/authViews/confirm_email_view.dart';
import 'package:planted/screens/views/authViews/login_view.dart';
import 'package:planted/screens/views/authViews/register_view.dart';
import 'package:planted/blocs/authBloc/auth_bloc.dart';
import 'package:planted/blocs/authBloc/auth_state.dart';
import 'package:planted/screens/messages/messages_screen_bloc_consumer.dart';
import 'package:planted/utilities/dialogs/show_auth_dialog.dart';
import 'package:planted/utilities/dialogs/show_database_error_dialog.dart';
import 'package:planted/utilities/loading/loading_screen.dart';
import 'package:planted/utilities/widget_utils.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, appState) {
        if (appState.isLoading) {
          LoadingScreen.instance()
              .show(context: context, text: LoadingScreenText.loading);
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
        Widget child;

        if (appState is AuthStateLoggedIn) {
          try {
            final _ = BlocProvider.of<MessagesScreenBloc>(context);
            child = MessagesScreenBlocConsumer(userID: appState.user.uid);
          } catch (_) {
            child = BlocProvider(
              create: (context) => MessagesScreenBloc(userID: appState.user.uid)
                ..add(const MessagesScreenEventInitialize()),
              child: MessagesScreenBlocConsumer(
                userID: appState.user.uid,
              ),
            );
          }
        } else if (appState is AuthStateLoggedOut) {
          child = const LoginView();
        } else if (appState is AuthStateIsInRegistrationView) {
          child = const RegisterView();
        } else if (appState is AuthStateIsInConfirmationEmailView) {
          child = const ConfrimEmailView();
        } else if (appState is AuthStateIsInCompleteProfileView) {
          child = const CompleteProfileView();
        } else {
          child = const Center(child: CircularProgressIndicator());
        }

        return createAnimatedSwitcher(child: child);
      },
    );
  }
}
