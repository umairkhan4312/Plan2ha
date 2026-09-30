import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

import '../models/conversion_result.dart';

class FloorPlanConverter {
  Future<SelectedFloorPlan?> selectFile() async {
    final selection = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
      allowMultiple: false,
      withData: false,
    );
    if (selection == null || selection.files.single.path == null) return null;

    final file = selection.files.single;
    final extension = (file.extension ?? p.extension(file.name).substring(1))
        .toLowerCase();
    var pages = 1;
    if (extension == 'pdf') {
      final document = await PdfDocument.openFile(file.path!);
      pages = document.pagesCount;
      await document.close();
    }
    return SelectedFloorPlan(
      path: file.path!,
      name: file.name,
      extension: extension,
      pdfPages: pages,
    );
  }

  Future<ConversionResult> generate(
    SelectedFloorPlan source, {
    int pdfPage = 1,
  }) async {
    final documents = await getApplicationDocumentsDirectory();
    final outputDirectory = Directory(
      p.join(documents.path, 'generated_floor_plans'),
    );
    await outputDirectory.create(recursive: true);

    final base = _safeName(p.basenameWithoutExtension(source.name));
    final pageSuffix = source.isPdf ? '_page_$pdfPage' : '';
    final outputName = '${base}${pageSuffix}_home_assistant.png';
    final outputPath = p.join(outputDirectory.path, outputName);

    late final int width;
    late final int height;
    if (source.isPdf) {
      final dimensions = await _renderPdfPage(
        source.path,
        pdfPage,
        outputPath,
      );
      width = dimensions.$1;
      height = dimensions.$2;
    } else if (source.extension == 'png') {
      final bytes = await File(source.path).readAsBytes();
      final dimensions = await _imageDimensions(bytes);
      width = dimensions.$1;
      height = dimensions.$2;
      await File(outputPath).writeAsBytes(bytes, flush: true);
    } else {
      final bytes = await File(source.path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      width = frame.image.width;
      height = frame.image.height;
      final png = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      if (png == null) throw StateError('Could not convert this image.');
      await File(outputPath).writeAsBytes(
        png.buffer.asUint8List(),
        flush: true,
      );
      frame.image.dispose();
      codec.dispose();
    }

    return ConversionResult(
      outputPath: outputPath,
      fileName: outputName,
      width: width,
      height: height,
    );
  }

  Future<(int, int)> _renderPdfPage(
    String inputPath,
    int pageNumber,
    String outputPath,
  ) async {
    final document = await PdfDocument.openFile(inputPath);
    if (pageNumber < 1 || pageNumber > document.pagesCount) {
      await document.close();
      throw RangeError('The selected PDF page does not exist.');
    }
    final page = await document.getPage(pageNumber);
    try {
      const scale = 3.0;
      final image = await page.render(
        width: page.width * scale,
        height: page.height * scale,
        format: PdfPageImageFormat.png,
        backgroundColor: '#FFFFFFFF',
      );
      if (image == null) throw StateError('Could not render this PDF page.');
      await File(outputPath).writeAsBytes(image.bytes, flush: true);
      return (image.width, image.height);
    } finally {
      await page.close();
      await document.close();
    }
  }

  Future<(int, int)> _imageDimensions(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final dimensions = (frame.image.width, frame.image.height);
    frame.image.dispose();
    codec.dispose();
    return dimensions;
  }

  String _safeName(String value) {
    final normalized = value.replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_');
    return normalized.replaceAll(RegExp(r'^_+|_+$'), '').isEmpty
        ? 'floor_plan'
        : normalized.replaceAll(RegExp(r'^_+|_+$'), '');
  }
}
