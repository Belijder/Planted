import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_bloc.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_event.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/screens/views/authViews/complete_profile_view.dart';
import 'package:planted/screens/views/authViews/confirm_email_view.dart';
import 'package:planted/screens/views/authViews/login_view.dart';
import 'package:planted/screens/views/authViews/register_view.dart';
import 'package:planted/blocs/authBloc/auth_bloc.dart';
import 'package:planted/blocs/authBloc/auth_state.dart';
import 'package:planted/screens/userProfile/user_profile_screen_bloc_consumer.dart';
import 'package:planted/utilities/dialogs/show_auth_dialog.dart';
import 'package:planted/utilities/loading/loading_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, appState) {
        if (appState.isLoading) {
          LoadingScreen.instance().show(
            context: context,
            text: LoadingScreenText.loading,
          );
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

        final message = appState.snackbarMessage;
        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 2), content: Text(message)));
        }
      },
      builder: (context, appState) {
        if (appState is AuthStateLoggedIn) {
          return BlocProvider<UserProfileScreenBloc>(
            create: (context) =>
                UserProfileScreenBloc(userID: appState.user.uid)
                  ..add(const UserProfileScreenEventInitialize()),
            child: UserProfileScreenBlocConsumer(userID: appState.user.uid),
          );
        } else if (appState is AuthStateLoggedOut) {
          return const LoginView();
        } else if (appState is AuthStateIsInRegistrationView) {
          return const RegisterView();
        } else if (appState is AuthStateIsInConfirmationEmailView) {
          return const ConfrimEmailView();
        } else if (appState is AuthStateIsInCompleteProfileView) {
          return const CompleteProfileView();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
