import 'dart:developer';

import 'package:file_picker/file_picker.dart';

class MediaService {
  MediaService() {}

  // Pick image from the device
  Future<PlatformFile?> pickImageFromLibrary() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(); // type: FileType.image

    if (result != null) {
      // open single file
      PlatformFile file = result.files.first;

      log(file.name);
      log(file.extension.toString());
      log(file.path.toString());

      return file;
    }

    // Do something here if user canceled the picker
    return null;
  }
}
