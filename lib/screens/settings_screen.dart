import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:phones_management/providers/phone_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:phones_management/models/phone.dart';
import 'package:downloadsfolder/downloadsfolder.dart';

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

      // Create temporary file first
      final Directory tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsString(jsonContent);

      // Copy to Downloads folder using downloadsfolder package
      bool? success = await copyFileIntoDownloadFolder(tempFile.path, fileName);

      if (success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Phones exported to Downloads folder: $fileName')),
        );

        // Clean up temporary file
        await tempFile.delete();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export to Downloads folder')),
        );
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting file: ${e.toString()}')),
      );
    }
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
