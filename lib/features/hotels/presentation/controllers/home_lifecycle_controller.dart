import 'package:flutter/widgets.dart';

class HomeLifecycleController with WidgetsBindingObserver {
  HomeLifecycleController({
    required this.onMessage,
  });

  final ValueChanged<String> onMessage;
  bool _hasEnteredBackground = false;

  void attach() {
    WidgetsBinding.instance.addObserver(this);
  }

  void detach() {
    WidgetsBinding.instance.removeObserver(this);
  }

  void notifyAppStarted() {
    onMessage('App iniciada');
    debugPrint('[Lifecycle] App iniciada');
  }

  void _emit(String message) {
    onMessage(message);
    debugPrint('[Lifecycle] $message');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_hasEnteredBackground) {
          _hasEnteredBackground = false;
          _emit('Bienvenido de nuevo');
        }
        break;
      case AppLifecycleState.paused:
        _hasEnteredBackground = true;
        _emit('App en segundo plano');
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _hasEnteredBackground = true;
        break;
      case AppLifecycleState.detached:
        _emit('App cerrandose');
        break;
    }
  }
}
