import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phones_management/providers/phone_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';

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
        final jsonData = json.decode(jsonContent);

        final phoneProvider =
            Provider.of<PhoneProvider>(context, listen: false);
        phoneProvider.loadPhonesFromDatabase(jsonData);

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
        ],
      ),
    );
  }
}
