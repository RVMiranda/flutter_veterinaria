import 'package:flutter/foundation.dart';
import '../models/evaluacion_lesion.dart';
import '../models/protocolo.dart';
import '../repository/protocol.dart';
import 'base_viewmodel.dart';

class ProtocoloViewModel extends BaseViewModel {
  ProtocoloViewModel({ProtocoloRepository? repository})
    : _repository = repository ?? ProtocoloRepository();

  final ProtocoloRepository _repository;

  List<Protocolo> _protocolos = [];
  Protocolo? _seleccionado;
  EvaluacionLesion? _evaluacionSeleccionada;
  Map<String, dynamic>? _estadisticas;

  List<Protocolo> get protocolos => _protocolos;
  Protocolo? get seleccionado => _seleccionado;
  EvaluacionLesion? get evaluacionSeleccionada => _evaluacionSeleccionada;
  Map<String, dynamic>? get estadisticas => _estadisticas;

  Future<void> cargarTodos() async {
    setLoading();
    try {
      _protocolos = await _repository.obtenerTodosProtocolos();
      _estadisticas = await _repository.obtenerEstadisticas();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> cargarPorPaciente(int pacienteId) async {
    setLoading();
    try {
      _protocolos = await _repository.obtenerProtocolosPorPaciente(pacienteId);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> cargarDetalle(int protocoloId) async {
    setLoading();
    try {
      final data = await _repository.obtenerProtocoloCompleto(protocoloId);
      _seleccionado = data?['protocolo'] as Protocolo?;
      _evaluacionSeleccionada = data?['evaluacion'] as EvaluacionLesion?;
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<int> crearProtocolo({
    required Protocolo protocolo,
    EvaluacionLesion? evaluacionLesion,
  }) async {
    setLoading();
    try {
      final id = await _repository.guardarProtocoloCompleto(
        protocolo: protocolo,
        evaluacionLesion: evaluacionLesion,
      );
      await cargarTodos();
      return id;
    } catch (e) {
      setError(e.toString());
      rethrow;
    }
  }

  Future<void> actualizarProtocolo({
    required Protocolo protocolo,
    EvaluacionLesion? evaluacionLesion,
  }) async {
    setLoading();
    try {
      await _repository.actualizarProtocoloCompleto(
        protocolo: protocolo,
        evaluacionLesion: evaluacionLesion,
      );
      await cargarDetalle(protocolo.id!);
      setSuccess();
    } catch (e) {
      setError(e.toString());
      rethrow;
    }
  }

  Future<void> eliminarProtocolo(int id) async {
    setLoading();
    try {
      await _repository.eliminarProtocolo(id);
      _protocolos.removeWhere((p) => p.id == id);
      if (_seleccionado?.id == id) {
        _seleccionado = null;
      }
      notifyListeners();
      setSuccess();
    } catch (e) {
      setError(e.toString());
      rethrow;
    }
  }

  Future<int> duplicarProtocolo(int id) async {
    setLoading();
    try {
      final nuevoId = await _repository.duplicarProtocolo(id);
      await cargarTodos();
      return nuevoId;
    } catch (e) {
      setError(e.toString());
      rethrow;
    }
  }

  Future<void> buscarPorNumeroInterno(String numeroInterno) async {
    setLoading();
    try {
      final protocolo = await _repository.buscarPorNumeroInterno(numeroInterno);
      _seleccionado = protocolo;
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  @visibleForTesting
  void limpiarSeleccion() {
    _seleccionado = null;
    _evaluacionSeleccionada = null;
    notifyListeners();
  }
}
