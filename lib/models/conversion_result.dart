class ConversionResult {
  const ConversionResult({
    required this.outputPath,
    required this.fileName,
    required this.width,
    required this.height,
  });

  final String outputPath;
  final String fileName;
  final int width;
  final int height;
}

class SelectedFloorPlan {
  const SelectedFloorPlan({
    required this.path,
    required this.name,
    required this.extension,
    required this.pdfPages,
  });

  final String path;
  final String name;
  final String extension;
  final int pdfPages;

  bool get isPdf => extension.toLowerCase() == 'pdf';
}
