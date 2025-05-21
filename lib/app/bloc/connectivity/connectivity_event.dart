part of 'connectivity_bloc.dart';

abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object> get props => [];
}

// --- Public Events ---
class ConnectivityManuallyChecked extends ConnectivityEvent {}

class ConnectivitySubscriptionRequested
    extends ConnectivityEvent {} // To start listening

// --- Internal Events ---
class _ConnectivityStatusUpdated extends ConnectivityEvent {
  final AppConnectionStatus newStatus;
  const _ConnectivityStatusUpdated(this.newStatus);
  @override
  List<Object> get props => [newStatus];
}

class _NetworkInterfaceChanged extends ConnectivityEvent {
  final List<ConnectivityResult> connectivityResults;
  const _NetworkInterfaceChanged(this.connectivityResults);
  @override
  List<Object> get props => [connectivityResults];
}
