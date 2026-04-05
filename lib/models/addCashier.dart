class Addcashier {

  final int? id;
  final String name;
  final String username;
  final String email;
  final String contactNo;
  final String address;
  final String password;
  final String role;


Addcashier({
  this.id, 
  required this.name, 
  required this.username, 
  required this.email,
  required this.contactNo,
  required this.address,
  required this.password,
  this.role = 'cashier'});

    Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'contact_number': contactNo,
      'address': address,
      'password': password,
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
      'is_synced': 0,
    };
  }

}