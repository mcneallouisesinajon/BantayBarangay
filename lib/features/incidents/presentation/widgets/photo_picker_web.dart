import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPickerWeb extends StatefulWidget {
  const PhotoPickerWeb({super.key, required this.onChanged, this.maxImages = 3});
  final ValueChanged<List<XFile>> onChanged;
  final int maxImages;

  @override
  State<PhotoPickerWeb> createState() => _PhotoPickerWebState();
}

class _PhotoPickerWebState extends State<PhotoPickerWeb> {
  final _picker = ImagePicker();
  final List<XFile> _files = [];

  Future<void> _pick() async {
    if (_files.length >= widget.maxImages) return;
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _files.add(picked));
    widget.onChanged(List.unmodifiable(_files));
  }

  void _remove(int index) {
    setState(() => _files.removeAt(index));
    widget.onChanged(List.unmodifiable(_files));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _files.length; i++)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: FutureBuilder(
                        future: _files[i].readAsBytes(),
                        builder: (context, snap) {
                          if (snap.connectionState != ConnectionState.done ||
                              snap.data == null) {
                            return Container(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: const Center(
                                  child: SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2))),
                            );
                          }
                          return Image.memory(snap.data!, fit: BoxFit.cover);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      iconSize: 18,
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                      ),
                      icon: const Icon(Icons.close),
                      onPressed: () => _remove(i),
                    ),
                  ),
                ],
              ),
            if (_files.length < widget.maxImages)
              SizedBox(
                width: 96,
                height: 96,
                child: OutlinedButton(
                  onPressed: _pick,
                  child: const Icon(Icons.add_a_photo_outlined),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text('Up to ${widget.maxImages} photos. JPEG/PNG, max 8MB each.',
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
