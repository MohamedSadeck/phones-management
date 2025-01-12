import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phones_management/providers/phone_provider.dart';

import '../models/firebase_utils.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phoneProvider = Provider.of<PhoneProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Import from the DataBase'),
            leading: const Icon(Icons.download_sharp),
            onTap: () async {
              phoneProvider.loadPhonesFromDatabase(
                  await FirebaseUtils.getPhoneDataFromFirebase());
              // seePhones(await FirebaseUtils.getPhoneDataFromFirebase(context));
            },
          ),
          ListTile(
            title: const Text('Save to the DataBase'),
            leading: const Icon(Icons.save),
            onTap: () async => FirebaseUtils.uploadPhoneData(
                await phoneProvider.loadPhoneList()),
          ),
        ],
      ),
    );
  }
}
