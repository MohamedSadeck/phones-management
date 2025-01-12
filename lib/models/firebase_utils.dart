import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'phone.dart';

class FirebaseUtils {
  static const _baseUrl =
      'https://store-app-f4462-default-rtdb.europe-west1.firebasedatabase.app/phones.json';

  static Future<List<Phone>> getPhoneDataFromFirebase() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      List<Phone> phones = [];

      data.forEach((key, value) {
        Phone phone = Phone.fromJson(value);
        phones.add(phone);
      });
      Fluttertoast.showToast(
          msg: 'Phone data imported successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);

      return phones;
    } else {
      Fluttertoast.showToast(
          msg: 'Failed to fetch phone data',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      throw Exception('Failed to fetch phone data');
    }
  }

  static Future<void> uploadPhoneData(List<Phone> phones) async {
    final Map<String, dynamic> phonesJsonMap = Map.fromEntries(
      phones.map((phone) => MapEntry(phone.id, phone.toJson())),
    );

    final response =
        await http.put(Uri.parse(_baseUrl), body: json.encode(phonesJsonMap));

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg: 'Phone data uploaded successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: 'Failed to upload phone data',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
