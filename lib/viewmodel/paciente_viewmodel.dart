import '../models/paciente.dart';
import '../models/propietario.dart';
import '../repository/paciente_repository.dart';
import 'base_viewmodel.dart';

class PacienteViewModel extends BaseViewModel {
  PacienteViewModel({PacienteRepository? repository})
    : _repository = repository ?? PacienteRepository();

  final PacienteRepository _repository;

  List<Paciente> _pacientes = [];
  Paciente? _seleccionado;
  Propietario? _propietarioSeleccionado;
  Map<String, dynamic>? _estadisticas;

  List<Paciente> get pacientes => _pacientes;
  Paciente? get seleccionado => _seleccionado;
  Propietario? get propietarioSeleccionado => _propietarioSeleccionado;
  Map<String, dynamic>? get estadisticas => _estadisticas;

  Future<void> cargarTodos() async {
    setLoading();
    try {
      _pacientes = await _repository.obtenerTodosPacientes();
      _estadisticas = await _repository.obtenerEstadisticas();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> cargarPorPropietario(int propietarioId) async {
    setLoading();
    try {
      _pacientes = await _repository.obtenerPacientesPorPropietario(
        propietarioId,
      );
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> cargarDetalle(int pacienteId) async {
    setLoading();
    try {
      final data = await _repository.obtenerPacienteConPropietario(pacienteId);
      _seleccionado = data?['paciente'] as Paciente?;
      _propietarioSeleccionado = data?['propietario'] as Propietario?;
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<int> crearPaciente(Paciente paciente) async {
    setLoading();
    try {
      final id = await _repository.guardarPaciente(paciente);
      await cargarTodos();
      return id;
    } catch (e) {
      setError(e.toString());
      rethrow;
    }
  }

  Future<void> actualizarPaciente(Paciente paciente) async {
    setLoading();
    try {
      await _repository.actualizarPaciente(paciente);
      await cargarDetalle(paciente.id!);
      setSuccess();
    } catch (e) {
      setError(e.toString());
      rethrow;
    }
  }

  Future<void> eliminarPaciente(int id) async {
    setLoading();
    try {
      await _repository.eliminarPaciente(id);
      _pacientes.removeWhere((p) => p.id == id);
      setSuccess();
    } catch (e) {
      setError(e.toString());
      rethrow;
    }
  }

  Future<void> buscarPorNombre(String nombre) async {
    setLoading();
    try {
      _pacientes = await _repository.buscarPorNombre(nombre);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<Map<String, dynamic>?> obtenerHistorial(int pacienteId) async {
    setLoading();
    try {
      final historial = await _repository.obtenerHistorialCompleto(pacienteId);
      setSuccess();
      return historial;
    } catch (e) {
      setError(e.toString());
      rethrow;
    }
  }

  void limpiarSeleccion() {
    _seleccionado = null;
    _propietarioSeleccionado = null;
    notifyListeners();
  }
}
