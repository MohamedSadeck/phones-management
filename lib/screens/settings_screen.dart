import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phones_management/providers/phone_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:phones_management/models/phone.dart';
import 'package:path_provider/path_provider.dart'; // updated import
import 'package:phones_management/utils/logger.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  Future<void> _importJsonFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
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

      // Get the base external storage directory
      final Directory? baseDir = await getExternalStorageDirectory();
      if (baseDir != null) {
        final String downloadsPath =
            '${baseDir.path.split('Android')[0]}Download';
        final filePath = '$downloadsPath/phones_export.json';
        final file = File(filePath);
        await file.writeAsString(jsonContent);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phones exported to: $filePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not access external storage')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting file: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final phoneProvider = Provider.of<PhoneProvider>(context);
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
