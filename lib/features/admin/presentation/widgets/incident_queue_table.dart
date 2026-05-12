import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../incidents/domain/incident.dart';
import '../../../incidents/presentation/widgets/category_chip.dart';
import '../../../incidents/presentation/widgets/severity_badge.dart';
import '../../../incidents/presentation/widgets/status_pill.dart';

class IncidentQueueTable extends StatelessWidget {
  const IncidentQueueTable({super.key, required this.incidents});
  final List<Incident> incidents;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TereTheme.paper,
        border: Border.all(color: TereTheme.ink, width: 2),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          horizontalMargin: 20,
          columnSpacing: 28,
          dividerThickness: 1,
          headingRowHeight: 44,
          dataRowMinHeight: 56,
          dataRowMaxHeight: 64,
          columns: [
            DataColumn(label: Text('TITLE', style: TereTheme.overline(size: 11))),
            DataColumn(label: Text('CATEGORY', style: TereTheme.overline(size: 11))),
            DataColumn(label: Text('SEVERITY', style: TereTheme.overline(size: 11))),
            DataColumn(label: Text('STATUS', style: TereTheme.overline(size: 11))),
            DataColumn(label: Text('REPORTER', style: TereTheme.overline(size: 11))),
            DataColumn(label: Text('REPORTED', style: TereTheme.overline(size: 11))),
          ],
          rows: [
            for (final i in incidents)
              DataRow(
                onSelectChanged: (_) => context.go('/incident/${i.id}'),
                cells: [
                  DataCell(SizedBox(
                    width: 240,
                    child: Text(
                      i.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TereTheme.body(
                          size: 14, weight: FontWeight.w700),
                    ),
                  )),
                  DataCell(CategoryChip(category: i.category)),
                  DataCell(SeverityBadge(severity: i.severity)),
                  DataCell(StatusPill(status: i.status)),
                  DataCell(Text(i.reporterName,
                      style: TereTheme.body(size: 13))),
                  DataCell(Text(
                      DateFormat.MMMd().add_jm().format(i.createdAt).toUpperCase(),
                      style: TereTheme.overline(
                          size: 10, color: TereTheme.textSecondary))),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
