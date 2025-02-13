class Specs {
  final String? brand;
  final String? material;
  final String? dimensions;
  final String? features;
  final String? manufacturedYear;
  final String? color;
  final String? model;
  final String? size;
  final String? location;

  const Specs({
    this.brand,
    this.material,
    this.dimensions,
    this.features,
    this.manufacturedYear,
    this.color,
    this.model,
    this.size,
    this.location,
  });

  factory Specs.fromJson(Map<String, dynamic> json) {
    return Specs(
      brand: json['brand'] as String?,
      material: json['material'] as String?,
      dimensions: json['dimensions'] as String?,
      features: json['features'] as String?,
      manufacturedYear: json['manufacturedYear'] as String?,
      color: json['color'] as String?,
      model: json['model'] as String?,
      size: json['size'] as String?,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'material': material,
      'dimensions': dimensions,
      'features': features,
      'manufacturedYear': manufacturedYear,
      'color': color,
      'model': model,
      'size': size,
      'location': location,
    };
  }
}
