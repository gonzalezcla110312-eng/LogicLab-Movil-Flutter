import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

const backend = String.fromEnvironment('API_URL', defaultValue: 'http://10.211.236.23:3001');
const vino = Color(0xFF281615);
const dorado = Color(0xFFE2B92F);
const naranja = Color(0xFFFF6929);

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false, home: Acceso()));

class Api {
  Api(this.url);
  final String url;
  String token = '';
  late final Dio dio = Dio(BaseOptions(baseUrl: url,
    connectTimeout: const Duration(seconds: 8)));
  Future<dynamic> pedir(String metodo, String ruta, [Object? datos]) async {
    try {
      final r = await dio.request(ruta, data: datos,
        options: Options(method: metodo, headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token'
        }));
      return r.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data is Map
        ? (e.response?.data['error'] ?? 'Solicitud rechazada')
        : 'No hay conexión con ' + url);
    }
  }
}

class Acceso extends StatefulWidget {
  const Acceso({super.key});
  @override
  State<Acceso> createState() => _AccesoState();
}
class _AccesoState extends State<Acceso> {
  final correo = TextEditingController();
  final clave = TextEditingController();
  final servidor = TextEditingController(text: backend);
  bool cargando = false;
  String error = '';
  Future<void> entrar() async {
    setState(() { cargando = true; error = ''; });
    try {
      final api = Api(servidor.text.trim());
      final r = await api.pedir('POST', '/api/usuarios/login',
        {'email': correo.text.trim(), 'password': clave.text});
      if (r['exito'] != true) throw Exception(r['error'] ?? 'Acceso denegado');
      api.token = r['token'].toString();
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => Panel(api: api, usuario: Map<String, dynamic>.from(r['usuario']))));
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }
  @override
  void dispose() { correo.dispose(); clave.dispose(); servidor.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF170F0E),
    body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(25),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('MANGATA', style: TextStyle(fontSize: 38,
          fontWeight: FontWeight.bold, color: dorado)),
        const SizedBox(height: 32),
        TextField(controller: correo, decoration: const InputDecoration(
          labelText: 'Correo electrónico')),
        TextField(controller: clave, obscureText: true,
          decoration: const InputDecoration(labelText: 'Contraseña')),
        ExpansionTile(title: const Text('Servidor Node.js'),
          children: [TextField(controller: servidor,
            decoration: const InputDecoration(labelText: 'URL del backend'))]),
        if (error.isNotEmpty) Text(error, style: const TextStyle(color: Colors.red)),
        FilledButton(onPressed: cargando ? null : entrar,
          child: Text(cargando ? 'Conectando...' : 'INICIAR SESIÓN')),
      ]))),
  );
}

class Panel extends StatefulWidget {
  const Panel({super.key, required this.api, required this.usuario});
  final Api api;
  final Map<String, dynamic> usuario;
  @override
  State<Panel> createState() => _PanelState();
}
class _PanelState extends State<Panel> {
  String pagina = 'Panel';
  @override
  Widget build(BuildContext context) {
    final rol = widget.usuario['rol'].toString().toLowerCase();
    final admin = rol == 'administrador';
    final secciones = [
      'Panel',
      if (admin) ...['Empleados', 'Platos', 'Menús', 'PQRS', 'Ganancias', 'Reservaciones'],
      if (rol == 'mesero' || rol == 'cocinero') ...['Platos', 'Menús'],
      if (rol == 'mesero') ...['Mesas', 'Reservaciones'],
      if (rol == 'cocinero') 'Cocina',
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF170F0E),
      appBar: AppBar(backgroundColor: vino,
        title: const Text('MANGATA', style: TextStyle(color: dorado))),
      drawer: Drawer(backgroundColor: vino, child: SafeArea(
        child: Column(children: [
          ListTile(title: const Text('MANGATA'),
            subtitle: Text('Bienvenido, ' + widget.usuario['nombre'].toString())),
          Expanded(child: ListView(children: secciones.map((s) =>
            ListTile(title: Text(s), selected: pagina == s,
              onTap: () { setState(() => pagina = s); Navigator.pop(context); })
          ).toList())),
          ListTile(title: const Text('CERRAR SESIÓN'), onTap: () =>
            Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const Acceso()), (_) => false)),
        ]))),
      body: pagina == 'Menús'
        ? MenuDia(api: widget.api)
        : VistaApi(api: widget.api, titulo: pagina, ruta: switch (pagina) {
          'Empleados' => '/api/usuarios',
          'Platos' => '/api/platillos',
          'PQRS' => '/api/pqrs',
          'Ganancias' => '/api/admin/dashboard/ingresos',
          'Reservaciones' => '/api/reservaciones',
          'Mesas' => '/api/mesas',
          'Cocina' => '/api/mesas/pedidos/activos/cocina',
          _ => admin ? '/api/admin/dashboard/estadisticas' : '/api/mesas/pedidos',
        }),
    );
  }
}

class VistaApi extends StatefulWidget {
  const VistaApi({super.key, required this.api, required this.titulo, required this.ruta});
  final Api api;
  final String titulo, ruta;
  @override
  State<VistaApi> createState() => _VistaApiState();
}
class _VistaApiState extends State<VistaApi> {
  late Future<dynamic> datos;
  @override
  void initState() { super.initState(); actualizar(); }
  void actualizar() => setState(() => datos = widget.api.pedir('GET', widget.ruta));
  @override
  Widget build(BuildContext context) => Column(children: [
    ListTile(title: Text(widget.titulo, style: const TextStyle(color: dorado, fontSize: 23)),
      trailing: IconButton(onPressed: actualizar, icon: const Icon(Icons.refresh))),
    Expanded(child: FutureBuilder<dynamic>(future: datos, builder: (context, snap) {
      if (!snap.hasData && !snap.hasError) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snap.hasError) return Center(child: Text(snap.error.toString()));
      dynamic value = snap.data is Map ? snap.data['datos'] : snap.data;
      if (value is Map) {
        for (final key in ['items', 'registros', 'resultados']) {
          if (value[key] is List) { value = value[key]; break; }
        }
      }
      if (value is List) {
        return ListView(children: value.map((v) => Card(color: vino,
          child: ListTile(title: Text(v is Map
            ? (v['nombre'] ?? v['nombre_cliente'] ?? v['asunto'] ?? 'Registro').toString()
            : v.toString()),
            subtitle: Text(v.toString())))).toList());
      }
      return ListView(children: [Padding(padding: const EdgeInsets.all(16),
        child: Text(value.toString()))]);
    })),
  ]);
}

class MenuDia extends StatefulWidget {
  const MenuDia({super.key, required this.api});
  final Api api;
  @override
  State<MenuDia> createState() => _MenuDiaState();
}
class _MenuDiaState extends State<MenuDia> {
  List<Map<String, dynamic>> platos = [];
  final elegidos = <int>[];
  bool cargando = true;
  String error = '';
  @override
  void initState() { super.initState(); cargar(); }
  Future<void> cargar() async {
    setState(() { cargando = true; error = ''; });
    try {
      final r = await widget.api.pedir('GET', '/api/platillos');
      platos = (r['datos'] as List).whereType<Map>()
        .map((p) => Map<String, dynamic>.from(p)).toList();
      final fecha = DateTime.now().toIso8601String().substring(0, 10);
      try {
        final menu = await widget.api.pedir('GET', '/api/menu-dia/' + fecha);
        elegidos.clear();
        final datos = menu['datos'];
        if (datos is Map && datos['items'] is List) {
          for (final p in datos['items']) {
            final id = int.tryParse((p['platillo_id'] ?? p['id']).toString());
            if (id != null) elegidos.add(id);
          }
        }
      } catch (_) { elegidos.clear(); }
    } catch (e) { error = e.toString(); }
    if (mounted) setState(() => cargando = false);
  }
  Future<void> guardar() async {
    if (elegidos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Selecciona al menos un plato.')));
      return;
    }
    try {
      final fecha = DateTime.now().toIso8601String().substring(0, 10);
      await widget.api.pedir('PUT', '/api/menu-dia/' + fecha, {
        'publicado': true,
        'items': [for (var i = 0; i < elegidos.length; i++)
          {'platillo_id': elegidos[i], 'orden': i + 1}]
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menú guardado correctamente')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())));
    }
  }
  @override
  Widget build(BuildContext context) => Column(children: [
    ListTile(title: const Text('MENÚ DEL DÍA',
      style: TextStyle(color: dorado, fontSize: 22)),
      trailing: IconButton(onPressed: cargar, icon: const Icon(Icons.refresh))),
    if (cargando) const Expanded(child: Center(child: CircularProgressIndicator()))
    else if (error.isNotEmpty) Expanded(child: Center(child: Text(error)))
    else Expanded(child: ListView(children: platos.map((p) {
      final id = int.tryParse(p['id'].toString()) ?? -1;
      return Card(color: vino, child: CheckboxListTile(
        activeColor: naranja,
        title: Text(p['nombre'].toString()),
        subtitle: Text((p['descripcion'] ?? '').toString() + '\n' + r'\$' + p['precio'].toString(),
          style: const TextStyle(color: dorado)),
        value: elegidos.contains(id),
        onChanged: (v) => setState(() {
          if (v == true) { if (id > 0 && !elegidos.contains(id)) elegidos.add(id); }
          else { elegidos.remove(id); }
        }),
      ));
    }).toList())),
    Padding(padding: const EdgeInsets.all(16),
      child: Column(children: [
        Text('Platos seleccionados: ' + elegidos.length.toString()),
        SizedBox(width: double.infinity, child: FilledButton(
          onPressed: guardar, child: const Text('GUARDAR MENÚ DEL DÍA'))),
      ])),
  ]);
}
