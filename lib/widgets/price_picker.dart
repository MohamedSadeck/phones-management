import 'package:flutter/material.dart';

class PricePicker extends StatefulWidget {
  final List<int> initialDigits;

  const PricePicker({super.key, required this.initialDigits});

  @override
  State<PricePicker> createState() => _PricePickerState();
}

class _PricePickerState extends State<PricePicker> {
  late List<int> _selectedDigits;

  @override
  void initState() {
    super.initState();
    _selectedDigits = widget.initialDigits;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDigitSelector(0),
                _buildDigitSelector(1),
                _buildDigitSelector(2),
                _buildDigitSelector(3),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _formatPrice(
                  '${_selectedDigits[0]}${_selectedDigits[1]}${_selectedDigits[2]}${_selectedDigits[3]}00'),
              style: const TextStyle(fontSize: 40),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedDigits),
                  child: const Text('OK'),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitSelector(int index) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey),
          ),
          child: IconButton(
            icon: const Icon(Icons.keyboard_arrow_up),
            onPressed: () {
              setState(() {
                _selectedDigits[index] = (_selectedDigits[index] + 1) % 10;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            _selectedDigits[index].toString(),
            style: const TextStyle(fontSize: 40),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey),
          ),
          child: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () {
              setState(() {
                _selectedDigits[index] = (_selectedDigits[index] - 1 + 10) % 10;
              });
            },
          ),
        ),
      ],
    );
  }

  String _formatPrice(String price) {
    // Remove leading zeros
    price = price.replaceFirst(RegExp('^0+'), '');
    // If empty (all were zeros), return "0"
    if (price.isEmpty) return '0 DA';

    // Add spaces every 3 digits from the right
    final characters = price.split('').reversed.toList();
    for (var i = 3; i < characters.length; i += 4) {
      characters.insert(i, ' ');
    }
    return '${characters.reversed.join('')} DA';
  }
}
