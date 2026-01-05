import 'package:flutter/foundation.dart';

enum ViewStatus { idle, loading, success, error }

/// Base simple para exponer estado de carga y errores a las vistas.
class BaseViewModel extends ChangeNotifier {
  ViewStatus _status = ViewStatus.idle;
  String? _error;

  ViewStatus get status => _status;
  bool get isLoading => _status == ViewStatus.loading;
  bool get hasError => _status == ViewStatus.error;
  String? get error => _error;

  @protected
  void setLoading() {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
  }

  @protected
  void setSuccess() {
    _status = ViewStatus.success;
    _error = null;
    notifyListeners();
  }

  @protected
  void setIdle() {
    _status = ViewStatus.idle;
    _error = null;
    notifyListeners();
  }

  @protected
  void setError(String message) {
    _status = ViewStatus.error;
    _error = message;
    notifyListeners();
  }
}
