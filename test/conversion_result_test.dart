import 'package:flutter_test/flutter_test.dart';
import 'package:smart_floor_plan/models/conversion_result.dart';

void main() {
  test('recognizes a PDF selection', () {
    const selection = SelectedFloorPlan(
      path: '/floor.pdf',
      name: 'floor.pdf',
      extension: 'pdf',
      pdfPages: 3,
    );

    expect(selection.isPdf, isTrue);
    expect(selection.pdfPages, 3);
  });
}
