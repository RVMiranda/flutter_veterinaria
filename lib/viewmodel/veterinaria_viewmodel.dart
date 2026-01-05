import '../models/veterinaria_info.dart';
import '../repository/veterinaria_repository.dart';
import 'base_viewmodel.dart';

class VeterinariaViewModel extends BaseViewModel {
  VeterinariaViewModel({VeterinariaRepository? repository})
    : _repository = repository ?? VeterinariaRepository();

  final VeterinariaRepository _repository;

  VeterinariaInfo? _info;

  VeterinariaInfo? get info => _info;

  Future<void> cargarInformacion() async {
    setLoading();
    try {
      _info = await _repository.obtenerInformacion();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> guardarInformacion(VeterinariaInfo info) async {
    setLoading();
    try {
      await _repository.guardarInformacion(info);
      _info = await _repository.obtenerInformacion();
      setSuccess();
    } catch (e) {
      setError(e.toString());
      rethrow;
    }
  }

  Future<void> actualizarLogo(String logoPath) async {
    setLoading();
    try {
      await _repository.actualizarLogo(logoPath);
      _info = await _repository.obtenerInformacion();
      setSuccess();
    } catch (e) {
      setError(e.toString());
      rethrow;
    }
  }

  Future<void> actualizarContacto({
    String? telefonoPrincipal,
    String? telefonoUrgencias,
    String? emailContacto,
  }) async {
    setLoading();
    try {
      await _repository.actualizarContacto(
        telefonoPrincipal: telefonoPrincipal,
        telefonoUrgencias: telefonoUrgencias,
        emailContacto: emailContacto,
      );
      _info = await _repository.obtenerInformacion();
      setSuccess();
    } catch (e) {
      setError(e.toString());
      rethrow;
    }
  }

  Future<bool> existeConfiguracion() async {
    try {
      return await _repository.existeConfiguracion();
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  void limpiar() {
    _info = null;
    notifyListeners();
  }
}
