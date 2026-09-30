import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/conversion_result.dart';
import '../services/floor_plan_converter.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _converter = FloorPlanConverter();
  SelectedFloorPlan? _source;
  ConversionResult? _result;
  int _page = 1;
  bool _busy = false;

  Future<void> _chooseFile() async {
    try {
      final source = await _converter.selectFile();
      if (source == null || !mounted) return;
      setState(() {
        _source = source;
        _result = null;
        _page = 1;
      });
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _generate() async {
    final source = _source;
    if (source == null) return;
    setState(() => _busy = true);
    try {
      final result = await _converter.generate(source, pdfPage: _page);
      if (!mounted) return;
      setState(() => _result = result);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not process file: $error')),
    );
  }

  Future<void> _share() async {
    final result = _result;
    if (result == null) return;
    await Share.shareXFiles(
      [XFile(result.outputPath, mimeType: 'image/png')],
      subject: result.fileName,
      text: 'Original floor plan exported as PNG for Home Assistant.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final source = _source;
    final result = _result;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Floor Plan'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Icon(Icons.home_work_outlined, size: 64),
                const SizedBox(height: 12),
                Text(
                  'Floor Plan Image Generator',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your PDF, JPG or PNG. The app creates a clean PNG without changing the drawing.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                _StepCard(
                  number: '1',
                  title: 'Select floor-plan file',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _chooseFile,
                        icon: const Icon(Icons.upload_file),
                        label: Text(source == null ? 'Choose File' : 'Change File'),
                      ),
                      if (source != null) ...[
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            source.isPdf ? Icons.picture_as_pdf : Icons.image,
                          ),
                          title: Text(source.name),
                          subtitle: Text(
                            source.isPdf
                                ? '${source.pdfPages} PDF page${source.pdfPages == 1 ? '' : 's'}'
                                : source.extension.toUpperCase(),
                          ),
                        ),
                        if (source.isPdf && source.pdfPages > 1)
                          DropdownButtonFormField<int>(
                            value: _page,
                            decoration: const InputDecoration(
                              labelText: 'PDF page to generate',
                            ),
                            items: [
                              for (var page = 1; page <= source.pdfPages; page++)
                                DropdownMenuItem(
                                  value: page,
                                  child: Text('Page $page'),
                                ),
                            ],
                            onChanged: _busy
                                ? null
                                : (value) => setState(() => _page = value ?? 1),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _StepCard(
                  number: '2',
                  title: 'Generate image',
                  child: FilledButton.icon(
                    onPressed: source == null || _busy ? null : _generate,
                    icon: _busy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(_busy ? 'Generating…' : 'Generate PNG'),
                  ),
                ),
                if (result != null) ...[
                  const SizedBox(height: 16),
                  _StepCard(
                    number: '✓',
                    title: 'Image ready',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 320,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 8,
                            child: Image.file(
                              File(result.outputPath),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${result.fileName}\n${result.width} × ${result.height} px',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _share,
                          icon: const Icon(Icons.ios_share),
                          label: const Text('Save or Share PNG'),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.verified_user_outlined),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Architecture guarantee: walls, doors, windows, rooms and dimensions are never redrawn or moved.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.title,
    required this.child,
  });

  final String number;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 16, child: Text(number)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
