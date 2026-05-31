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
    return Expanded(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              'زمان تخمینی سفر: ${route.estimatedTimeMinutes} دقیقه',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ...route.legs.map((leg) {
            final directionStation = leg.stationsFa.last;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
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
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            'خط ${leg.line}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'به سمت $directionStation',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, thickness: 1),
                    ),
                    Text(
                      'طی کردن ${leg.stationsFa.length - 1} ایستگاه:',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      leg.stationsFa.join('  ←  '),
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.8,
                        color: Color(0xFF4A5568),
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
