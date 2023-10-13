import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_bloc.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/models/report.dart';
import 'package:planted/screens/userProfile/report_item_list_tile.dart';
import 'package:planted/screens/views/empty_state_view.dart';

class ReportsTabBarView extends StatelessWidget {
  const ReportsTabBarView({super.key});

  @override
  Widget build(BuildContext context) {
    final reportStream =
        context.watch<UserProfileScreenBloc>().state.reportsStream;

    return StreamBuilder<List<Report>>(
      stream: reportStream,
      builder: (context, snapshot) {
        if (snapshot.hasError || snapshot.data == null) {
          return const EmptyStateView(
            message: StreamMessageText.reportsError,
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = snapshot.data!;

        if (reports.isEmpty) {
          return const EmptyStateView(
            message: StreamMessageText.reportsEmpty,
          );
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
    );
  }
}
