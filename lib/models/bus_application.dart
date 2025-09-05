class BusApplication {
  final String regionId;
  final String name;
  final int age;
  final String phoneNumber;
  final String address;
  final String? selectedProgram;
  final String? desiredBook;

  BusApplication({
    required this.regionId,
    required this.name,
    required this.age,
    required this.phoneNumber,
    required this.address,
    this.selectedProgram,
    this.desiredBook,
  });

  Map<String, dynamic> toJson() {
    return {
      'regionId': regionId,
      'name': name,
      'age': age,
      'phoneNumber': phoneNumber,
      'address': address,
      'selectedProgram': selectedProgram,
      'desiredBook': desiredBook,
    };
  }

  factory BusApplication.fromJson(Map<String, dynamic> json) {
    return BusApplication(
      regionId: json['regionId'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      selectedProgram: json['selectedProgram'],
      desiredBook: json['desiredBook'],
    );
  }
}
