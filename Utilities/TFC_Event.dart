import 'dart:developer';

class TFC_Event {
  List<Function> listeners;

  TFC_Event() {
    listeners = List();
  }

  void addListener(Function listener) {
    listeners.add(listener);
  }

  void removeListener(Function listener) {
    listeners.remove(listener);
  }

  void trigger() {
    List<Function> nullListeners = List();
    for (Function listener in listeners) {
      if (listener != null) {
        try {
          listener();
        } catch(e) {
          log(e.toString());
        }
      } else {
        nullListeners.add(listener);
      }
    }
    while (nullListeners.length > 0) {
      Function listener = nullListeners.removeAt(0);
      removeListener(listener);
    }
  }
}