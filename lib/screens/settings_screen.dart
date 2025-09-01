import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:phones_management/providers/phone_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:phones_management/models/phone.dart';
import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  Future<void> _importJsonFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Changed from FileType.custom to FileType.any
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final jsonContent = await file.readAsString();
        final List<dynamic> jsonData = json.decode(jsonContent);

        final List<Phone> phones =
            jsonData.map((data) => Phone.fromJson(data)).toList();

        final phoneProvider =
            Provider.of<PhoneProvider>(context, listen: false);
        phoneProvider.loadPhonesFromDatabase(phones);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phones imported successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing file: ${e.toString()}')),
      );
    }
  }

  Future<void> _exportJsonFile(BuildContext context) async {
    try {
      // Request storage permission first
      final permission = await _requestStoragePermission();
      if (!permission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Storage permission is required to export files')),
        );
        return;
      }

      final phoneProvider = Provider.of<PhoneProvider>(context, listen: false);
      await phoneProvider.loadPhones(); // Ensure phones are loaded
      final jsonList =
          phoneProvider.phones.map((phone) => phone.toJson()).toList();
      final jsonContent = json.encode(jsonList);

      // Get current date for versioning
      final DateTime now = DateTime.now();
      final String dateString =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final fileName = 'phones_export_$dateString.json';

      // Try multiple export methods for better compatibility
      final result = await _tryExportMethods(jsonContent, fileName);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Phones exported successfully: $fileName\nSaved to: ${result['path']}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Failed to export file. Check app permissions and storage space.')),
        );
      }
    } catch (e) {
      print('Export error: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting file: ${e.toString()}')),
      );
    }
  }

  Future<bool> _requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
      return true;
    } catch (e) {
      print('Permission request error: ${e.toString()}');
      // Fallback to assuming permission is granted
      return true;
    }
  }

  Future<Map<String, dynamic>> _tryExportMethods(
      String jsonContent, String fileName) async {
    // Method 1: Try downloadsfolder package
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsString(jsonContent);

      bool? success = await copyFileIntoDownloadFolder(tempFile.path, fileName);
      await tempFile.delete(); // Clean up temp file

      if (success == true) {
        return {'success': true, 'path': 'Downloads folder'};
      }
    } catch (e) {
      print('Method 1 failed: ${e.toString()}');
    }

    // Method 2: Try traditional Android Downloads path (for older devices like Android 7)
    try {
      const String traditionalDownloadsPath = '/storage/emulated/0/Download';
      final downloadsDir = Directory(traditionalDownloadsPath);
      if (await downloadsDir.exists()) {
        final file = File('$traditionalDownloadsPath/$fileName');
        await file.writeAsString(jsonContent);
        return {'success': true, 'path': traditionalDownloadsPath};
      }
    } catch (e) {
      print('Method 2 (traditional path) failed: ${e.toString()}');
    }

    // Method 3: Try external_path package
    try {
      // Use the correct method for getting Downloads directory
      List<String>? paths = await ExternalPath.getExternalStorageDirectories();
      if (paths != null && paths.isNotEmpty) {
        // Get the first external storage path and append Downloads
        String downloadsPath =
            '${paths.first}/Download'; // Note: Download not Downloads on some devices
        final downloadsDir = Directory(downloadsPath);
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        final file = File('$downloadsPath/$fileName');
        await file.writeAsString(jsonContent);
        return {'success': true, 'path': downloadsPath};
      }
    } catch (e) {
      print('Method 3 failed: ${e.toString()}');
    }

    // Method 4: Fallback to app's external directory
    try {
      final Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final file = File('${externalDir.path}/$fileName');
        await file.writeAsString(jsonContent);
        return {'success': true, 'path': '${externalDir.path} (App folder)'};
      }
    } catch (e) {
      print('Method 4 failed: ${e.toString()}');
    }

    return {'success': false, 'path': ''};
  }

  @override
  Widget build(BuildContext context) {
    // Use provider from child widgets when needed; no local usage here.
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Import JSON from device'),
            leading: const Icon(Icons.file_upload),
            onTap: () => _importJsonFile(context),
          ),
          ListTile(
            title: const Text('Export JSON to device'),
            leading: const Icon(Icons.file_download),
            onTap: () => _exportJsonFile(context),
          ),
        ],
      ),
    );
  }
}
