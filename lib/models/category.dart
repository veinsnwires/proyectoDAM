class Category {
  final String id;
  final String name; // The display name: "Charla", "Workshop"
  final String imagePath; // Local asset path

  Category({
    required this.id,
    required this.name,
    required this.imagePath,
  });

  // Factory: From Firebase (Map) -> To App (Object)
  factory Category.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Category(
      id: documentId,
      name: data['name'] ?? 'Unnamed',
      // We assume the DB stores just the filename (e.g., "poke4.jpg")
      imagePath: 'assets/images/${data['photo'] ?? 'default.jpg'}',
    );
  }
}
