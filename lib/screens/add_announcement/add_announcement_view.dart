import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/styles/text_styles.dart';

class AddAnnouncementView extends HookWidget {
  const AddAnnouncementView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    // final latinNameController = useTextEditingController();
    // final cityNameController = useTextEditingController();
    // final descriptionController = useTextEditingController();
    // final seedCount = useState(1);
    // final imagePicker = useMemoized(() => ImagePicker(), [key]);
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              'Dodaj',
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nazwa',
                  labelStyle: formLabelTextStyle,
                  floatingLabelStyle: formFloatingLabelTextStyle,
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: colorDarkMossGreen,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: colorSepia,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                style: formTextStyle,
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
