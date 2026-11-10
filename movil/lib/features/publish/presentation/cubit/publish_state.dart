import 'package:equatable/equatable.dart';

abstract class PublishState extends Equatable {
  const PublishState();
  @override
  List<Object?> get props => [];
}

class PublishInitial extends PublishState {
  const PublishInitial();
}

class PublishLoading extends PublishState {
  const PublishLoading();
}

class PublishSuccess extends PublishState {
  const PublishSuccess(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class PublishError extends PublishState {
  const PublishError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
