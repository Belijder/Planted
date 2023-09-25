import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/auth_views/complete_profile_view.dart';
import 'package:planted/auth_views/confirm_email_view.dart';
import 'package:planted/auth_views/login_view.dart';
import 'package:planted/auth_views/register_view.dart';
import 'package:planted/blocs/app_bloc.dart/app_bloc.dart';
import 'package:planted/blocs/app_bloc.dart/app_state.dart';
import 'package:planted/screens/messages/messages_screen_bloc_consumer.dart';
import 'package:planted/utilities/dialogs/show_auth_dialog.dart';
import 'package:planted/utilities/dialogs/show_database_error_dialog.dart';
import 'package:planted/utilities/loading/loading_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

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
        Widget child;

        if (appState is AppStateLoggedIn) {
          child = const MessagesScreenBlocConsumer();
        } else if (appState is AppStateLoggedOut) {
          child = const LoginView();
        } else if (appState is AppStateIsInRegistrationView) {
          child = const RegisterView();
        } else if (appState is AppStateIsInConfirmationEmailView) {
          child = const ConfrimEmailView();
        } else if (appState is AppStateIsInCompleteProfileView) {
          child = const CompleteProfileView();
        } else {
          child = const Center(child: CircularProgressIndicator());
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.fastOutSlowIn,
          transitionBuilder: (child, animation) {
            final scaleAnimation = Tween<double>(
              begin: 0.85,
              end: 1.0,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
          layoutBuilder: (currentChild, previousChildren) {
            return currentChild ?? Container();
          },
          child: child,
        );
      },
    );
  }
}
