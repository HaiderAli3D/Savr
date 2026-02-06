
class UserPreferences {
  final bool sulfateFree;
  final bool organicOnly;
  final bool noBrandSwaps;
  final bool vegetarian;
  final bool vegan;
  final bool glutenFree;
  final String budgetFocus; // 'Lowest Price', 'Balanced', 'Best Quality'

  UserPreferences({
    this.sulfateFree = false,
    this.organicOnly = false,
    this.noBrandSwaps = false,
    this.vegetarian = false,
    this.vegan = false,
    this.glutenFree = false,
    this.budgetFocus = 'Balanced',
  });

  UserPreferences copyWith({
    bool? sulfateFree,
    bool? organicOnly,
    bool? noBrandSwaps,
    bool? vegetarian,
    bool? vegan,
    bool? glutenFree,
    String? budgetFocus,
  }) {
    return UserPreferences(
      sulfateFree: sulfateFree ?? this.sulfateFree,
      organicOnly: organicOnly ?? this.organicOnly,
      noBrandSwaps: noBrandSwaps ?? this.noBrandSwaps,
      vegetarian: vegetarian ?? this.vegetarian,
      vegan: vegan ?? this.vegan,
      glutenFree: glutenFree ?? this.glutenFree,
      budgetFocus: budgetFocus ?? this.budgetFocus,
    );
  }
}

class BasketItem {
  final String id;
  final String name; 
  final String rawName;
  final double price;
  final String quantity; // e.g., "100ml", "250g"
  final String category;

  BasketItem({
    required this.id,
    required this.name,
    required this.rawName,
    required this.price,
    required this.quantity,
    required this.category,
  });

  factory BasketItem.fromJson(Map<String, dynamic> json) {
    return BasketItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      rawName: json['rawName'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? '',
      category: json['category'] ?? '',
    );
  }
}

class ComparisonItem {
  final BasketItem original;
  final BasketItem alternative;
  final String reason; // Why this matches constraints
  final double savings;
  final List<String> tags; // e.g. ["Sulfat-Free", "Value-Frase"]

  ComparisonItem({
    required this.original,
    required this.alternative,
    required this.reason,
    required this.savings,
    required this.tags,
  });
}

class SavingsReport {
  final String id;
  final DateTime date;
  final List<ComparisonItem> substitutions;
  final double totalOriginalPrice;
  final double totalSavings;
  final double percentageSaved;

  SavingsReport({
    required this.id,
    required this.date,
    required this.substitutions,
    required this.totalOriginalPrice,
    required this.totalSavings,
    required this.percentageSaved,
  });
}
