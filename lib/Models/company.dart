/// Represents the company of the current
class Company {
  /// The name of this company
  final String name;

  /// The logo of this company
  final String logo;

  // The company website
  final String website;

  // The company principal phone number
  final String phone;

  Company(this.name, {this.logo = "", this.website = "", this.phone});
}
