import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../config.dart';

/// Camera capture + client-side compression. Photos are shrunk to a sane long
/// edge BEFORE they enter the sync queue (CLAUDE.md) — field data is often on
/// metered connections.
class PhotoService {
  final _picker = ImagePicker();

  /// Take a photo, compress it, and return the on-disk path of the compressed
  /// file (kept in the app's documents dir so it survives until synced).
  Future<String?> captureCompressed() async {
    final shot = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: AppConfig.photoMaxLongEdge.toDouble(),
      imageQuality: AppConfig.photoQuality,
    );
    if (shot == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final outPath =
        p.join(dir.path, 'photos', '${const Uuid().v4()}.jpg');
    await Directory(p.dirname(outPath)).create(recursive: true);

    final result = await FlutterImageCompress.compressAndGetFile(
      shot.path,
      outPath,
      quality: AppConfig.photoQuality,
      minWidth: AppConfig.photoMaxLongEdge,
      minHeight: AppConfig.photoMaxLongEdge,
      keepExif: false,
    );
    // Fall back to the picker's already-resized file if the codec bails.
    return result?.path ?? shot.path;
  }
}
