import 'package:path/path.dart' as p;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

Future<XFile?> compressImage(String path, int quality) async {
  final newPath = p.join((await getTemporaryDirectory()).path,
      '${DateTime.now()}${p.extension(path)}');
  final result = await FlutterImageCompress.compressAndGetFile(
    path,
    newPath,
    quality: quality,
  ).onError((error, stackTrace) {
    return null;
  });
  return result;
}
