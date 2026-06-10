// مسیر: lib/features/metro_routing/presentation/widgets/route_result_widget.dart

import 'package:flutter/material.dart';
import '../../domain/entities/metro_route.dart';

class RouteResultWidget extends StatelessWidget {
  final MetroRoute route;

  const RouteResultWidget({super.key, required this.route});

  // رنگ‌بندی استاندارد خطوط متروی تهران
  Color _getLineColor(int line) {
    switch (line) {
      case 1:
        return const Color(0xFFE0001F); // قرمز
      case 2:
        return const Color(0xFF003882); // سرمه‌ای
      case 3:
        return const Color(0xFF00B2E2); // آبی روشن
      case 4:
        return const Color(0xFFFDC70F); // زرد
      case 5:
        return const Color(0xFF009C4A); // سبز
      case 6:
        return const Color(0xFFEF5F8A); // صورتی
      case 7:
        return const Color(0xFF862688); // بنفش
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer_outlined, 
                  color: theme.colorScheme.onSecondaryContainer
                ),
                const SizedBox(width: 12),
                Text(
                  'زمان تخمینی سفر: ${route.estimatedTimeMinutes} دقیقه',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...route.legs.map((leg) {
            final directionStation = leg.stationsFa.last;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getLineColor(leg.line),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'خط ${leg.line}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'به سمت $directionStation',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(
                        height: 1, 
                        thickness: 1,
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.stairs_outlined, 
                          size: 16, 
                          color: theme.colorScheme.primary
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'طی کردن ${leg.stationsFa.length - 1} ایستگاه:',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      leg.stationsFa.join('  ←  '),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.8,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
