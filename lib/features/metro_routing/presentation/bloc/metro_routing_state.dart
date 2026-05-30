// مسیر: lib/features/metro_routing/presentation/bloc/metro_routing_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/metro_route.dart';

abstract class MetroRoutingState extends Equatable {
  const MetroRoutingState();

  @override
  List<Object?> get props => [];
}

class MetroRoutingInitial extends MetroRoutingState {}

// --- وضعیت‌های مربوط به آپدیت نقشه ---

class GraphUpdating extends MetroRoutingState {} // در حال دانلود

class GraphUpdateSuccess extends MetroRoutingState {
  final String message;
  const GraphUpdateSuccess({this.message = 'نقشه با موفقیت به‌روزرسانی شد.'});

  @override
  List<Object?> get props => [message];
}

// --- وضعیت‌های مربوط به مسیریابی ---

class RouteLoading
    extends MetroRoutingState {} // در حال اجرای دایجسترا (هرچند خیلی سریع است)

class RouteLoaded extends MetroRoutingState {
  final MetroRoute route;
  const RouteLoaded({required this.route});

  @override
  List<Object?> get props => [route];
}

// --- وضعیت خطای عمومی ---

class MetroRoutingError extends MetroRoutingState {
  final String message;
  const MetroRoutingError({required this.message});

  @override
  List<Object?> get props => [message];
}
