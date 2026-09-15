enum Role { customer, seller, admin }

extension RoleX on Role {
  String get name {
    switch (this) {
      case Role.customer:
        return 'customer';
      case Role.seller:
        return 'seller';
      case Role.admin:
        return 'admin';
    }
  }

  static Role fromString(String value) {
    switch (value) {
      case 'seller':
        return Role.seller;
      case 'admin':
        return Role.admin;
      case 'customer':
      default:
        return Role.customer;
    }
  }
}