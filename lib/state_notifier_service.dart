import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grid_collage/log_utils.dart';

class StateNotifierService<T> extends StateNotifier<T> {
  StateNotifierService(super.state) {
    LogUtils.d('State notifier class ${runtimeType.toString()} init');
  }

  @override
  void dispose() {
    LogUtils.d('State notifier class ${runtimeType.toString()} disposed');
    super.dispose();
  }

  @override
  set state(T value) {
    if (mounted) super.state = value;
  }
}
