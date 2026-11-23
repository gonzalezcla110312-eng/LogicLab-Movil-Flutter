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
    backgroundColor: const Color(0xFF291512),
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 700),
        padding: const EdgeInsets.fromLTRB(30, 40, 30, 30),
        decoration: BoxDecoration(
          color: const Color(0xFFF8ECE2),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFEFC5B5)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
            decoration: BoxDecoration(color: const Color(0xFF923326),
              borderRadius: BorderRadius.circular(30)),
            child: const Text('ZONA DE PERSONAL',
              style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold,
                color: Colors.white, fontSize: 14))),
          const SizedBox(height: 17),
          const Text('Inicio de Sesión',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF251A18),
              fontWeight: FontWeight.w800, fontSize: 35)),
          const SizedBox(height: 12),
          Container(width: 80, height: 4,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(colors: [
                Color(0xFFC52320), Color(0xFFFF7628)]))),
          const SizedBox(height: 16),
          const Text('Ingresa para gestionar pedidos en tiempo real.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF674A40),
              fontFamily: 'serif', fontSize: 17)),
          const SizedBox(height: 25),
          TextField(controller: correo, keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Color(0xFF251A18)),
            decoration: campo('Nombre de usuario')),
          const SizedBox(height: 16),
          TextField(controller: clave, obscureText: true,
            style: const TextStyle(color: Color(0xFF251A18)),
            decoration: campo('Contraseña')),
          if (error.isNotEmpty) Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(error, style: const TextStyle(color: Color(0xFFB82220)))),
          const SizedBox(height: 17),
          SizedBox(width: double.infinity, height: 64,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Color(0xFFBB211E), Color(0xFFFF7927)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Color(0x44BB3021),
                  blurRadius: 19, offset: Offset(0, 12))]),
              child: TextButton(onPressed: cargando ? null : entrar,
                child: Text(cargando ? 'CONECTANDO...' : 'SIGUIENTE',
                  style: const TextStyle(color: Colors.white,
                    fontFamily: 'serif', fontWeight: FontWeight.bold,
                    fontSize: 16))))),
          const SizedBox(height: 15),
          TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(
                'Recuperación de contraseña pendiente de implementar en el backend.'))),
            child: const Text('Recuperación contraseña',
              style: TextStyle(color: Color(0xFF923326),
                fontFamily: 'serif', fontWeight: FontWeight.bold,
                fontSize: 16))),
        ]),
      ),
    ))),
  );

  InputDecoration campo(String titulo) => InputDecoration(
    hintText: titulo,
    hintStyle: const TextStyle(color: Color(0xFF9B8F8B),
      fontFamily: 'serif', fontSize: 17),
    filled: true,
    fillColor: const Color(0xFFFFFBFA),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 21),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Color(0xFFEFC4B2))),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Color(0xFFDD5434), width: 1.5)),
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
  void actualizar() {
    final solicitud = widget.api.pedir('GET', widget.ruta);
    setState(() { datos = solicitud; });
  }
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
        final menu = await widget.api.pedir('GET', '/api/menu-dia/hoy');
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
    ListTile(title: const Text('MENÚ HOY',
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
        Text('Total platos en menú: ' + elegidos.length.toString()),
        SizedBox(width: double.infinity, child: FilledButton(
          onPressed: guardar, child: const Text('↑ Subir Menú del Día'))),
      ])),
  ]);
}
