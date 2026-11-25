enum BalanceAccountType { bank, cash }

enum BalanceBrand {
  commercialBank,
  sampathBank,
  hattonNationalBank,
  physicalWallet,
  homeCashReserve,
  genericBank,
  genericCash,
}

class BalanceAccount {
  final String id;
  final String name;
  final String? subtitle;
  final double balance;
  final BalanceAccountType type;
  final BalanceBrand brand;
  final bool isHighlighted;

  const BalanceAccount({
    required this.id,
    required this.name,
    this.subtitle,
    required this.balance,
    required this.type,
    required this.brand,
    this.isHighlighted = false,
  });

  BalanceAccount copyWith({
    String? id,
    String? name,
    String? subtitle,
    double? balance,
    BalanceAccountType? type,
    BalanceBrand? brand,
    bool? isHighlighted,
  }) {
    return BalanceAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }

  Map<String, Object?> toMap({DateTime? timestamp}) {
    final nowIso = (timestamp ?? DateTime.now().toUtc()).toIso8601String();
    return <String, Object?>{
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'balance': balance,
      'type': type.name,
      'brand': brand.name,
      'is_highlighted': isHighlighted ? 1 : 0,
      'updated_at': nowIso,
    };
  }

  factory BalanceAccount.fromMap(Map<String, Object?> map) {
    final typeName = map['type']?.toString();
    final type = BalanceAccountType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => BalanceAccountType.bank,
    );

    final brandName = map['brand']?.toString();
    final brand = BalanceBrand.values.firstWhere(
      (e) => e.name == brandName,
      orElse: () => type == BalanceAccountType.bank
          ? BalanceBrand.genericBank
          : BalanceBrand.genericCash,
    );

    final rawBalance = map['balance'];
    final balance = rawBalance is num
        ? rawBalance.toDouble()
        : double.tryParse(rawBalance?.toString() ?? '') ?? 0.0;

    final rawHighlighted = map['is_highlighted'];
    final isHighlighted = rawHighlighted is bool
        ? rawHighlighted
        : (rawHighlighted is num ? rawHighlighted != 0 : false);

    final rawSubtitle = map['subtitle']?.toString();

    return BalanceAccount(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      subtitle: rawSubtitle != null && rawSubtitle.isNotEmpty
          ? rawSubtitle
          : null,
      balance: balance,
      type: type,
      brand: brand,
      isHighlighted: isHighlighted,
    );
  }
}
