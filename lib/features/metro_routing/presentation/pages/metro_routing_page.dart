// مسیر: lib/features/metro_routing/presentation/pages/metro_routing_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../bloc/metro_routing_bloc.dart';
import '../bloc/metro_routing_event.dart';
import '../bloc/metro_routing_state.dart';

class MetroRoutingPage extends StatelessWidget {
  const MetroRoutingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MetroRoutingBloc>(),
      child: const Scaffold(
        // طراحی مینیمال: استفاده از رنگ پس‌زمینه خنثی
        backgroundColor: Color(0xFFF8F9FA),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: _MetroRoutingForm(),
          ),
        ),
      ),
    );
  }
}

class _MetroRoutingForm extends StatefulWidget {
  const _MetroRoutingForm();

  @override
  State<_MetroRoutingForm> createState() => _MetroRoutingFormState();
}

class _MetroRoutingFormState extends State<_MetroRoutingForm> {
  final startStationController = TextEditingController();
  final endStationController = TextEditingController();

  @override
  void dispose() {
    startStationController.dispose();
    endStationController.dispose();
    super.dispose();
  }

  void _submitRouting() {
    FocusScope.of(context).unfocus(); // بستن کیبورد
    final start = startStationController.text.trim();
    final end = endStationController.text.trim();

    if (start.isEmpty || end.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً مبدا و مقصد را وارد کنید.')),
      );
      return;
    }

    context.read<MetroRoutingBloc>().add(
      GetOfflineRouteRequested(startStation: start, endStation: end),
    );
  }

  void _updateGraph() {
    context.read<MetroRoutingBloc>().add(UpdateGraphRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // هدر صفحه و دکمه آپدیت
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'مسیریاب آفلاین مترو',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: Color(0xFF2D3748),
              ),
            ),
            IconButton(
              onPressed: _updateGraph,
              icon: const Icon(Icons.cloud_download_outlined),
              tooltip: 'دانلود آخرین نقشه',
              color: const Color(0xFF4A5568),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // فیلدهای ورودی با طراحی فلت و مهندسی
        TextField(
          controller: startStationController,
          decoration: InputDecoration(
            labelText: 'ایستگاه مبدا (مثال: تجریش)',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.trip_origin, color: Colors.blueGrey),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: endStationController,
          decoration: InputDecoration(
            labelText: 'ایستگاه مقصد (مثال: دروازه دولت)',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.location_on, color: Colors.redAccent),
          ),
        ),
        const SizedBox(height: 24),

        // دکمه اصلی مسیریابی
        ElevatedButton(
          onPressed: _submitRouting,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: const Color(0xFF2D3748),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'محاسبه مسیر',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 32),

        // BlocConsumer برای گوش دادن به رویدادها و ساخت UI
        Expanded(
          child: BlocConsumer<MetroRoutingBloc, MetroRoutingState>(
            listener: (context, state) {
              // نمایش اسنک‌بار فقط در زمان آپدیت موفق
              if (state is GraphUpdateSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is GraphUpdating) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF2D3748)),
                      SizedBox(height: 16),
                      Text('در حال دریافت اطلاعات از سرور...'),
                    ],
                  ),
                );
              } else if (state is RouteLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2D3748)),
                );
              } else if (state is RouteLoaded) {
                final route = state.route;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'زمان تخمینی: ${route.estimatedTimeMinutes} دقیقه',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Expanded(
                        child: ListView.builder(
                          itemCount: route.path.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    index == 0 || index == route.path.length - 1
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    size: 16,
                                    color: const Color(0xFF4A5568),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    route.path[index],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is MetroRoutingError) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      state.message,
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              // حالت Initial یا Success (که نیازی به تغییر فرم پایین صفحه ندارد)
              return const Center(
                child: Text(
                  'برای شروع، روی آیکون دانلود (بالا چپ) کلیک کنید تا نقشه بارگیری شود.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
