import 'package:flutter/material.dart';
import 'package:planted/extensions/time_stamp_extensions.dart';
import 'package:planted/models/report.dart';
import 'package:planted/styles/box_decoration_styles.dart';
import 'package:planted/styles/text_styles.dart';

enum ReportRowArrangement { horizontal, vertical }

class ReportItemListTile extends StatelessWidget {
  const ReportItemListTile({
    super.key,
    required this.report,
  });

  final Report report;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: backgroundBoxDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Zgłoszenie',
              style: textStyle15BoldSepia,
            ),
            _ReportRow(
              title: 'ID Zgłoszenia:',
              value: report.reportID,
              arrangement: ReportRowArrangement.horizontal,
            ),
            _ReportRow(
              title: 'Data głoszenia:',
              value: report.reportingDate.toFormattedDateString(),
              arrangement: ReportRowArrangement.horizontal,
            ),
            _ReportRow(
              title: 'Dotyczy użytkownika:',
              value: report.reportedPersonDisplayName,
              arrangement: ReportRowArrangement.horizontal,
            ),
            _ReportRow(
              title: 'Powód zgłoszenia:',
              value: report.reasonForReporting,
              arrangement: ReportRowArrangement.horizontal,
            ),
            if (report.additionalInformation.isNotEmpty)
              _ReportRow(
                title: 'Dodatkowe Informacje:',
                value: report.additionalInformation,
                arrangement: ReportRowArrangement.vertical,
              ),
            _ReportRow(
              title: 'Status zgłoszenia',
              value: report.statusDescription,
              arrangement: ReportRowArrangement.horizontal,
            ),
            if (report.status != 0)
              _ReportRow(
                title: 'Decyzja',
                value: report.decision,
                arrangement: ReportRowArrangement.horizontal,
              ),
            if (report.adminResponse.isNotEmpty)
              _ReportRow(
                title: 'Uzasadnienie:',
                value: report.adminResponse,
                arrangement: ReportRowArrangement.vertical,
              ),
          ],
        ),
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.title,
    required this.value,
    required this.arrangement,
  });
  final String title;
  final String value;
  final ReportRowArrangement arrangement;

  @override
  Widget build(BuildContext context) {
    if (arrangement == ReportRowArrangement.horizontal) {
      return Column(
        children: [
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: textStyle10Sepia,
              ),
              Text(
                value,
                style: textStyle10BoldSepia,
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Text(
            title,
            style: textStyle10Sepia,
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: textStyle10BoldSepia,
          ),
        ],
      );
    }
  }
}
