import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:planted/blocs/addScreenBloc/add_screen_bloc.dart';
import 'package:planted/blocs/addScreenBloc/add_screen_event.dart';
import 'package:planted/blocs/addScreenBloc/add_screen_state.dart';
import 'package:planted/blocs/authBloc/auth_bloc.dart';
import 'package:planted/blocs/authBloc/auth_event.dart';
import 'package:planted/blocs/authBloc/auth_state.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/styles/create_input_decoration.dart';
import 'package:planted/styles/box_decoration_styles.dart';
import 'package:planted/styles/buttons_styles.dart';
import 'package:planted/styles/text_styles.dart';
import 'package:planted/utilities/dialogs/show_database_error_dialog.dart';
import 'package:planted/utilities/dialogs/show_information_dialog.dart';
import 'package:planted/utilities/loading/loading_screen.dart';

enum AddAnnouncementViewMenuAction { remove }

class AddAnnouncementView extends HookWidget {
  const AddAnnouncementView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final latinNameController = useTextEditingController();
    final cityNameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final seedCount = useState(1);
    final ValueNotifier<String?> imagePath = useState(null);
    final imagePicker = useMemoized(() => ImagePicker(), [key]);
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              AppBarTitleText.add,
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
      body: BlocListener<AddScreenBloc, AddScreenState>(
        listener: (context, addScreenState) {
          if (addScreenState.isLoading) {
            LoadingScreen.instance().show(
              context: context,
              text: LoadingScreenText.adding,
            );
          } else {
            LoadingScreen.instance().hide();
          }

          final error = addScreenState.databaseError;
          if (error != null) {
            showDatabaseErrorDialog(
              context: context,
              databaseError: error,
            );
          }

          final message = addScreenState.snackbarMessage;
          if (message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 2),
                content: Text(message),
              ),
            );
          }

          if (addScreenState.shouldCleanFields) {
            nameController.text = '';
            latinNameController.text = '';
            cityNameController.text = '';
            descriptionController.text = '';
            imagePath.value = null;
            seedCount.value = 1;
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  TextField(
                    controller: nameController,
                    decoration: createInputDecoration(
                      label: CustomText.nameLabel,
                    ),
                    style: TextStyles.bodyTextStyle(weight: FontWeight.bold),
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    textCapitalization: TextCapitalization.sentences,
                    enableSuggestions: false,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: latinNameController,
                    decoration: createInputDecoration(
                      label: CustomText.latinNameLabel,
                    ),
                    style: TextStyles.bodyTextStyle(weight: FontWeight.bold),
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    textCapitalization: TextCapitalization.sentences,
                    enableSuggestions: false,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ImageView(imagePath: imagePath, imagePicker: imagePicker),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            SeedStepper(seedCount: seedCount),
                            const SizedBox(height: 20),
                            TextField(
                              controller: cityNameController,
                              decoration: createInputDecoration(
                                  label: CustomText.cityLabel),
                              style: TextStyles.bodyTextStyle(
                                  weight: FontWeight.bold),
                              onSubmitted: (_) =>
                                  FocusScope.of(context).unfocus(),
                              onTapOutside: (_) =>
                                  FocusScope.of(context).unfocus(),
                              textCapitalization: TextCapitalization.sentences,
                              enableSuggestions: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 150,
                    child: TextField(
                      controller: descriptionController,
                      decoration: createInputDecoration(
                        label: CustomText.descriptionLabel,
                      ),
                      style: TextStyles.bodyTextStyle(weight: FontWeight.bold),
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      minLines: null,
                      maxLines: null,
                      expands: true,
                      textCapitalization: TextCapitalization.sentences,
                      enableSuggestions: false,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: filledButtonStyle,
                      onPressed: () {
                        if (imagePath.value == null) {
                          showInformationDialog(
                            context: context,
                            title: DialogTitleText.photoRequired,
                            content: DialogContentText.photoRequired,
                          );
                          return;
                        }

                        if (nameController.text.isEmpty ||
                            cityNameController.text.isEmpty) {
                          showInformationDialog(
                            context: context,
                            title: DialogTitleText.completeFields,
                            content: DialogContentText.completeFields,
                          );
                          return;
                        }

                        final user = context.read<AuthBloc>().state.user;
                        if (user == null) {
                          context
                              .read<AuthBloc>()
                              .add(const AuthEventGoToLoginView());
                          return;
                        }

                        context.read<AddScreenBloc>().add(
                              AddNewAnnouncementAddScreenEvent(
                                user: user,
                                name: nameController.text,
                                latinName: latinNameController.text,
                                imagePath: imagePath.value!,
                                seedCount: seedCount.value,
                                city: cityNameController.text,
                                description: descriptionController.text,
                              ),
                            );
                      },
                      child: const Text(ButtonLabelText.addAnnouncement),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImageView extends StatelessWidget {
  const ImageView({
    super.key,
    required this.imagePath,
    required this.imagePicker,
  });

  final ValueNotifier<String?> imagePath;
  final ImagePicker imagePicker;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: (MediaQuery.of(context).size.width / 2) - 30,
        decoration: BoxDecoration(
          border: Border.all(
            color: imagePath.value == null
                ? colorSepia
                : colorDarkMossGreen, // Border color
            width: 1.0, // Border width
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ValueListenableBuilder(
          valueListenable: imagePath,
          builder: (context, imageData, child) {
            if (imageData == null) {
              return IconButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: colorDarkMossGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final image = await imagePicker.pickImage(
                    source: ImageSource.gallery,
                  );

                  if (image == null) {
                    return;
                  }
                  if (!context.mounted) return;

                  imagePath.value = image.path;
                },
                icon: const Icon(
                  Icons.add_a_photo_outlined,
                  size: 30,
                  color: colorDarkMossGreen,
                ),
              );
            } else {
              return GestureDetector(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11.0),
                  child: Image.file(File(imagePath.value!), fit: BoxFit.cover),
                ),
                onTap: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) {
                      return Container(
                        decoration: cupertinoModalPopapBoxDecoration,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: double.infinity - 40,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: colorRedKenyanCopper,
                                  ),
                                  onPressed: () {
                                    imagePath.value = null;
                                    Navigator.pop(context);
                                  },
                                  child:
                                      const Text(ButtonLabelText.removeImage),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(ButtonLabelText.cancel),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class SeedStepper extends StatelessWidget {
  const SeedStepper({
    super.key,
    required this.seedCount,
  });

  final ValueNotifier<int> seedCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton.filledTonal(
          style: ElevatedButton.styleFrom(
            foregroundColor: colorDarkMossGreen,
            backgroundColor: colorDarkMossGreen.withAlpha(100),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(
            Icons.remove,
            size: 44,
          ),
          onPressed: () {
            if (seedCount.value > 1) {
              seedCount.value -= 1;
            }
          },
        ),
        Text(
          '${seedCount.value}',
          style: TextStyles.largeTitleTextStyle(weight: FontWeight.bold),
        ),
        IconButton.filledTonal(
          style: ElevatedButton.styleFrom(
            foregroundColor: colorDarkMossGreen,
            backgroundColor: colorDarkMossGreen.withAlpha(100),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(
            Icons.add,
            size: 44,
          ),
          onPressed: () {
            if (seedCount.value < 10) {
              seedCount.value += 1;
            }
          },
        ),
      ],
    );
  }
}
