import 'package:bloc/bloc.dart';

/// A defensive [Cubit] that skips emissions once it has been closed.
///
/// Long running async work may complete after the cubit is disposed. When that
/// happens the default [Cubit.emit] throws a [StateError]. By guarding against
/// `isClosed`, features can finish their work without crashing the UI tree.
abstract class SafeCubit<State> extends Cubit<State> {
  SafeCubit(State initialState) : super(initialState);

  @override
  void emit(State state) {
    if (isClosed) {
      return;
    }
    super.emit(state);
  }
}
