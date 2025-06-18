import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileService {
  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory?.path ?? '';
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  Future<File> saveCsv(String csvData) async {
    final path = await _localPath;
    final fileName = 'payments_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('$path/$fileName');

    return file.writeAsString(csvData);
  }
}
