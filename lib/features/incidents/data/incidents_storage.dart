import 'package:cross_file/cross_file.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase_bootstrap.dart';

class IncidentsStorage {
  IncidentsStorage(this._storage);
  final FirebaseStorage _storage;

  Future<List<String>> uploadPhotos({
    required String uid,
    required String incidentId,
    required List<XFile> files,
  }) async {
    final urls = <String>[];
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final bytes = await file.readAsBytes();
      final contentType = file.mimeType ?? 'image/jpeg';
      final ref = _storage.ref('incidents/$uid/$incidentId/$i.jpg');
      final snap = await ref.putData(bytes, SettableMetadata(contentType: contentType));
      urls.add(await snap.ref.getDownloadURL());
    }
    return urls;
  }
}

final incidentsStorageProvider = Provider<IncidentsStorage>((ref) {
  return IncidentsStorage(ref.watch(firebaseStorageProvider));
});
