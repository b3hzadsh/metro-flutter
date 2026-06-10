// مسیر: lib/features/metro_routing/presentation/pages/metro_routing_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metro/core/theme/presentation/bloc/theme_cubit.dart';
import 'package:metro/features/metro_routing/presentation/pages/route_result_widget.dart';

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
      child: Builder(
        builder: (context) {
          return Scaffold(
            drawer: _MetroDrawer(
              onUpdateMap: () => context.read<MetroRoutingBloc>().add(UpdateGraphRequested()),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: const _MetroRoutingForm(),
              ),
            ),
          );
        }
      ),
    );
  }
}

class _MetroDrawer extends StatelessWidget {
  final VoidCallback onUpdateMap;
  
  const _MetroDrawer({required this.onUpdateMap});

  Color _getLineColor(int line) {
    switch (line) {
      case 1: return const Color(0xFFE0001F);
      case 2: return const Color(0xFF003882);
      case 3: return const Color(0xFF00B2E2);
      case 4: return const Color(0xFFFDC70F);
      case 5: return const Color(0xFF009C4A);
      case 6: return const Color(0xFFEF5F8A);
      case 7: return const Color(0xFF862688);
      default: return Colors.grey;
    }
  }

  String _getLineName(int line) {
    switch (line) {
      case 1: return 'تجریش - کهریزک';
      case 2: return 'صادقیه - فرهنگسرا';
      case 3: return 'قائم - آزادگان';
      case 4: return 'کلاهدوز - ارم سبز';
      case 5: return 'صادقیه - گلشهر';
      case 6: return 'دولت‌آباد - کوهسار';
      case 7: return 'بسیج - میدان کتاب';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.subway_rounded,
                    size: 48,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'متروی تهران',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: theme.colorScheme.primary,
            ),
            title: const Text('حالت شب'),
            trailing: Switch(
              value: isDark,
              onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'اطلاعات خطوط',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: 7,
              itemBuilder: (context, index) {
                final line = index + 1;
                return ListTile(
                  dense: true,
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getLineColor(line),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$line',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text('خط $line'),
                  subtitle: Text(_getLineName(line)),
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.refresh_rounded),
            title: const Text('بروزرسانی نقشه'),
            onTap: () {
              Navigator.pop(context);
              onUpdateMap();
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'نسخه ۱.۰.۰',
              style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
            ),
          ),
        ],
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
  TextEditingController? _startController;
  TextEditingController? _endController;

  @override
  void initState() {
    super.initState();
    context.read<MetroRoutingBloc>().add(LoadStationsListRequested());
  }

  void _submitRouting() {
    FocusScope.of(context).unfocus(); // بستن کیبورد

    final start = _startController?.text.trim() ?? '';
    final end = _endController?.text.trim() ?? '';
    final bloc = context.read<MetroRoutingBloc>();

    if (start.isEmpty || end.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً مبدا و مقصد را وارد کنید.')),
      );
      return;
    }

    if (!bloc.availableStations.contains(start) ||
        !bloc.availableStations.contains(end)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً ایستگاه را از لیست پیشنهادی انتخاب کنید.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    bloc.add(GetOfflineRouteRequested(startStation: start, endStation: end));
  }

  Widget _buildAutocompleteField({
    required String label,
    required IconData icon,
    required Color iconColor,
    required List<String> options,
    required Function(TextEditingController) onControllerReady,
  }) {
    final theme = Theme.of(context);

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return options.where((String option) {
          return option.contains(textEditingValue.text.trim());
        });
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            onControllerReady(textEditingController);

            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: label,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(icon, color: iconColor),
              ),
            );
          },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topRight,
          child: Material(
            elevation: 8.0,
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250, maxWidth: 350),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1, 
                  color: theme.colorScheme.outlineVariant
                ),
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return ListTile(
                    title: Text(
                      option,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stationsList = context.watch<MetroRoutingBloc>().availableStations;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'مسیریاب آفلاین مترو',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu_rounded),
              tooltip: 'منو',
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildAutocompleteField(
          label: 'ایستگاه مبدا',
          icon: Icons.trip_origin_rounded,
          iconColor: theme.colorScheme.primary,
          options: stationsList,
          onControllerReady: (controller) => _startController = controller,
        ),
        const SizedBox(height: 16),
        _buildAutocompleteField(
          label: 'ایستگاه مقصد',
          icon: Icons.location_on_rounded,
          iconColor: theme.colorScheme.error,
          options: stationsList,
          onControllerReady: (controller) => _endController = controller,
        ),
        const SizedBox(height: 24),
        FilledButton.tonal(
          onPressed: _submitRouting,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'محاسبه مسیر',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: BlocConsumer<MetroRoutingBloc, MetroRoutingState>(
            listener: (context, state) {
              if (state is GraphUpdateSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: theme.colorScheme.secondary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is GraphUpdating) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: theme.colorScheme.primary),
                      const SizedBox(height: 16),
                      const Text('در حال دریافت اطلاعات...'),
                    ],
                  ),
                );
              } else if (state is RouteLoading) {
                return Center(
                  child: CircularProgressIndicator(color: theme.colorScheme.primary),
                );
              } else if (state is RouteLoaded) {
                return RouteResultWidget(route: state.route);
              } else if (state is MetroRoutingError) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      state.message,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return Center(
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    'مبدا و مقصد را برای مسیریابی انتخاب کنید.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
