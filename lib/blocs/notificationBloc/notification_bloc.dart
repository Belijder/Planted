import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/notificationBloc/notification_event.dart';
import 'package:planted/blocs/notificationBloc/notification_state.dart';
import 'package:planted/managers/firebase_database_manager.dart';
import 'package:planted/managers/push_notifications_manager.dart';
import 'package:planted/models/conversation.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final notificationManager = PushNotificationManager();
  final dataBaseManager = FirebaseDatabaseManager();

  late Stream<Iterable<Conversation>> unreadMessagesStream;

  NotificationBloc()
      : super(
          const NotificationState(
            currentBadgeNumber: 0,
            conversationsIDs: [],
          ),
        ) {
    on<NotificationInitializeEvent>(
      (event, emit) {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          return;
        }
        unreadMessagesStream =
            dataBaseManager.getUnreadConversationsIDsStreamFor(user.uid);

        add(const StartMonitoring());
      },
    );

    on<StartMonitoring>(_onStarted);

    on<NewNotificationArrivedEvent>(
      (event, emit) {
        final message = event.message;
        notificationManager.showFlutterNotification(message);
      },
    );
  }

  Future<void> _onStarted(
      StartMonitoring event, Emitter<NotificationState> emit) {
    return emit.forEach(
      unreadMessagesStream,
      onData: (conversationsIDs) => NotificationState(
          currentBadgeNumber: conversationsIDs.length,
          conversationsIDs: conversationsIDs.map((e) => e.conversationID)),
    );
  }
}
