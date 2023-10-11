import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:planted/blocs/authBloc/auth_bloc.dart';
import 'package:planted/blocs/authBloc/auth_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/images.dart';
import 'package:planted/styles/create_input_decoration.dart';
import 'package:planted/styles/buttons_styles.dart';
import 'package:planted/styles/text_styles.dart';

class CompleteProfileView extends HookWidget {
  const CompleteProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final ValueNotifier<String?> imagePath = useState(null);
    final imagePicker = useMemoized(() => ImagePicker(), [key]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorEggsheel,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 40,
                      child: Image.asset(plantedLogo),
                    ),
                    const Text(
                      'share nature',
                      style: TextStyle(
                          color: colorSepia,
                          fontWeight: FontWeight.w300,
                          fontSize: 18),
                    )
                  ],
                ),
                const SizedBox(height: 30),
                const Text('Uzupełnij profil', style: titleTextStyle),
                const SizedBox(height: 20),

                //Image here
                ProfileImagePickerView(
                  imagePath: imagePath,
                  imagePicker: imagePicker,
                ),

                const SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  decoration: createInputDecoration(label: 'Nazwa użytkownika'),
                  style: textStyle15BoldSepia,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            AuthEventCompletingUserProfile(
                              displayName: nameController.text,
                              imagePath: imagePath.value,
                            ),
                          );
                    },
                    style: filledButtonStyle,
                    child: const Text('Zapisz'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileImagePickerView extends StatelessWidget {
  const ProfileImagePickerView({
    super.key,
    required this.imagePath,
    required this.imagePicker,
  });

  final ValueNotifier<String?> imagePath;
  final ImagePicker imagePicker;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: imagePath,
      builder: (context, imageData, child) {
        if (imageData == null) {
          return GestureDetector(
            onTap: () async {
              final image = await imagePicker.pickImage(
                source: ImageSource.gallery,
              );

              if (image == null) {
                return;
              }
              if (!context.mounted) return;

              imagePath.value = image.path;
            },
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                SizedBox(
                  height: 100,
                  child: Image.asset('assets/images/person.png'),
                ),
                SizedBox(
                  height: 30,
                  child: Image.asset('assets/images/add.png'),
                ),
              ],
            ),
          );
        } else {
          return GestureDetector(
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorDarkMossGreen, // Border color
                  width: 1.0, // Border width
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: Image.file(File(imagePath.value!), fit: BoxFit.cover),
              ),
            ),
            onTap: () {
              showCupertinoModalPopup(
                context: context,
                builder: (context) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: 120, left: 20, right: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity - 40,
                          child: ElevatedButton(
                            onPressed: () {
                              imagePath.value = null;
                              Navigator.pop(context);
                            },
                            child: const Text('Usuń zdjęcie'),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Anuluj'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
