import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/services/geolocation_service.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../domain/alert.dart';

/// Editorial alert banner — left red rule, severity rubric, dek paragraph.
/// Used in feeds and on the home page.
class AlertBanner extends ConsumerWidget {
  const AlertBanner({super.key, required this.alert});
  final Alert alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(currentPositionProvider).valueOrNull;
    String? distance;
    if (position != null && alert.location != null) {
      final d = haversineMeters(
        GeoPoint(position.latitude, position.longitude),
        alert.location!,
      );
      distance = formatDistance(d);
    }

    final severityColor = alert.severity.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: TereTheme.paper,
          border: Border(
            top: const BorderSide(color: TereTheme.borderMedium, width: 2),
            right: const BorderSide(color: TereTheme.borderMedium, width: 2),
            bottom: const BorderSide(color: TereTheme.borderMedium, width: 2),
            left: BorderSide(color: severityColor, width: 6),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: severityColor, size: 18),
                const SizedBox(width: 8),
                Text('BULLETIN · ${alert.severity.label.toUpperCase()}',
                    style:
                        TereTheme.overline(size: 11, color: severityColor)),
                const Spacer(),
                Text(
                  DateFormat.yMMMd().add_jm().format(alert.issuedAt).toUpperCase(),
                  style: TereTheme.overline(
                      size: 10, color: TereTheme.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(alert.title, style: TereTheme.subhead(size: 22)),
            const SizedBox(height: 6),
            Container(width: 48, height: 2, color: TereTheme.ink),
            const SizedBox(height: 10),
            Text(
              alert.body,
              style: TereTheme.body(size: 15, color: TereTheme.textPrimary),
            ),
            if (distance != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.place_outlined,
                      size: 14, color: TereTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(distance.toUpperCase(),
                      style: TereTheme.overline(
                          size: 10, color: TereTheme.textSecondary)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
