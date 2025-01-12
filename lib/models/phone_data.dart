// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:phones_management/models/phone.dart';

Future<List<Phone>> loadPhoneData() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/phones.json');

    if (file.existsSync()) {
      final jsonData = await file.readAsString();
      final List<dynamic> phoneListData = json.decode(jsonData);

      List<Phone> phoneList = [];
      for (var phoneData in phoneListData) {
        phoneList.add(Phone.fromJson(phoneData));
      }
      // print('load phone data');
      // seePhones(phoneList);
      phoneList.sort((a, b) => a.price.compareTo(b.price));
      return phoneList;
    } else {
      return [];
    }
  } catch (e) {
    print('Error loading phone data: $e');
    return [];
  }
}

Future<void> savePhoneData(List<Phone> phones) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/phones.json');

    final jsonList = phones.map((phone) => phone.toJson()).toList();

    // Encode to JSON and write to file
    await file.writeAsString(jsonEncode(jsonList));
  } catch (e) {
    print('savePhoneData error : $e');
  }
}

Future<void> clearPhoneData() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/phones.json');

    if (file.existsSync()) {
      await file.writeAsString('[]'); // Write an empty JSON array
    }
  } catch (e) {
    print('clearPhoneData error : $e');
  }
}

void seePhones(List<Phone> list) {
  for (Phone phone in list) {
    print('name : ${phone.name}');
  }
}
