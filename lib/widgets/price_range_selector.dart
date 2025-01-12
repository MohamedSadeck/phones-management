import 'package:flutter/material.dart';

class PriceRangeSelector extends StatefulWidget {
  final Function(int min, int max) onRangeChanged;

  const PriceRangeSelector({super.key, required this.onRangeChanged});

  @override
  State<PriceRangeSelector> createState() => _PriceRangeSelectorState();
}

class _PriceRangeSelectorState extends State<PriceRangeSelector> {
  static const int minPriceLimit = 15000;
  static const int maxPriceLimit = 150000;

  int _minPrice = minPriceLimit;
  int _maxPrice = maxPriceLimit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Price Range: $_minPrice - $_maxPrice'),
        RangeSlider(
          values: RangeValues(
            _minPrice.toDouble(),
            _maxPrice.toDouble(),
          ),
          min: minPriceLimit.toDouble(),
          max: maxPriceLimit.toDouble(),
          onChanged: (values) {
            setState(() {
              _minPrice = values.start.toInt();
              _maxPrice = values.end.toInt();
              widget.onRangeChanged(_minPrice, _maxPrice);
            });
          },
          labels: RangeLabels(
            _minPrice.toStringAsFixed(0),
            _maxPrice.toStringAsFixed(0),
          ),
          divisions: 10,
        ),
      ],
    );
  }
}
