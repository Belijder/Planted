import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/app_bloc.dart/app_bloc.dart';
import 'package:planted/blocs/app_bloc.dart/app_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/styles/buttons_styles.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              'Twoje konto',
              style: TextStyle(
                  color: colorSepia,
                  fontSize: 30.0,
                  fontWeight: FontWeight.w800),
            ),
          ],
        ),
        backgroundColor: colorEggsheel,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                style: filledButtonStyle,
                onPressed: () {
                  context.read<AppBloc>().add(
                        const AppEventLogOut(),
                      );
                },
                child: const Text('Wyloguj się'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
