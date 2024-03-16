import 'package:flutter_bloc/flutter_bloc.dart';

enum NamazState { Neutral, Qiyam, Ruku, Sajdah, Qaada }

class NamazPosture extends Cubit<NamazState> {
  NamazPosture() : super(NamazState.Qiyam);

  void setNamazState(NamazState current) {
    emit(current);
  }

  void update() {
    emit(state);
  }

  void reset() {
    emit(NamazState.Neutral);
  }
}
