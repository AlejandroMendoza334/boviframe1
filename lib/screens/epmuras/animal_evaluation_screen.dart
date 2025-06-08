import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart'; // Para rootBundle.load()
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

// ——— IMPORTS PDF ———
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // pw.Document, pw.Table, pw.Text, etc.
import 'package:printing/printing.dart';

import '../providers/session_provider.dart';
import '../providers/settings_provider.dart';
import '../../widgets/custom_app_scaffold.dart';

class AnimalEvaluationScreen extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? initialData;
  final bool isEditing;

  const AnimalEvaluationScreen({Key? key})
      : docId = null,
        initialData = null,
        isEditing = false,
        super(key: key);

  const AnimalEvaluationScreen.edit({
    Key? key,
    required this.docId,
    required this.initialData,
  })  : isEditing = true,
        super(key: key);

  @override
  State<AnimalEvaluationScreen> createState() => _AnimalEvaluationScreenState();
}

class _AnimalEvaluationScreenState extends State<AnimalEvaluationScreen> {
  // ─── Controllers para cada campo:
  final _numeroController = TextEditingController();
  final _registroController = TextEditingController();
  final _pesoNacController = TextEditingController();
  final _pesoDestController = TextEditingController();
  final _pesoAjusController = TextEditingController();
  final _edadDiasController = TextEditingController();
  final _fechaNacController = TextEditingController();
  final _fechaDestController = TextEditingController();
  Future<void> _selectDate(
  BuildContext ctx,
  TextEditingController ctrl,
) async {
  DateTime init = DateTime.now();
  try {
    init = DateTime.parse(ctrl.text);
  } catch (_) {}
  final picked = await showDatePicker(
    context: ctx,
    initialDate: init,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  if (picked != null) {
    ctrl.text = picked.toIso8601String().split('T').first;
    _markChanged();
    _calcularPesoAjustado();

  }
}

// ──────────────────────────────

  // Dropdowns:
  String? _selectedSexo;
  String? _selectedEstadoAnimal;

  // Mapa de EPMURAS para esta evaluación:
  Map<String, String?> _epmuras = {
    'E': null,
    'P': null,
    'M': null,
    'U': null,
    'R': null,
    'A': null,
    'S': null,
  };

  Uint8List? _imageBytes; // Foto del animal
  String? _sessionId; // Viene de SessionProvider
  bool _hasChanged = false;
  String? _lastEvaluationId;
  bool _loading = true;

  Map<String, dynamic>? _sessionData;
  Map<String, dynamic>? _producerData;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();

    // Si es edición, precargamos datos en los controllers:
    if (widget.isEditing && widget.initialData != null) {
      final data = widget.initialData!;
      _numeroController.text = data['numero']?.toString() ?? '';
      _registroController.text = data['registro']?.toString() ?? '';
      _selectedSexo = data['sexo']?.toString();
      _selectedEstadoAnimal = data['estado']?.toString();
      _fechaNacController.text = data['fecha_nac']?.toString() ?? '';
      _fechaDestController.text = data['fecha_dest']?.toString() ?? '';
      _pesoNacController.text = data['peso_nac']?.toString() ?? '';
      _pesoDestController.text = data['peso_dest']?.toString() ?? '';
      _pesoAjusController.text = data['peso_ajus']?.toString() ?? '';
      _edadDiasController.text = data['edad_dias']?.toString() ?? '';
      

      final epm = (data['epmuras'] as Map<String, dynamic>? ?? {});
      epm.forEach((key, value) {
        if (_epmuras.containsKey(key)) {
          _epmuras[key] = value?.toString();
        }
      });

      if (data['image_base64'] != null) {
        try {
          _imageBytes = base64Decode(data['image_base64'] as String);
        } catch (_) {
          _imageBytes = null;
        }
      }
    }

    // Detectar cambios para habilitar “Actualizar”:
    _numeroController.addListener(_markChanged);
_registroController.addListener(_markChanged);
_pesoNacController.addListener(_markChanged);
_pesoDestController.addListener(_markChanged);
_pesoAjusController.addListener(_markChanged);
_edadDiasController.addListener(_markChanged);
_fechaNacController.addListener(_markChanged);
_fechaDestController.addListener(_markChanged);

// Añade los listeners de peso ajustado justo después:
_pesoNacController.addListener(_calcularPesoAjustado);
_pesoDestController.addListener(_calcularPesoAjustado);
_fechaNacController.addListener(_calcularPesoAjustado);
_fechaDestController.addListener(_calcularPesoAjustado);

    

    // Registrar el callback de reset para el provider (si lo usas):
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SessionProvider>(
        context,
        listen: false,
      ).registerResetEvaluationForm(_resetForm);
    });

    // Cargar datos de sesión/productor/usuario desde Firestore:
    _loadAllData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && args['sessionId'] != null) {
      _sessionId = args['sessionId'] as String;
      Provider.of<SessionProvider>(context, listen: false).sessionId =
          _sessionId!;
    } else {
      _sessionId =
          Provider.of<SessionProvider>(context, listen: false).sessionId;
    }

    if (widget.isEditing &&
        widget.initialData != null &&
        widget.initialData!['session_id'] != null) {
      _sessionId = widget.initialData!['session_id'].toString();
      Provider.of<SessionProvider>(context, listen: false).sessionId =
          _sessionId!;
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _registroController.dispose();
    _pesoNacController.dispose();
    _pesoDestController.dispose();
    _pesoAjusController.dispose();
    _edadDiasController.dispose();
    _fechaNacController.dispose();
    _fechaDestController.dispose();
    super.dispose();
  }

  void _markChanged() {
    if (!_hasChanged) setState(() => _hasChanged = true);
  }

  void _resetForm() {
    _numeroController.clear();
    _registroController.clear();
    _pesoNacController.clear();
    _pesoDestController.clear();
    _pesoAjusController.clear();
    _edadDiasController.clear();
    _fechaNacController.clear();
    _fechaDestController.clear();
    setState(() {
      _selectedSexo = null;
      _selectedEstadoAnimal = null;
      _epmuras.updateAll((k, _) => null);
      _imageBytes = null;
      _hasChanged = false;
    });
    Provider.of<SessionProvider>(context, listen: false).clearAll();
  }
void _calcularPesoAjustado() {
  if (_pesoNacController.text.isEmpty ||
      _pesoDestController.text.isEmpty ||
      _fechaNacController.text.isEmpty ||
      _fechaDestController.text.isEmpty) return;

  final nac = double.tryParse(_pesoNacController.text);
  final dest = double.tryParse(_pesoDestController.text);
  DateTime fn, fd;
  try {
    fn = DateTime.parse(_fechaNacController.text);
    fd = DateTime.parse(_fechaDestController.text);
  } catch (_) {
    return;
  }

  final dias = fd.difference(fn).inDays;
  if (nac == null || dest == null || dias <= 0) return;

  // Fórmula original que daba ~250 kg:
  final ajus = (((dest - nac) / dias) * 205) + nac;

  _pesoAjusController.text = ajus.toStringAsFixed(0);  // redondeo sin decimales
  _edadDiasController.text = dias.toString();
  _markChanged();
}






  Future<void> _pickImage() async {
  showModalBottomSheet(
    context: context,
    builder: (ctx) => Wrap(
      children: [
        ListTile(
          leading: const Icon(Icons.camera_alt),
          title: const Text('Tomar foto'),
          onTap: () async {
            Navigator.pop(ctx);
            final picked = await ImagePicker().pickImage(
              source: ImageSource.camera,
              imageQuality: 85,
            );
            if (picked != null) {
              final bytes = await picked.readAsBytes();
              setState(() {
                _imageBytes = bytes;
                _hasChanged = true;
              });
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.photo_library),
          title: const Text('Seleccionar de galería'),
          onTap: () async {
            Navigator.pop(ctx);
            final picked = await ImagePicker().pickImage(
              source: ImageSource.gallery,
              imageQuality: 85,
            );
            if (picked != null) {
              final bytes = await picked.readAsBytes();
              setState(() {
                _imageBytes = bytes;
                _hasChanged = true;
              });
            }
          },
        ),
      ],
    ),
  );
}


  /// Carga datos de sesión, productor y usuario desde Firestore
  Future<void> _loadAllData() async {
    if (_sessionId == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      // 1) Cargar datos de la sesión
      final sessionSnap = await FirebaseFirestore.instance
          .collection('sesiones')
          .doc(_sessionId)
          .get();
      _sessionData = sessionSnap.data();

      // 2) Leer “datos_productor” como SUBCOLECCIÓN dentro de esta sesión
      final prodQuery = await FirebaseFirestore.instance
          .collection('sesiones')
          .doc(_sessionId)
          .collection('datos_productor')
          .limit(1)
          .get();

      if (prodQuery.docs.isNotEmpty) {
        _producerData = prodQuery.docs.first.data();
      } else {
        _producerData = null;
      }

      // 3) Cargar datos del usuario: **usar “userId” en lugar de “usuarioId”**
      final userId = _sessionData?['userId'] as String?;
      if (userId != null) {
        final userSnap = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
            .get();
        _userData = userSnap.data();
      }
    } catch (e) {
      debugPrint('Error cargando datos de sesión/productor/usuario: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  /// Guarda o actualiza la evaluación en Firestore
  Future<String?> _guardarEvaluacionEnFirestore() async {
    if (_sessionId == null || _sessionId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: sessionId no disponible.'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    final sessionProv = Provider.of<SessionProvider>(context, listen: false);
    sessionProv.setDatosAnimal(
      numero: _numeroController.text,
      registro: _registroController.text,
      sexo: _selectedSexo,
      estadoAnimal: _selectedEstadoAnimal,
      fechaNac: _fechaNacController.text,
      fechaDest: _fechaDestController.text,
      pesoNac: _pesoNacController.text,
      pesoDest: _pesoDestController.text,
      pesoAjus: _pesoAjusController.text,
      edadDias: _edadDiasController.text,
    );
    sessionProv.setEpmuras(_epmuras);
    sessionProv.setImage(_imageBytes);

    final data = <String, dynamic>{
      'numero': _numeroController.text,
      'registro': _registroController.text,
      'sexo': _selectedSexo,
      'estado': _selectedEstadoAnimal,
      'fecha_nac': _fechaNacController.text,
      'fecha_dest': _fechaDestController.text,
      'peso_nac': _pesoNacController.text,
      'peso_dest': _pesoDestController.text,
      'peso_ajus': _pesoAjusController.text,
      'edad_dias': _edadDiasController.text,
      'epmuras': sessionProv.epmuras,
      'image_base64': sessionProv.imageBytes != null
          ? base64Encode(sessionProv.imageBytes!)
          : null,
      'datos_productor': sessionProv.datosProductor,
      'timestamp': Timestamp.now(),
      'session_id': _sessionId,
    };

    try {
      if (widget.isEditing && widget.docId != null) {
        // MODO EDICIÓN
        await FirebaseFirestore.instance
            .collection('sesiones')
            .doc(_sessionId)
            .collection('evaluaciones_animales')
            .doc(widget.docId)
            .update(data);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Evaluación actualizada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return widget.docId;
      } else {
        // MODO NUEVO
        final docRef = await FirebaseFirestore.instance
            .collection('sesiones')
            .doc(_sessionId)
            .collection('evaluaciones_animales')
            .add(data);

        _lastEvaluationId = docRef.id;
        _hasChanged = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Evaluación guardada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return docRef.id;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _guardarYVolver() async {
    final docId = await _guardarEvaluacionEnFirestore();
    if (docId == null) return;
    _resetForm();
    // Al guardar, navegamos a la pestaña de "Nueva Sesión"
    Navigator.pushReplacementNamed(
      context,
      '/new_session',
      arguments: {'sessionId': _sessionId!},
    );
  }

  Future<void> _guardarYNuevo() async {
    final docId = await _guardarEvaluacionEnFirestore();
    if (docId == null) return;
    _resetForm();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AnimalEvaluationScreen(),
        settings: RouteSettings(arguments: {'sessionId': _sessionId}),
      ),
    );
  }

  Future<void> _actualizarEvaluacionExistente() async {
    if (!_hasChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay cambios para actualizar.'),
          backgroundColor: Colors.grey,
        ),
      );
      return;
    }
    if (_sessionId == null || _sessionId!.isEmpty || widget.docId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error: no se puede actualizar (falta sessionId o docId).',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final docId = await _guardarEvaluacionEnFirestore();
    if (docId != null) {
      _resetForm();
      Navigator.pushReplacementNamed(context, '/epmuras');
    }
  }

  Future<void> _cancelarEvaluacion() async {
    // No borra nada en la base de datos. Solo redirige sin modificar registros.
    Navigator.pushReplacementNamed(
      context,
      '/new_session',
      arguments: {'sessionId': _sessionId!},
    );
  }

  /// Construye un resumen de los cambios que estamos a punto de guardar.
  /// Si es edición, solo muestra los campos que difieren de initialData.
  /// Si es nuevo, muestra todos los valores ingresados.
  String _buildResumenCambios() {
    final buffer = StringBuffer();

    // Helper para comparar un campo (edit) vs valor original:
    void compareField(String key, String label, String actualValue) {
      if (widget.isEditing && widget.initialData != null) {
        final original = (widget.initialData![key]?.toString() ?? '');
        if (original != actualValue) {
          buffer.writeln('$label:\n  • Antes: $original\n  • Ahora: $actualValue\n');
        }
      } else {
        // modo “nuevo”
        buffer.writeln('$label: $actualValue\n');
      }
    }

    // Campos texto básicos:
    compareField('numero', 'Número', _numeroController.text);
    compareField('registro', 'Registro (RGN)', _registroController.text);
    compareField('sexo', 'Sexo', _selectedSexo ?? '-');
    compareField('estado', 'Estado Animal', _selectedEstadoAnimal ?? '-');
    compareField('fecha_nac', 'Fecha Nacimiento', _fechaNacController.text);
    compareField('fecha_dest', 'Fecha Destete', _fechaDestController.text);
    compareField('peso_nac', 'Peso Nacimiento', _pesoNacController.text);
    compareField('peso_dest', 'Peso Destete', _pesoDestController.text);
    compareField('peso_ajus', 'Peso Ajustado', _pesoAjusController.text);
    compareField('edad_dias', 'Edad (días)', _edadDiasController.text);

    // EPMURAS:
    if (widget.isEditing && widget.initialData != null) {
      final origEpm = (widget.initialData!['epmuras'] as Map<String, dynamic>? ?? {});
      _epmuras.forEach((letra, valorActual) {
        final origVal = (origEpm[letra]?.toString() ?? '');
        final actVal = valorActual ?? '-';
        if (origVal != actVal) {
          buffer.writeln('EPMURAS $letra:\n  • Antes: $origVal\n  • Ahora: $actVal\n');
        }
      });
    } else {
      // Nuevo => mostrar todos los EPMURAS que tengan algo distinto de null:
      _epmuras.forEach((letra, valorActual) {
        final actVal = valorActual ?? '-';
        buffer.writeln('EPMURAS $letra: $actVal\n');
      });
    }

    // Imagen:
    if (widget.isEditing && widget.initialData != null) {
      final origBase64 = widget.initialData!['image_base64'] as String?;
      final tieneOriginal = origBase64 != null && origBase64.isNotEmpty;
      final tieneActual = _imageBytes != null;
      if (tieneOriginal != tieneActual) {
        buffer.writeln('Foto del animal:\n  • Antes: ${tieneOriginal ? 'existía' : 'no existía'}\n  • Ahora: ${tieneActual ? 'ha sido cargada' : 'ha sido removida'}\n');
      }
    } else {
      // Modo nuevo:
      if (_imageBytes != null) {
        buffer.writeln('Foto del animal: Se cargó una imagen\n');
      } else {
        buffer.writeln('Foto del animal: (sin imagen)\n');
      }
    }

    final resultado = buffer.toString().trim();
    return resultado.isEmpty
        ? '[No hay cambios detectados]'
        : resultado;
  }

  /// Muestra un diálogo de confirmación antes de guardar o actualizar.
  /// Indica también que se redirigirá a la pestaña de "Nueva Sesión".
  Future<void> _confirmGuardar() async {
    final resumen = _buildResumenCambios();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.isEditing ? 'Confirmar Actualización' : 'Confirmar Guardar'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEditing
                      ? 'Vas a actualizar esta evaluación con los siguientes cambios:'
                      : 'Vas a guardar la siguiente información:\n\n(Al confirmar, serás redirigido a la pestaña de Nueva Sesión)',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    resumen,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(widget.isEditing ? 'Actualizar' : 'Guardar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (widget.isEditing) {
        _actualizarEvaluacionExistente();
      } else {
        _guardarYVolver();
      }
    }
  }

  /// Muestra un diálogo de confirmación antes de cancelar la edición/creación.
  /// Solo advierte que se perderán los cambios en la pantalla actual, sin tocar la base de datos.
  Future<void> _confirmCancelar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Salida'),
          content: const Text(
            '¿Deseas salir sin guardar? No se eliminará ningún registro en la base de datos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Seguir Editando'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _cancelarEvaluacion();
    }
  }

  /// -----------------------------------------------------------------------
  /// Carga todas las evaluaciones dentro de cada sesión (colección raíz)
  Future<List<Map<String, dynamic>>> _cargarTodasLasEvaluaciones() async {
    final firestore = FirebaseFirestore.instance;
    final sesionesSnapshot = await firestore
        .collection('sesiones')
        .orderBy('timestamp', descending: true)
        .get();

    final List<Map<String, dynamic>> acumulado = [];

    for (final sesionDoc in sesionesSnapshot.docs) {
      final sessionId = sesionDoc.id;

      // Leer todas las evaluaciones de esta sesión
      final evalsSnapshot = await firestore
          .collection('sesiones')
          .doc(sessionId)
          .collection('evaluaciones_animales')
          .orderBy('timestamp', descending: true)
          .get();

      for (final evalDoc in evalsSnapshot.docs) {
        final mapaEval = evalDoc.data();
        mapaEval['evalId'] = evalDoc.id;
        mapaEval['sessionId'] = sessionId;
        acumulado.add(mapaEval);
      }
    }

    return acumulado;
  }

  /// -----------------------------------------------------------------------
  /// DIALOG PARA “Ver sesiones y evaluaciones”
  void _mostrarConteosDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _cargarTodasLasEvaluaciones(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Error al leer Firestore'),
                content: Text('${snapshot.error}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ],
              );
            }

            final todasLasEval = snapshot.data!;
            final totalEval = todasLasEval.length;

            // Contar cuántas sesiones distintas hay:
            final sesionesDistintas = <String>{};
            for (var m in todasLasEval) {
              if (m['sessionId'] != null) {
                sesionesDistintas.add(m['sessionId'] as String);
              }
            }
            final totalSesiones = sesionesDistintas.length;

            return StatefulBuilder(
              builder: (context, setStateSB) {
                // Filtrar según número o registro:
                final filtered = todasLasEval.where((m) {
                  final numero = (m['numero'] ?? '').toString().toLowerCase();
                  final registro =
                      (m['registro'] ?? '').toString().toLowerCase();
                  final q = searchQuery.toLowerCase();
                  return numero.contains(q) || registro.contains(q);
                }).toList();

                return AlertDialog(
                  title: const Text('Sesiones y Evaluaciones'),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: 400, // Ajusta la altura según convenga
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total evaluaciones: $totalEval'),
                        const SizedBox(height: 4),
                        Text('Sesiones distintas: $totalSesiones'),
                        const SizedBox(height: 12),
                        TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Buscar por número o registro',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) {
                            setStateSB(() {
                              searchQuery = val;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: filtered.isEmpty
                              ? const Center(
                                  child: Text('No se encontraron resultados'),
                                )
                              : ListView.builder(
                                  itemCount: filtered.length,
                                  itemBuilder: (context, idx) {
                                    final m = filtered[idx];
                                    final numero = m['numero'] ?? '—';
                                    final registro = m['registro'] ?? '—';
                                    final fechaNac = m['fecha_nac'] ?? '—';
                                    final pesoNac = m['peso_nac'] ?? '—';
                                    final imageBase64 =
                                        m['image_base64'] as String?;

                                    Widget leadingImage = const SizedBox(
                                      width: 48,
                                    );
                                    if (imageBase64 != null) {
                                      try {
                                        final bytes =
                                            base64Decode(imageBase64);
                                        leadingImage = ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Image.memory(
                                            bytes,
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      } catch (_) {
                                        leadingImage = const SizedBox(
                                          width: 48,
                                        );
                                      }
                                    }

                                    return ListTile(
                                      leading: leadingImage,
                                      title: Text(
                                        'N° $numero  ·  RGN $registro',
                                      ),
                                      subtitle: Text(
                                        'Nac.: $fechaNac  ·  Peso: $pesoNac',
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.picture_as_pdf,
                                          color: Colors.redAccent,
                                        ),
                                        tooltip: 'Descargar PDF',
                                        onPressed: () async {
                                          // 1) Cerramos PRIMERO el AlertDialog
                                          Navigator.of(context).pop();

                                          // 2) Esperamos un micro‐delay
                                          await Future.delayed(
                                            const Duration(
                                                milliseconds: 100),
                                          );

                                          // 3) Debug: confirma que m trae todos los datos
                                          debugPrint(
                                            '[DEBUG] Datos a exportar: $m',
                                          );

                                          // 4) Ahora sí lanzamos la generación/​descarga del PDF
                                          await _printOrSharePDF(m);
                                        },
                                      ),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                AnimalEvaluationScreen.edit(
                                              docId: m['evalId'],
                                              initialData: m,
                                            ),
                                            settings: RouteSettings(
                                              arguments: {
                                                'sessionId': m['sessionId'],
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  /// Calcula el promedio de EPMURAS para una lista de snapshots
  Map<String, double> _calcularPromedioSesion(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    Map<String, double> sumMap = {
      'E': 0,
      'P': 0,
      'M': 0,
      'U': 0,
      'R': 0,
      'A': 0,
      'S': 0,
    };
    int count = 0;

    for (var doc in docs) {
      final data = doc.data();
      final epm = (data['epmuras'] as Map<String, dynamic>? ?? {});
      if (epm.isNotEmpty) {
        count++;
        sumMap.forEach((key, _) {
          final val = double.tryParse(epm[key]?.toString() ?? '') ?? 0.0;
          sumMap[key] = (sumMap[key] ?? 0) + val;
        });
      }
    }
    if (count > 0) {
      sumMap.updateAll((key, val) => val / count);
    }
    return sumMap;
  }

  /// -----------------------------------------------------------------------
  /// Genera (o comparte) el PDF con todos los datos (animal, usuario, lista EPMURAS, etc.)
  Future<void> _printOrSharePDF(Map<String, dynamic> m) async {
    try {
      // ─── 1) EXTRAER DATOS DE 'm' ─────────────────────────────────────────
      final numero = (m['numero'] ?? '').toString();
      final registro = (m['registro'] ?? '').toString();
      final sexo = (m['sexo'] ?? '').toString();
      final estado = (m['estado'] ?? '').toString();
      final fechaNac = (m['fecha_nac'] ?? '').toString();
      final fechaDest = (m['fecha_dest'] ?? '').toString();
      final pesoNac = (m['peso_nac'] ?? '').toString();
      final pesoDest = (m['peso_dest'] ?? '').toString();
      final pesoAjus = (m['peso_ajus'] ?? '').toString();
      final edadDias = (m['edad_dias'] ?? '').toString();

      // Construimos el mapa epmurasForPDF a partir de m['epmuras']
      final rawEpm = (m['epmuras'] as Map<String, dynamic>? ?? {});
      final epmurasForPDF = <String, String>{};
      rawEpm.forEach((k, v) {
        epmurasForPDF[k] = v?.toString() ?? '0';
      });

      // Foto base64 si existe
      final imageBase64 = m['image_base64'] as String?;

      // ─── 2) LEER DATOS DEL USUARIO DESDE FIRESTORE ────────────────────────
      String userName = 'Nombre no disponible';
      String userEmail = 'E-mail no disponible';
      String userProf = 'Profesión no disponible';
      String userLoc = 'Ubicación no disponible';

      try {
        final currentSessionId = (m['sessionId'] ?? '') as String;
        if (currentSessionId.isNotEmpty) {
          final sessionSnap = await FirebaseFirestore.instance
              .collection('sesiones')
              .doc(currentSessionId)
              .get();
          final sessionData = sessionSnap.data();
          final usuarioId = sessionData?['userId'] as String?;
          if (usuarioId != null && usuarioId.isNotEmpty) {
            final userSnap = await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(usuarioId)
                .get();
            final udata = userSnap.data();
            userName = udata?['nombre'] as String? ?? userName;
            userEmail = udata?['email'] as String? ?? userEmail;
            userProf = udata?['profesion'] as String? ?? userProf;
            userLoc = udata?['ubicacion'] as String? ?? userLoc;
          }
        }
      } catch (e) {
        debugPrint('[PDF] Error cargando datos de usuario: $e');
      }

      // ─── 3) LEER DATOS DEL PRODUCTOR (subcolección) ───────────────────────
      String prodTexto = 'No hay datos del productor';
      final datosProductorWidgets = <pw.Widget>[];
      {
        final prodQuery = await FirebaseFirestore.instance
            .collection('sesiones')
            .doc(_sessionId)
            .collection('datos_productor')
            .limit(1)
            .get();
        if (prodQuery.docs.isNotEmpty) {
          _producerData = prodQuery.docs.first.data();
        }
      }
      if (_producerData != null && _producerData!.isNotEmpty) {
        // Definimos exclusivamente los cuatro campos deseados:
        final camposDeseados = <String>[
          'unidad_produccion',
          'ubicacion',
          'estado',
          'municipio',
        ];
        for (final key in camposDeseados) {
          final valor = _producerData![key];
          if (valor != null && valor.toString().trim().isNotEmpty) {
            datosProductorWidgets.add(
              pw.Text(
                '• $key: ${valor.toString()}',
                style: pw.TextStyle(fontSize: 11),
              ),
            );
          }
        }
        prodTexto = 'Datos del productor:';
      }

      // ─── 4) CARGAR LOGO DE ASSETS ────────────────────────────────────────
      final Uint8List logoBytes =
          (await rootBundle.load('assets/icons/logoapp2.png'))
              .buffer
              .asUint8List();

      // ─── 5) DECODIFICAR FOTO DEL ANIMAL (SI HAY) ─────────────────────────
      Uint8List? fotoBytes;
      if (imageBase64 != null) {
        try {
          fotoBytes = base64Decode(imageBase64);
        } catch (_) {
          fotoBytes = null;
        }
      }

      // ─── 6) CALCULAR PROMEDIO DE EPMURAS PARA LA SESIÓN ──────────────────
      List<Map<String, dynamic>> todasEvalMap = [];
      try {
        todasEvalMap = await _cargarTodasLasEvaluaciones();
      } catch (_) {}
      final currentSessionId = _sessionId ?? '';
      final evalsActualSession = todasEvalMap
          .where((e) =>
              (e['sessionId']?.toString() ?? '') == currentSessionId)
          .toList();
      final evalDocsSession = evalsActualSession.map((e) {
        return FakeQueryDocumentSnapshot(e)
            as QueryDocumentSnapshot<Map<String, dynamic>>;
      }).toList();
      final promedioSesionMap = _calcularPromedioSesion(evalDocsSession);

      // ─── 7) CREAR EL DOCUMENTO PDF ────────────────────────────────────────
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            // 7.1) Encabezado con logo e línea azul
            final header = <pw.Widget>[
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(logoBytes),
                  width: 120,
                  height: 40,
                ),
              ),
              pw.Divider(color: PdfColors.blue, thickness: 2),
              pw.SizedBox(height: 8),
            ];

            // 7.2) Datos del usuario (ya cargados correctamente)
            final datosUsuario = <pw.Widget>[
              pw.Text('Usuario: $userName',
                  style: pw.TextStyle(fontSize: 12)),
              pw.Text('Correo: $userEmail',
                  style: pw.TextStyle(fontSize: 12)),
              pw.Text('Profesión: $userProf',
                  style: pw.TextStyle(fontSize: 12)),
              pw.Text('Ubicación: $userLoc',
                  style: pw.TextStyle(fontSize: 12)),
              pw.Divider(color: PdfColors.grey),
            ];

            // 7.3) Encabezado del productor (sólo si hay algo para mostrar)
            final encabezadoProductor = <pw.Widget>[];
            if (datosProductorWidgets.isNotEmpty) {
              encabezadoProductor.add(
                pw.Text(prodTexto, style: pw.TextStyle(fontSize: 12)),
              );
              encabezadoProductor.add(pw.SizedBox(height: 4));
              encabezadoProductor.addAll(datosProductorWidgets);
              encabezadoProductor.add(pw.Divider(color: PdfColors.grey));
              encabezadoProductor.add(pw.SizedBox(height: 8));
            }

            // 7.4) FOTO DEL ANIMAL + DATOS DEL ANIMAL COMO TABLA
            final detallesAnimal = <String>[
              'Número: $numero',
              'Registro (RGN): $registro',
              'Sexo: $sexo',
              'Estado: $estado',
              'Fecha Nacimiento: $fechaNac',
              'Fecha Destete: $fechaDest',
              'Peso Nacimiento: $pesoNac',
              'Peso Destete: $pesoDest',
              'Peso Ajustado: $pesoAjus',
              'Edad (días): $edadDias',
            ];

            final datosAnimalTable = pw.Table(
              columnWidths: {
                0: pw.FixedColumnWidth(200), // ancho fijo para la foto
                1: pw.FlexColumnWidth(), // el resto para los bullets
              },
              children: [
                pw.TableRow(
                  children: [
                    // Celda 0: imagen o “Sin foto”
                    if (fotoBytes != null)
                      pw.Image(
                        pw.MemoryImage(fotoBytes),
                        width: 200,
                        height: 200,
                        fit: pw.BoxFit.cover,
                      )
                    else
                      pw.Container(
                        width: 200,
                        height: 200,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey),
                        ),
                        child: pw.Center(child: pw.Text('Sin foto')),
                      ),

                    // Celda 1: lista de viñetas
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 10),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: detallesAnimal
                            .map((texto) => pw.Bullet(text: texto))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ],
            );

            // 7.5) RESULTADOS EPMURAS (tabla sencilla)
            final tablaEpm = <pw.Widget>[
              pw.SizedBox(height: 16),
              pw.Header(level: 1, text: 'Resultados EPMURAS'),
              pw.Table.fromTextArray(
                headers: ['Letra', 'Valor', 'Promedio Sesión'],
                data: epmurasForPDF.keys.map((letra) {
                  final val = epmurasForPDF[letra] ?? '-';
                  final promDouble = promedioSesionMap[letra] ?? 0.0;
                  final prom = promDouble.toStringAsFixed(2);
                  return [letra, val, prom];
                }).toList(),
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerStyle:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration:
                    pw.BoxDecoration(color: PdfColors.grey200),
              ),
            ];

            // 7.6) Pie de página
            final footer = <pw.Widget>[
              pw.Divider(color: PdfColors.blue, thickness: 2),
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(logoBytes),
                  width: 100,
                  height: 30,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Generado: ${DateTime.now().toString().substring(0, 19)}',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey),
                ),
              ),
            ];

            return [
              ...header,
              ...datosUsuario,
              ...encabezadoProductor,
              datosAnimalTable,
              ...tablaEpm,
              ...footer,
            ];
          },
        ),
      );

      // ─── 8) COMPARTIR / GUARDAR EL PDF ─────────────────────────────────
      final pdfBytes = await pdf.save();
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'evaluacion_animal_$numero.pdf',
      );
    } catch (e) {
      debugPrint('[PDF] Error generando PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al generar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si aún estoy cargando datos de Firestore:
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return CustomAppScaffold(
      currentIndex: 2,
      title: widget.isEditing ? 'Editar Evaluación' : 'Evaluación',
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Botón para ver sesiones y evaluaciones ───
              Center(
                child: ElevatedButton.icon(
                  onPressed: _mostrarConteosDialog,
                  icon: const Icon(Icons.list, color: Colors.white),
                  label: const Text(
                    'Ver sesiones y evaluaciones',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[700],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ──── Campo: Número ────
              _buildLabeledTextField('Número', controller: _numeroController),

              // ─── Campo: Registro Animal (RGN) ───
              _buildLabeledTextField(
                'Registro (RGN)',
                controller: _registroController,
              ),

              // ─ Dropdowns: Estado del Animal y Sexo ─
              Row(
                children: [
                  Expanded(
                    child: _buildLabeledDropdown(
                      'Estado del Animal',
                      _animalStates,
                      value: _selectedEstadoAnimal,
                      onChanged: (val) {
                        setState(() {
                          _selectedEstadoAnimal = val;
                          _markChanged();
                          if (!_animalStates
                              .contains(_selectedEstadoAnimal)) {
                            _selectedEstadoAnimal = null;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLabeledDropdown(
                      'Sexo',
                      ['Macho', 'Hembra'],
                      value: _selectedSexo,
                      onChanged: (val) {
                        setState(() {
                          _selectedSexo = val;
                          _markChanged();
                          if (!_animalStates
                              .contains(_selectedEstadoAnimal)) {
                            _selectedEstadoAnimal = null;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),

              // ─── Fecha Nacimiento / Fecha Destete ───
             Row(
  children: [
    Expanded(
      child: TextField(
  controller: _fechaNacController,
  readOnly: true,
  decoration: const InputDecoration(
    labelText: 'Fecha Nacimiento',
    border: OutlineInputBorder(),
  ),
  onTap: () => _selectDate(context, _fechaNacController),
),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: TextField(
  controller: _fechaDestController,
  readOnly: true,
  decoration: const InputDecoration(
    labelText: 'Fecha Destete',
    border: OutlineInputBorder(),
  ),
  onTap: () => _selectDate(context, _fechaDestController),
),
    ),
  ],
              ),

// ── Peso Nacimiento / Peso Destete ──
Row(
  children: [
    Expanded(
      child: _buildLabeledTextField(
        'Peso Nacimiento',
        controller: _pesoNacController,
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: _buildLabeledTextField(
        'Peso Destete',
        controller: _pesoDestController,
      ),
    ),
  ],
),
const SizedBox(height: 12),

// ── Peso Ajustado / Edad (días) ──
Row(
  children: [
    Expanded(
      child: _buildLabeledTextField(
        'Peso Ajustado',
        controller: _pesoAjusController,
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: _buildLabeledTextField(
        'Edad (días)',
        controller: _edadDiasController,
      ),
    ),
  ],
),

const SizedBox(height: 12),



              // ───── Foto del animal ─────
              const Text('Foto del animal:'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(child: Text('Toca para cargar o tomar foto')),
                ),
              ),

              const SizedBox(height: 20),

              // ─────────── EPMURAS ───────────
              const Text(
                'EPMURAS:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildEpmurasInputs(),

              const SizedBox(height: 20),

              // ───── Botones Guardar / Actualizar / Nuevo / Cancelar ─────
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ─ Botón Guardar o Actualizar ─ ahora llama a _confirmGuardar()
                    ElevatedButton(
                      onPressed: () {
                        _confirmGuardar();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isEditing
                            ? (_hasChanged
                                ? Colors.orange[700]
                                : Colors.grey)
                            : Colors.blue[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        widget.isEditing ? 'Actualizar' : 'Guardar',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ─ Botón “Nuevo” (solo si no estamos editando) ─ (sin cambios)
                    if (!widget.isEditing)
                      ElevatedButton.icon(
                        onPressed: _guardarYNuevo,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Nuevo',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),

                    const SizedBox(width: 12),

                    // ─ Botón “Cancelar” ─ ahora llama a _confirmCancelar()
                    ElevatedButton(
                      onPressed: () {
                        _confirmCancelar();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Construye inputs de EPMURAS
  Widget _buildEpmurasInputs() {
    final letras = _epmuras.keys.toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: letras.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
      final letra = letras[index];
      final maxItems = (letra == 'E' || letra == 'P' || letra == 'M') ? 6 : 4;
      return Row(
        children: [
          Expanded(child: Text(letra, style: TextStyle(fontSize: 18))),
          const SizedBox(width: 8),
          // Contenedor con tamaño fijo
          SizedBox(
            width: 60,    
            height: 48,   
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              style: TextStyle(fontSize: 18, color: Colors.black),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                border: OutlineInputBorder(),
              ),
              iconSize: 20,          
              itemHeight: 48,        
              items: List.generate(
                maxItems,
                (i) => DropdownMenuItem(
                  value: '${i + 1}',
                  child: Center(child: Text('${i + 1}', style: TextStyle(fontSize: 18))),
                ),
              
                ),
                value: _epmuras[letra],
                onChanged: (val) {
                  setState(() {
                    _epmuras[letra] = val;
                    _markChanged();
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  Widget _buildLabeledTextField(
    String label, {
    required TextEditingController controller,
    List<TextInputFormatter>? inputFormatters, 
  }) {
    return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextField(
          controller: controller,
          keyboardType: inputFormatters != null
            ? TextInputType.number
            : TextInputType.text,
          inputFormatters: inputFormatters,          
          onChanged: (_) => _markChanged(),
          decoration: const InputDecoration(
            border: OutlineInputBorder()
          ),
        ),
      ],
    ),
  );
}

  // ─────────────────────────────────────────────────────────────────
  Widget _buildLabeledDropdown(
    String label,
    List<String> items, {
    String? value,
    ValueChanged<String?>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            value: value,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  List<String> get _animalStates {
    if (_selectedSexo == 'Macho') {
      return ['Mautes', 'Toretes', 'Toros'];
    } else if (_selectedSexo == 'Hembra') {
      return ['Mautas', 'Novillas', 'Vacas'];
    }
    return [];
  }
}

/// Clase auxiliar para adaptar un Map<String,dynamic> a
/// QueryDocumentSnapshot<Map<String,dynamic>>
class FakeQueryDocumentSnapshot
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;

  FakeQueryDocumentSnapshot(this._data);

  @override
  Map<String, dynamic> data() => _data;

  @override
  late final DocumentReference<Map<String, dynamic>> reference =
      FirebaseFirestore.instance
          .collection('sesiones')
          .doc('fake')
          .collection('evaluaciones_animales')
          .doc();

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  String get id => reference.id;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
