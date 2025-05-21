part of 'connectivity_bloc.dart';

enum AppConnectionStatus { initial, loading, connected, disconnected }

class ConnectivityState extends Equatable {
  final AppConnectionStatus status;

  const ConnectivityState({this.status = AppConnectionStatus.initial});

  ConnectivityState copyWith({AppConnectionStatus? status}) {
    return ConnectivityState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [status];
}
