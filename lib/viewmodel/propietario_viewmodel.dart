import '../models/propietario.dart';
import '../repository/propietario_repository.dart';
import 'base_viewmodel.dart';

class PropietarioViewModel extends BaseViewModel {
  PropietarioViewModel({PropietarioRepository? repository})
    : _repository = repository ?? PropietarioRepository();

  final PropietarioRepository _repository;

  List<Propietario> _propietarios = [];
  Propietario? _seleccionado;

  List<Propietario> get propietarios => _propietarios;
  Propietario? get seleccionado => _seleccionado;

  Future<void> cargarTodos() async {
    setLoading();
    try {
      _propietarios = await _repository.obtenerTodosPropietarios();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> cargarDetalle(int propietarioId) async {
    setLoading();
    try {
      _seleccionado = await _repository.obtenerPropietarioPorId(propietarioId);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<int> crearPropietario(Propietario propietario) async {
    setLoading();
    try {
      final id = await _repository.guardarPropietario(propietario);
      await cargarTodos();
      return id;
    } catch (e) {
      setError(e.toString());
      rethrow;
    }
  }

  Future<void> actualizarPropietario(Propietario propietario) async {
    setLoading();
    try {
      await _repository.actualizarPropietario(propietario);
      await cargarDetalle(propietario.id!);
      setSuccess();
    } catch (e) {
      setError(e.toString());
      rethrow;
    }
  }

  Future<void> eliminarPropietario(int id) async {
    setLoading();
    try {
      await _repository.eliminarPropietario(id);
      _propietarios.removeWhere((p) => p.id == id);
      setSuccess();
    } catch (e) {
      setError(e.toString());
      rethrow;
    }
  }

  Future<void> buscarPorNombre(String nombre) async {
    setLoading();
    try {
      _propietarios = await _repository.buscarPorNombre(nombre);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> buscarPorEmail(String email) async {
    setLoading();
    try {
      final encontrado = await _repository.buscarPorEmail(email);
      _seleccionado = encontrado;
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> buscarPorTelefono(String telefono) async {
    setLoading();
    try {
      final encontrado = await _repository.buscarPorTelefono(telefono);
      _seleccionado = encontrado;
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  void limpiarSeleccion() {
    _seleccionado = null;
    notifyListeners();
  }
}
