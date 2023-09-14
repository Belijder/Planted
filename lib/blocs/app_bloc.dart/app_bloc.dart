import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planted/auth_error.dart';
import 'package:planted/blocs/app_bloc.dart/app_event.dart';
import 'package:planted/blocs/app_bloc.dart/app_state.dart';
import 'package:planted/constants/strings.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc()
      : super(
          const AppStateInitialState(
            isLoading: false,
          ),
        ) {
    on<AppEventInitialize>(
      (event, emit) {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          emit(
            const AppStateLoggedOut(
              isLoading: false,
            ),
          );
          return;
        }

        if (user.emailVerified == false) {
          emit(
            const AppStateIsInConfirmationEmailView(
              isLoading: false,
            ),
          );
          return;
        }

        emit(AppStateLoggedIn(
          isLoading: false,
          user: user,
        ));
      },
    );

    on<AppEventGoToRegisterView>(
      (event, emit) {
        emit(
          const AppStateIsInRegistrationView(
            isLoading: false,
          ),
        );
      },
    );

    on<AppEventGoToLoginView>(
      (event, emit) {
        emit(
          const AppStateLoggedOut(
            isLoading: false,
          ),
        );
      },
    );

    on<AppEventRegister>(
      (event, emit) async {
        emit(
          const AppStateIsInRegistrationView(
            isLoading: true,
          ),
        );

        final email = event.email;
        final password = event.password;
        final confirmPassword = event.confirmPassword;

        // check passwords identicality
        if (password != confirmPassword) {
          emit(
            const AppStateIsInRegistrationView(
              isLoading: false,
              authError: AuthErrorPasswordAreNotIdentical(),
            ),
          );
          return;
        }

        try {
          final credentials =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          final user = credentials.user!;
          await user.sendEmailVerification();

          emit(
            const AppStateIsInConfirmationEmailView(
              isLoading: false,
            ),
          );
        } on FirebaseAuthException catch (e) {
          emit(AppStateIsInRegistrationView(
            isLoading: false,
            authError: AuthError.from(e),
          ));
        }
      },
    );

    on<AppEventResentVerificationMail>(
      (event, emit) async {
        emit(
          const AppStateIsInConfirmationEmailView(
            isLoading: true,
          ),
        );

        try {
          await FirebaseAuth.instance.currentUser!.sendEmailVerification();

          emit(
            const AppStateIsInConfirmationEmailView(
              isLoading: false,
              snackbarMessage: 'Mail został wysłany. sprawdź poczę!',
            ),
          );
        } on FirebaseAuthException catch (e) {
          emit(
            AppStateIsInConfirmationEmailView(
              isLoading: false,
              authError: AuthError.from(e),
            ),
          );
        }
      },
    );

    on<AppEventReloadUserInfo>(
      (event, emit) async {
        emit(
          const AppStateIsInConfirmationEmailView(
            isLoading: true,
          ),
        );

        try {
          await FirebaseAuth.instance.currentUser!.reload();
          final user = FirebaseAuth.instance.currentUser;

          if (user == null) {
            emit(
              const AppStateLoggedOut(
                isLoading: false,
              ),
            );
            return;
          }

          if (user.emailVerified == true) {
            emit(AppStateLoggedIn(
              isLoading: false,
              user: user,
            ));
          } else {
            emit(
              const AppStateIsInConfirmationEmailView(
                isLoading: false,
              ),
            );
            return;
          }
        } on FirebaseAuthException catch (e) {
          emit(AppStateIsInConfirmationEmailView(
            isLoading: false,
            authError: AuthError.from(e),
          ));
        }
      },
    );

    on<AppEventLogOut>(
      (event, emit) async {
        emit(const AppStateLoggedOut(isLoading: true));

        try {
          await FirebaseAuth.instance.signOut();
          emit(const AppStateLoggedOut(isLoading: false));
        } on FirebaseAuthException catch (e) {
          emit(AppStateLoggedOut(
            isLoading: false,
            authError: AuthError.from(e),
          ));
        }
      },
    );

    on<AppEventLogIn>(
      (event, emit) async {
        emit(const AppStateLoggedOut(isLoading: true));

        final email = event.email;
        final password = event.password;

        try {
          final credentials =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          final user = credentials.user;
          if (user == null) {
            emit(const AppStateLoggedOut(
              isLoading: false,
            ));
          } else {
            emit(AppStateLoggedIn(
              isLoading: false,
              user: user,
            ));
          }
        } on FirebaseAuthException catch (e) {
          emit(AppStateLoggedOut(
            isLoading: false,
            authError: AuthError.from(e),
          ));
        }
      },
    );

    on<AppEventSendResetPassword>(
      (event, emit) async {
        emit(const AppStateLoggedOut(isLoading: true));

        final email = event.email;

        try {
          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
          emit(const AppStateLoggedOut(
            isLoading: false,
            snackbarMessage: resetPasswordSended,
          ));
        } on FirebaseAuthException catch (e) {
          emit(AppStateLoggedOut(
            isLoading: false,
            authError: AuthError.from(e),
          ));
        }
      },
    );
  }
}
