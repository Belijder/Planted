import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planted/auth_error.dart';
import 'package:planted/blocs/app_bloc.dart/app_event.dart';
import 'package:planted/blocs/app_bloc.dart/app_state.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/database_error.dart';
import 'package:planted/helpers/compress_image.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
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
            if (user.displayName != null) {
              final userProfileData = {
                'displayName': user.displayName!,
                'userID': user.uid,
                'photoURL': user.photoURL
              };

              await FirebaseFirestore.instance
                  .collection('profiles')
                  .doc(user.uid)
                  .set(userProfileData);

              emit(AppStateLoggedIn(
                isLoading: false,
                user: user,
              ));
            } else {
              emit(AppStateIsInCompleteProfileView(
                isLoading: false,
                user: user,
              ));
            }
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

    on<AppEventCompletingUserProfile>(
      (event, emit) async {
        emit(const AppStateIsInConfirmationEmailView(isLoading: true));

        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          emit(const AppStateLoggedOut(isLoading: false));
          return;
        }

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

          final userProfileData = {
            'displayName': event.displayName,
            'userID': user.uid,
            'photoURL': imageURL,
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
    on<AppEventAddNewAnnouncement>(
      (event, emit) async {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          emit(
            const AppStateLoggedOut(
              isLoading: false,
              authError: AuthErrorNoCurrentUser(),
            ),
          );
          return;
        }

        emit(AppStateLoggedIn(isLoading: true, user: user));

        final announcementId = const Uuid().v4();

        final timeStamp = DateTime.timestamp();

        final file = File(event.imagePath);

        final docData = {
          'docID': announcementId,
          'name': event.name,
          'latinName': event.latinName,
          'seedCount': event.seedCount,
          'city': event.city,
          'description': event.description,
          'timeStamp': timeStamp,
          'giverID': user.uid
        };

        try {
          final compressedFile = await compressImage(file.path, 30);
          final File fileToPut;

          if (compressedFile != null) {
            fileToPut = File(compressedFile.path);
          } else {
            fileToPut = file;
          }

          await FirebaseStorage.instance
              .ref('images')
              .child(announcementId)
              .putFile(fileToPut);

          final db = FirebaseFirestore.instance;
          await db.collection('announcements').doc(announcementId).set(docData);

          emit(
            AppStateLoggedIn(
              isLoading: false,
              user: user,
              shouldClean: true,
              snackbarMessage: 'Ogłoszenie zostało dodane!',
            ),
          );
        } on FirebaseException catch (e) {
          emit(
            AppStateLoggedIn(
              isLoading: false,
              user: user,
              databaseError: DatabaseError.from(e),
            ),
          );
        }
      },
    );

    on<AppEventAnnouncemmentFieldsCleaned>(
      (event, emit) {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          emit(
            const AppStateLoggedOut(
              isLoading: false,
              authError: AuthErrorNoCurrentUser(),
            ),
          );
          return;
        }
        emit(AppStateLoggedIn(isLoading: false, user: user));
      },
    );
  }
}
