import '../models/medico.dart';
import '../repository/medico_repository.dart';
import 'base_viewmodel.dart';

class MedicoViewModel extends BaseViewModel {
  MedicoViewModel({MedicoRepository? repository})
    : _repository = repository ?? MedicoRepository();

  final MedicoRepository _repository;

  List<Medico> _medicos = [];
  Medico? _seleccionado;
  Map<String, dynamic>? _estadisticasSeleccionado;

  List<Medico> get medicos => _medicos;
  Medico? get seleccionado => _seleccionado;
  Map<String, dynamic>? get estadisticasSeleccionado =>
      _estadisticasSeleccionado;

  Future<void> cargarTodos() async {
    setLoading();
    try {
      _medicos = await _repository.obtenerTodosMedicos();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> cargarDetalle(int medicoId) async {
    setLoading();
    try {
      _seleccionado = await _repository.obtenerMedicoPorId(medicoId);
      _estadisticasSeleccionado = await _repository.obtenerEstadisticasMedico(
        medicoId,
      );
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<int> crearMedico(Medico medico) async {
    setLoading();
    try {
      final id = await _repository.guardarMedico(medico);
      await cargarTodos();
      return id;
    } catch (e) {
      setError(e.toString());
      rethrow;
    }
  }

  Future<void> actualizarMedico(Medico medico) async {
    setLoading();
    try {
      await _repository.actualizarMedico(medico);
      await cargarDetalle(medico.id!);
      setSuccess();
    } catch (e) {
      setError(e.toString());
      rethrow;
    }
  }

  Future<void> eliminarMedico(int id) async {
    setLoading();
    try {
      await _repository.eliminarMedico(id);
      _medicos.removeWhere((m) => m.id == id);
      setSuccess();
    } catch (e) {
      setError(e.toString());
      rethrow;
    }
  }

  Future<void> buscarPorNombre(String nombre) async {
    setLoading();
    try {
      _medicos = await _repository.buscarPorNombre(nombre);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> buscarPorMatricula(String matricula) async {
    setLoading();
    try {
      final encontrado = await _repository.buscarPorMatricula(matricula);
      _seleccionado = encontrado;
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  void limpiarSeleccion() {
    _seleccionado = null;
    _estadisticasSeleccionado = null;
    notifyListeners();
  }
}
