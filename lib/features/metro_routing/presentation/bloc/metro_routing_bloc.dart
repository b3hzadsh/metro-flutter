// مسیر: lib/features/metro_routing/presentation/bloc/metro_routing_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_metro_route.dart'; // نام کلاس را در پیام‌های قبل تغییر ندادیم تا سازگاری حفظ شود
import '../../domain/usecases/update_metro_graph.dart';
import 'metro_routing_event.dart';
import 'metro_routing_state.dart';

class MetroRoutingBloc extends Bloc<MetroRoutingEvent, MetroRoutingState> {
  // تزریق هر دو UseCase
  final GetMetroRoute getOfflineMetroRoute;
  final UpdateMetroGraph updateMetroGraph;

  MetroRoutingBloc({
    required this.getOfflineMetroRoute,
    required this.updateMetroGraph,
  }) : super(MetroRoutingInitial()) {
    // ثبت مدیریت‌کننده‌ها برای هر رویداد
    on<UpdateGraphRequested>(_onUpdateGraphRequested);
    on<GetOfflineRouteRequested>(_onGetOfflineRouteRequested);
  }

  // مدیریت‌کننده دکمه آپدیت نقشه
  Future<void> _onUpdateGraphRequested(
    UpdateGraphRequested event,
    Emitter<MetroRoutingState> emit,
  ) async {
    emit(GraphUpdating()); // نمایش لودینگ مخصوص دانلود

    final failureOrSuccess = await updateMetroGraph();

    failureOrSuccess.fold(
      (failure) => emit(MetroRoutingError(message: failure.message)),
      (_) => emit(const GraphUpdateSuccess()),
    );
  }

  // مدیریت‌کننده دکمه مسیریابی آفلاین
  Future<void> _onGetOfflineRouteRequested(
    GetOfflineRouteRequested event,
    Emitter<MetroRoutingState> emit,
  ) async {
    emit(RouteLoading()); // نمایش لودینگ مسیریابی

    final failureOrRoute = await getOfflineMetroRoute(
      startStation: event.startStation,
      endStation: event.endStation,
    );

    failureOrRoute.fold(
      (failure) => emit(MetroRoutingError(message: failure.message)),
      (route) => emit(RouteLoaded(route: route)),
    );
  }
}
