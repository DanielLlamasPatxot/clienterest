class Detection {
  final Map<String, dynamic> bbox;
  final double conf;
  final double classId;

  Detection({required this.bbox, required this.conf, required this.classId});

  static Detection fromJson(Map<String, dynamic> json) {
    if (json['bbox'] == null) {
      throw FormatException("Missing 'bbox' field in JSON");
    }

    return Detection(
      bbox: json['bbox'],
      conf: json['conf'] ??
          0.0, // Si el campo 'conf' está ausente, usa un valor predeterminado
      classId: json['class'] ??
          0.0, // Si el campo 'class' está ausente, usa un valor predeterminado
    );
  }
}
