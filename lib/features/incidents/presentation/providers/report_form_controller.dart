import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/geolocation_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/incidents_repository.dart';
import '../../domain/incident.dart';
import '../../domain/incident_category.dart';

class ReportFormController extends AsyncNotifier<Incident?> {
  @override
  Future<Incident?> build() async => null;

  Future<Incident> submit({
    required String title,
    required String description,
    required IncidentCategory category,
    required List<XFile> photos,
    String? address,
  }) async {
    state = const AsyncLoading();
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) {
        throw StateError('You must be signed in to submit a report.');
      }

      final position = await ref.read(geolocationServiceProvider).getCurrentPosition();
      final geoPoint = ref.read(geolocationServiceProvider).toGeoPoint(position);

      final incident = await ref.read(incidentsRepositoryProvider).create(
            reporterId: user.uid,
            reporterName: user.displayName,
            title: title,
            description: description,
            category: category,
            barangayId: user.barangayId,
            location: geoPoint,
            address: address,
            photos: photos,
          );

      state = AsyncData(incident);
      return incident;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final reportFormControllerProvider =
    AsyncNotifierProvider<ReportFormController, Incident?>(ReportFormController.new);
