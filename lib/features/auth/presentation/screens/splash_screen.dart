import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Editorial splash — TERE masthead with a single red rule and a
/// thin progress band. Shown only briefly while auth state hydrates.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TereTheme.paper,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('VOLUME I · ${DateTime.now().year}',
                  style: TereTheme.overline(
                      size: 11, color: TereTheme.textSecondary)),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BANTAY\nBARANGAY',
                      style: TereTheme.display(size: 64).copyWith(height: 0.9)),
                  const SizedBox(width: 16),
                  Container(
                    margin: const EdgeInsets.only(top: 28),
                    width: 8,
                    height: 80,
                    color: TereTheme.accent,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 4, width: 96, color: TereTheme.ink),
              const SizedBox(height: 16),
              Text('The barangay bulletin.',
                  style: TereTheme.body(
                      size: 16, color: TereTheme.textSecondary)),
              const SizedBox(height: 32),
              const SizedBox(
                width: 220,
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: TereTheme.accent,
                  backgroundColor: TereTheme.borderSubtle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
