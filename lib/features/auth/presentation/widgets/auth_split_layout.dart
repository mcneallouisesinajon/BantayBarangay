import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Magazine-style auth layout: editorial masthead on one side, form on the
/// other. Light, sharp, flat — same vocabulary as the rest of the app.
class AuthSplitLayout extends StatelessWidget {
  const AuthSplitLayout({
    super.key,
    required this.child,
    this.dek,
  });

  final Widget child;

  /// Description shown under the BANTAY BARANGAY title on the masthead.
  final String? dek;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TereTheme.paper,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 900;
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: _MastheadPanel(
                    dek: dek ??
                        'Report incidents, follow alerts, and read the bulletin from one bold front page.',
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Container(
                    color: TereTheme.paper,
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 56, vertical: 56),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // Mobile: condensed masthead band on top, form below.
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MastheadBand(
                  dek: dek ??
                      'Report incidents, follow alerts, and read the bulletin from one bold front page.',
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
                  child: child,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MastheadPanel extends StatelessWidget {
  const _MastheadPanel({required this.dek});

  final String dek;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TereTheme.ink,
        border: Border(
          right: BorderSide(color: TereTheme.ink, width: 2),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(56, 48, 56, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text('BANTAY\nBARANGAY',
                      style: TereTheme.display(size: 56, color: TereTheme.paper)
                          .copyWith(height: 0.95)),
                  const SizedBox(width: 16),
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    width: 6,
                    height: 56,
                    color: TereTheme.accent,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Container(height: 4, width: 96, color: TereTheme.accent),
              const SizedBox(height: 24),
              Text(dek,
                  style: TereTheme.body(
                          size: 16,
                          color: TereTheme.paper.withValues(alpha: 0.78))
                      .copyWith(height: 1.6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MastheadBand extends StatelessWidget {
  const _MastheadBand({required this.dek});

  final String dek;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: TereTheme.ink,
        border: Border(
          bottom: BorderSide(color: TereTheme.accent, width: 4),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('BANTAY\nBARANGAY',
                      style: TereTheme.display(size: 30, color: TereTheme.paper)
                          .copyWith(height: 0.95)),
                  const SizedBox(width: 10),
                  Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 4,
                      height: 32,
                      color: TereTheme.accent),
                ],
              ),
              const SizedBox(height: 14),
              Text(dek,
                  style: TereTheme.body(
                          size: 14,
                          color: TereTheme.paper.withValues(alpha: 0.78))
                      .copyWith(height: 1.45)),
            ],
          ),
        ),
      ),
    );
  }
}
