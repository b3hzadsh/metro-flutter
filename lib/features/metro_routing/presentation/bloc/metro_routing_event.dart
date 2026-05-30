// مسیر: lib/features/metro_routing/presentation/bloc/metro_routing_event.dart

import 'package:equatable/equatable.dart';

abstract class MetroRoutingEvent extends Equatable {
  const MetroRoutingEvent();

  @override
  List<Object?> get props => [];
}

/// رویداد درخواست دانلود/به‌روزرسانی نقشه از سرور
class UpdateGraphRequested extends MetroRoutingEvent {}

/// رویداد درخواست مسیریابی آفلاین بین دو ایستگاه
class GetOfflineRouteRequested extends MetroRoutingEvent {
  final String startStation;
  final String endStation;

  const GetOfflineRouteRequested({
    required this.startStation,
    required this.endStation,
  });

  @override
  List<Object?> get props => [startStation, endStation];
}
