import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mob_lab_manger/core/network/network_info.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final NetworkInfo _networkInfo;
  StreamSubscription<InternetConnectionStatus>? _internetStatusSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivityTypeSubscription;

  ConnectivityBloc({required NetworkInfo networkInfo})
      : _networkInfo = networkInfo,
        super(const ConnectivityState(status: AppConnectionStatus.initial)) {
    on<ConnectivitySubscriptionRequested>(_onSubscriptionRequested);
    on<_NetworkInterfaceChanged>(_onNetworkInterfaceChanged);
    on<ConnectivityManuallyChecked>(_onConnectivityManuallyChecked);
    on<_ConnectivityStatusUpdated>(_onConnectivityStatusUpdated);

    add(ConnectivitySubscriptionRequested());
    debugPrint(
        '[ConnectivityBloc] CONSTRUCTOR: Initialized and SubscriptionRequested event added.');
  }

  Future<void> _onSubscriptionRequested(
    ConnectivitySubscriptionRequested event,
    Emitter<ConnectivityState> emit,
  ) async {
    debugPrint('[ConnectivityBloc] EVENT: _onSubscriptionRequested');
    if (state.status == AppConnectionStatus.loading && !emit.isDone) {
    } else if (!emit.isDone) {
      emit(state.copyWith(status: AppConnectionStatus.loading));
      debugPrint(
          '[ConnectivityBloc] EMIT from _onSubscriptionRequested: AppConnectionStatus.loading');
    }

    debugPrint(
        '[ConnectivityBloc] _onSubscriptionRequested: Getting initial connectivity types...');
    final initialConnectivityTypes =
        await _networkInfo.currentConnectivityTypes;
    debugPrint(
        '[ConnectivityBloc] _onSubscriptionRequested: Initial Connectivity Types: $initialConnectivityTypes. Adding _NetworkInterfaceChanged.');
    if (!isClosed) add(_NetworkInterfaceChanged(initialConnectivityTypes));

    debugPrint(
        '[ConnectivityBloc] _onSubscriptionRequested: Getting initial internet status...');
    final initialInternetStatus = await _networkInfo.currentInternetStatus;
    debugPrint(
        '[ConnectivityBloc] _onSubscriptionRequested: Initial Internet Status: $initialInternetStatus. Adding _ConnectivityStatusUpdated.');
    if (!isClosed) {
      if (initialInternetStatus == InternetConnectionStatus.connected) {
        add(const _ConnectivityStatusUpdated(AppConnectionStatus.connected));
      } else {
        add(const _ConnectivityStatusUpdated(AppConnectionStatus.disconnected));
      }
    }

    await _connectivityTypeSubscription?.cancel();
    _connectivityTypeSubscription =
        _networkInfo.onConnectivityTypeChange.listen(
      (connectivityResults) {
        debugPrint(
            '[ConnectivityBloc] STREAM NetworkInterfaceChanged: $connectivityResults. Adding _NetworkInterfaceChanged.');
        if (!isClosed) add(_NetworkInterfaceChanged(connectivityResults));
      },
    );

    await _internetStatusSubscription?.cancel();
    _internetStatusSubscription = _networkInfo.onInternetStatusChange.listen(
      (status) {
        debugPrint(
            '[ConnectivityBloc] STREAM InternetStatusChanged: $status. Adding _ConnectivityStatusUpdated.');
        if (!isClosed) {
          if (status == InternetConnectionStatus.connected) {
            add(const _ConnectivityStatusUpdated(
                AppConnectionStatus.connected));
          } else {
            add(const _ConnectivityStatusUpdated(
                AppConnectionStatus.disconnected));
          }
        }
      },
    );
    debugPrint(
        '[ConnectivityBloc] _onSubscriptionRequested: Stream listeners set up.');
  }

  Future<void> _onNetworkInterfaceChanged(
    _NetworkInterfaceChanged event,
    Emitter<ConnectivityState> emit,
  ) async {
    debugPrint(
        '[ConnectivityBloc] EVENT: _onNetworkInterfaceChanged with results: ${event.connectivityResults}');
    if (event.connectivityResults.contains(ConnectivityResult.none)) {
      debugPrint(
          '[ConnectivityBloc] _onNetworkInterfaceChanged: No network interface. Adding _ConnectivityStatusUpdated(disconnected).');
      if (!isClosed)
        add(const _ConnectivityStatusUpdated(AppConnectionStatus.disconnected));
    } else {
      debugPrint(
          '[ConnectivityBloc] _onNetworkInterfaceChanged: Network interface detected. Checking actual internet...');
      final hasInternet = await _networkInfo.isConnected;
      debugPrint(
          '[ConnectivityBloc] _onNetworkInterfaceChanged: Actual internet: $hasInternet. Adding _ConnectivityStatusUpdated.');
      if (!isClosed) {
        add(_ConnectivityStatusUpdated(hasInternet
            ? AppConnectionStatus.connected
            : AppConnectionStatus.disconnected));
      }
    }
  }

  Future<void> _onConnectivityManuallyChecked(
    ConnectivityManuallyChecked event,
    Emitter<ConnectivityState> emit,
  ) async {
    debugPrint('[ConnectivityBloc] EVENT: _onConnectivityManuallyChecked');
    if (!emit.isDone) {
      emit(state.copyWith(status: AppConnectionStatus.loading));
      debugPrint(
          '[ConnectivityBloc] EMIT from _onConnectivityManuallyChecked: AppConnectionStatus.loading');
    }

    final hasInternet = await _networkInfo.isConnected;
    debugPrint(
        '[ConnectivityBloc] _onConnectivityManuallyChecked: Manual check result - Has internet: $hasInternet. Adding _ConnectivityStatusUpdated.');
    if (!isClosed) {
      add(_ConnectivityStatusUpdated(hasInternet
          ? AppConnectionStatus.connected
          : AppConnectionStatus.disconnected));
    }
  }

  void _onConnectivityStatusUpdated(
    _ConnectivityStatusUpdated event,
    Emitter<ConnectivityState> emit,
  ) {
    debugPrint(
        '[ConnectivityBloc] EVENT: _onConnectivityStatusUpdated with new status: ${event.newStatus}. Current state: ${state.status}');
    if (state.status == event.newStatus &&
        event.newStatus != AppConnectionStatus.disconnected) {
      debugPrint(
          '[ConnectivityBloc] _onConnectivityStatusUpdated: New status is same as current and not disconnected. No emit.');
      return;
    }

    if (!emit.isDone) {
      emit(state.copyWith(status: event.newStatus));
      debugPrint(
          '[ConnectivityBloc] EMIT from _onConnectivityStatusUpdated: ${event.newStatus}');
    } else {
      debugPrint(
          '[ConnectivityBloc] _onConnectivityStatusUpdated: Emit was done, cannot emit ${event.newStatus}.');
    }
  }

  @override
  Future<void> close() {
    debugPrint('[ConnectivityBloc] Closing BLoC and cancelling subscriptions.');
    _connectivityTypeSubscription?.cancel();
    _internetStatusSubscription?.cancel();
    return super.close();
  }
}
