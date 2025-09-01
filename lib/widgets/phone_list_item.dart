import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/phone.dart';
import '../screens/edit_phone_screen.dart';

class PhoneListItem extends StatelessWidget {
  final Phone phone;
  const PhoneListItem({
    required this.phone,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.all(4.0),
      child: Stack(
        children: [
          ListTile(
            leading: SizedBox(
              width: 50.0, // Adjust the width as needed
              height: 50.0, // Adjust the height as needed
              child: Image.asset(brandsImages[brandsList.indexOf(phone.brand)]),
            ),
            title: Text(
              phone.name,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.of(context).pushNamed(
                EditPhoneScreen.routeName,
                arguments: phone,
              );
            },
            subtitle: Text(
              '${phone.ram}/${phone.storage}',
              style: const TextStyle(fontSize: 17.0),
            ),
            trailing: Text(
              '${phone.salePrice} Da',
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
          if (!phone.isAvailable)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4.0),
                color: Colors.red,
                child: const Text(
                  'SOLD',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
