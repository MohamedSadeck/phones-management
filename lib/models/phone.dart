class Phone {
  final String id;
  final String brand;
  final String name;
  final String storage;
  final String ram;
  final int price;
  bool isAvailable; // Optional: for the image of the phone

  Phone({
    required this.id,
    required this.brand,
    required this.name,
    required this.storage,
    required this.ram,
    required this.price,
    required this.isAvailable, // Default to empty string if no image is provided
  });

  void setAvailable(bool isAvailable) {
    this.isAvailable = isAvailable;
  }

  factory Phone.fromJson(Map<String, dynamic> json) {
    return Phone(
      id: json['id'],
      brand: json['brand'] as String,
      name: json['name'] as String,
      storage: json['storage'] as String,
      ram: json['ram'] as String,
      price: json['price'] as int,
      isAvailable: json['isAvailable'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'ram': ram,
      'storage': storage,
      'price': price,
      'name': name,
      'isAvailable': isAvailable,
    };
  }
}
