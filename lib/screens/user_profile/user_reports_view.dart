import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_bloc.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/models/report.dart';
import 'package:planted/screens/user_profile/report_item_list_tile.dart';
import 'package:planted/screens/views/empty_state_view.dart';

class UserReportsView extends StatelessWidget {
  const UserReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final reportStream =
        context.watch<UserProfileScreenBloc>().state.reportsStream;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorEggsheel,
        leading: IconButton(
          onPressed: () {
            context
                .read<UserProfileScreenBloc>()
                .add(const UserProfileScreenEventGoToUserProfileView());
          },
          icon: const Icon(Icons.arrow_back),
          style: IconButton.styleFrom(
            shadowColor: colorSepia.withAlpha(50),
          ),
          color: colorSepia,
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Twoje zgłoszenia',
            style: TextStyle(
              color: colorSepia,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Report>>(
        stream: reportStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const EmptyStateView(
              message:
                  'Nie udało się pobrać twoich zgłoszeń. Sprawdz połączenie z internetem i spróbuj ponownie za chwilę.',
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!;

          if (reports.isEmpty) {
            return const EmptyStateView(
                message: 'Nie masz żadnych zgłoszeń do wyświetlenia.');
          }

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports.elementAt(index);
                return ReportItemListTile(report: report);
              },
            ),
          );
        },
      ),
    );
  }
}
