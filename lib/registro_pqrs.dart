import 'package:flutter/material.dart';
import 'main.dart';

class RegistroPqrs extends StatefulWidget {
  const RegistroPqrs({super.key, required this.api});
  final Api api;
  @override
  State<RegistroPqrs> createState() => _RegistroPqrsState();
}

class _RegistroPqrsState extends State<RegistroPqrs> {
  final formulario = GlobalKey<FormState>();
  final campos = <String, TextEditingController>{
    for (final nombre in [
      'nombre_cliente', 'apellido_cliente', 'email_cliente',
      'telefono_cliente', 'asunto', 'mensaje',
    ]) nombre: TextEditingController(),
  };
  List<Map<String, dynamic>> tipos = [];
  int? tipo;
  bool cargando = true;
  bool enviando = false;
  String error = '';
  bool enviado = false;

  @override
  void initState() {
    super.initState();
    cargarTipos();
  }

  @override
  void dispose() {
    for (final c in campos.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> cargarTipos() async {
    try {
      final respuesta = await widget.api.pedir('GET', '/api/pqrs/tipos');
      final datos = respuesta is Map ? respuesta['datos'] : respuesta;
      final lista = datos is List ? datos
          : datos is Map && datos['tipos'] is List ? datos['tipos']
          : <dynamic>[];
      if (!mounted) return;
      setState(() {
        tipos = lista.whereType<Map>()
            .map((t) => Map<String, dynamic>.from(t)).toList();
      });
    } catch (e) {
      if (mounted) setState(() { error = e.toString(); });
    } finally {
      if (mounted) setState(() { cargando = false; });
    }
  }

  Future<void> enviar() async {
    if (!(formulario.currentState?.validate() ?? false)) return;
    if (tipo == null) {
      setState(() { error = 'Selecciona un tipo de PQRS'; });
      return;
    }
    setState(() { enviando = true; error = ''; });
    try {
      await widget.api.pedir('POST', '/api/pqrs', {
        'id_TipoPQRSF': tipo,
        for (final campo in campos.entries)
          campo.key: campo.value.text.trim(),
      });
      if (!mounted) return;
      setState(() { enviado = true; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Tu PQRS fue registrada exitosamente')));
    } catch (e) {
      if (mounted) setState(() { error = e.toString(); });
    } finally {
      if (mounted) setState(() { enviando = false; });
    }
  }

  Widget campo(String clave, String titulo, {
    int lineas = 1, TextInputType? teclado,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: campos[clave],
        maxLines: lineas,
        keyboardType: teclado,
        maxLength: clave == 'mensaje' ? 500 : null,
        decoration: InputDecoration(
          labelText: titulo,
          filled: true,
          fillColor: const Color(0xFFFFFBF7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
        ),
        style: const TextStyle(color: Color(0xFF251A18)),
        validator: (valor) {
          final v = (valor ?? '').trim();
          if (v.isEmpty) return 'Este campo es obligatorio';
          if (clave == 'mensaje' && v.length < 10) {
            return 'Escribe al menos 10 caracteres';
          }
          if (clave == 'email_cliente' &&
              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
            return 'Correo electrónico inválido';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF281615),
      appBar: AppBar(title: const Text('Registrar PQRS'),
        backgroundColor: vino),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF7E9DD),
              borderRadius: BorderRadius.circular(18),
            ),
            child: enviado
              ? Column(children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 54),
                  const SizedBox(height: 12),
                  const Text('¡Éxito!',
                    style: TextStyle(color: Color(0xFF251A18), fontSize: 24)),
                  const Text('Tu PQRS ha sido registrada exitosamente.',
                    style: TextStyle(color: Color(0xFF251A18))),
                  TextButton(onPressed: () => Navigator.pop(context),
                    child: const Text('Volver')),
                ])
              : Form(key: formulario, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('CANAL DE ATENCIÓN',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF923326),
                        fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Registrar PQRS',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF251A18),
                        fontSize: 29, fontWeight: FontWeight.bold)),
                    const Text(
                      'Peticiones, Quejas, Reclamos, Sugerencias y Felicitaciones',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF674A40))),
                    const SizedBox(height: 18),
                    if (cargando) const LinearProgressIndicator(),
                    DropdownButtonFormField<int>(
                      initialValue: tipo,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de PQRS *'),
                      items: tipos.map((t) => DropdownMenuItem<int>(
                        value: int.tryParse(t['id'].toString()) ?? 0,
                        child: Text((t['nombre'] ?? '').toString(),
                          style: const TextStyle(color: Color(0xFF251A18))),
                      )).toList(),
                      onChanged: (v) => setState(() { tipo = v; }),
                    ),
                    const SizedBox(height: 16),
                    campo('nombre_cliente', 'Nombre *'),
                    campo('apellido_cliente', 'Apellido *'),
                    campo('email_cliente', 'Correo electrónico *',
                      teclado: TextInputType.emailAddress),
                    campo('telefono_cliente', 'Teléfono *',
                      teclado: TextInputType.phone),
                    campo('asunto', 'Asunto *'),
                    campo('mensaje', 'Descripción *', lineas: 5),
                    if (error.isNotEmpty) Text(error,
                      style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: enviando ? null : enviar,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFB52A1E)),
                      child: Text(enviando ? 'Enviando...' : 'ENVIAR PQRS'),
                    ),
                  ],
                )),
          ),
        ]),
      )),
    );
  }
}
