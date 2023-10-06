import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:planted/auth_error.dart';
import 'package:planted/blocs/app_bloc.dart/app_event.dart';
import 'package:planted/blocs/app_bloc.dart/app_state.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/database_error.dart';
import 'package:planted/helpers/compress_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:planted/managers/conectivity_manager.dart';
import 'package:planted/models/announcement.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final connectivityManager = ConnectivityManager();

  AppBloc()
      : super(
          const AppStateInitialState(
            isLoading: false,
          ),
        ) {
    on<AppEventInitialize>(
      (event, emit) async {
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

        final QuerySnapshot query = await FirebaseFirestore.instance
            .collection('profiles')
            .where('userID', isEqualTo: user.uid)
            .get();

        if (query.docs.isEmpty) {
          emit(
            AppStateIsInCompleteProfileView(
              isLoading: false,
              user: user,
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
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(const AppStateIsInRegistrationView(
            isLoading: false,
            authError: AuthErrorNetworkRequestFailed(),
          ));
          return;
        }

        emit(const AppStateIsInRegistrationView(isLoading: true));

        final email = event.email;
        final password = event.password;
        final confirmPassword = event.confirmPassword;
        final areLegalTermsAccepted = event.areLegalTermsAccepted;

        // check if the fields are not empty
        if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
          emit(
            const AppStateIsInRegistrationView(
              isLoading: false,
              authError: AuthErrorFieldsAreEmpty(),
            ),
          );
          return;
        }

        if (areLegalTermsAccepted == false) {
          emit(
            const AppStateIsInRegistrationView(
              isLoading: false,
              authError: AuthErrorLegalTermsNotAccepted(),
            ),
          );
          return;
        }

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
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(const AppStateIsInConfirmationEmailView(
            isLoading: false,
            authError: AuthErrorNetworkRequestFailed(),
          ));
          return;
        }

        emit(const AppStateIsInConfirmationEmailView(isLoading: true));

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

    on<AppEventCompletingUserProfile>(
      (event, emit) async {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          emit(const AppStateLoggedOut(isLoading: false));
          return;
        }

        if (connectivityManager.status == ConnectivityResult.none) {
          emit(AppStateIsInCompleteProfileView(
            user: user,
            isLoading: false,
            authError: const AuthErrorNetworkRequestFailed(),
          ));
          return;
        }

        emit(AppStateIsInCompleteProfileView(user: user, isLoading: true));

        try {
          final String imageURL;

          if (event.imagePath != null) {
            final file = File(event.imagePath!);
            final compressedFile = await compressImage(file.path, 10);
            final File fileToPut;

            if (compressedFile != null) {
              fileToPut = File(compressedFile.path);
            } else {
              fileToPut = file;
            }

            final task = await FirebaseStorage.instance
                .ref('profileImages')
                .child(user.uid)
                .putFile(fileToPut);

            imageURL = await task.ref.getDownloadURL();
          } else {
            imageURL = '';
          }

          final fcmToken = await FirebaseMessaging.instance.getToken();

          final userProfileData = {
            'displayName': event.displayName,
            'userID': user.uid,
            'photoURL': imageURL,
            'blockedUsers': [],
            'userReports': [],
            'isAdmin': false,
            'fcmToken': fcmToken
          };

          await FirebaseFirestore.instance
              .collection('profiles')
              .doc(user.uid)
              .set(userProfileData);

          emit(AppStateLoggedIn(isLoading: false, user: user));
        } on FirebaseException catch (e) {
          emit(AppStateIsInCompleteProfileView(
            isLoading: false,
            user: user,
            databaseError: DatabaseError.from(e),
          ));
        }
      },
    );

    on<AppEventLogOut>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          final user = FirebaseAuth.instance.currentUser;

          if (user == null) {
            emit(const AppStateLoggedOut(isLoading: false));
            return;
          }

          emit(AppStateLoggedIn(
            isLoading: false,
            user: user,
            authError: const AuthErrorNetworkRequestFailed(),
          ));
          return;
        }

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
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(const AppStateLoggedOut(
            isLoading: false,
            authError: AuthErrorNetworkRequestFailed(),
          ));
          return;
        }

        emit(const AppStateLoggedOut(isLoading: true));

        final email = event.email;
        final password = event.password;

        // check if the fields are not empty
        if (email.isEmpty || password.isEmpty) {
          emit(
            const AppStateLoggedOut(
              isLoading: false,
              authError: AuthErrorFieldsAreEmpty(),
            ),
          );
          return;
        }

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

          final QuerySnapshot query = await FirebaseFirestore.instance
              .collection('profiles')
              .where('userID', isEqualTo: user.uid)
              .get();

          final fcmToken = await FirebaseMessaging.instance.getToken();

          if (query.docs.isEmpty) {
            if (user.displayName != null) {
              final userProfileData = {
                'displayName': user.displayName!,
                'userID': user.uid,
                'photoURL': user.photoURL ?? '',
                'blockedUsers': [],
                'userReports': [],
                'isAdmin': false,
                'fcmToken': fcmToken
              };

              await FirebaseFirestore.instance
                  .collection('profiles')
                  .doc(user.uid)
                  .set(userProfileData);
            } else {
              emit(
                AppStateIsInCompleteProfileView(
                  isLoading: false,
                  user: user,
                ),
              );
            }
            return;
          }

          emit(AppStateLoggedIn(
            isLoading: false,
            user: user,
          ));
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
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(const AppStateLoggedOut(
            isLoading: false,
            authError: AuthErrorNetworkRequestFailed(),
          ));
          return;
        }

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

    on<AppEventDeleteAccount>(
      (event, emit) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(const AppStateLoggedOut(isLoading: true));
          return;
        }

        if (connectivityManager.status == ConnectivityResult.none) {
          emit(AppStateLoggedIn(
            user: user,
            isLoading: false,
            authError: const AuthErrorNetworkRequestFailed(),
          ));
          return;
        }

        emit(AppStateLoggedIn(isLoading: true, user: user));

        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: user.email!,
            password: event.password,
          );
        } on FirebaseAuthException catch (e) {
          emit(AppStateLoggedIn(
            isLoading: false,
            user: user,
            authError: AuthError.from(e),
          ));
          return;
        }

        emit(const AppStateLoggedOut(isLoading: true));

        //change All user announcement to Archived
        final announcements = await FirebaseFirestore.instance
            .collection(announcemensPath)
            .where('giverID', isEqualTo: user.uid)
            .get()
            .then((querySnapshot) => querySnapshot.docs
                .map((snapshot) => Announcement.fromSnapshot(snapshot)));

        final futures = <Future<void>>[];

        for (var announcement in announcements) {
          futures.add(FirebaseFirestore.instance
              .collection(announcemensPath)
              .doc(announcement.docID)
              .update({'status': 3}));
        }

        await Future.wait(futures);

        //DeleteUserImage
        await FirebaseStorage.instance
            .ref(storageProfileImagesRef)
            .child(user.uid)
            .delete()
            .onError((_, __) => null);

        //DeleteUserProfile
        await FirebaseFirestore.instance
            .collection(profilesPath)
            .doc(user.uid)
            .delete()
            .onError((_, __) => null);

        //DeleteAccount
        try {
          await FirebaseAuth.instance.currentUser?.delete();
          emit(const AppStateLoggedOut(
            isLoading: false,
            snackbarMessage: 'Konto zostało usunięte!',
          ));
        } on FirebaseAuthException catch (e) {
          emit(
            AppStateLoggedOut(isLoading: false, authError: AuthError.from(e)),
          );
        }
      },
    );

    on<AppEventOpenLegalTerms>(
      (event, emit) async {
        try {
          final path = await FirebaseFirestore.instance
              .collection(legaltermsPath)
              .doc(event.documentID)
              .get()
              .then((snapshot) => snapshot.data()?['path'] as String);

          emit(AppStateIsInRegistrationView(
            isLoading: false,
            path: path,
          ));
        } on FirebaseException catch (e) {
          emit(AppStateIsInRegistrationView(
            isLoading: false,
            databaseError: DatabaseError.from(e),
          ));
        }
      },
    );
  }
}
