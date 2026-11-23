import 'registro_pqrs.dart';
import 'pedidos_cocina.dart';
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
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFCEAA95)),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5EC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEFC4B2)),
            ),
            child: Column(children: [
              const Text('ACCESO CLIENTES',
                style: TextStyle(color: Color(0xFF923326),
                  fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 9),
              const Text('Menú Digital - Cliente',
                style: TextStyle(color: Color(0xFF251A18),
                  fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 9),
              const Text('Explora el menú y registra tus PQRS de forma rápida.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF674A40))),
              const SizedBox(height: 13),
              SizedBox(width: double.infinity, child: FilledButton(
                onPressed: () {
                  final api = Api(servidor.text.trim());
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('Menú Digital - Cliente')),
                      body: VistaApi(api: api, titulo: 'Menú del Día',
                        ruta: '/api/menu-dia/hoy'))));
                },
                child: const Text('VER MENÚ'),
              )),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => RegistroPqrs(
                      api: Api(servidor.text.trim()))));
                },
                child: const Text('REGISTRAR PQRS',
                  style: TextStyle(color: Color(0xFF923326))),
              )),
            ]),
          ),
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
      if (rol == 'mesero' || rol == 'administrador') 'Pedidos',
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
        : (pagina == 'Cocina' || pagina == 'Pedidos')
        ? PedidosCocina(api: widget.api, rol: pagina == 'Cocina' ? 'cocinero' : rol)
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
  final categorias = const {
    0: 'Todos', 1: 'Carta Corriente', 2: 'Comida Rapida',
    3: 'Carta Especial', 4: 'Bebidas',
  };
  List<Map<String, dynamic>> platos = [];
  List<Map<String, dynamic>> seleccion = [];
  int filtro = 0;
  bool cargando = true;
  bool publicando = false;
  bool publicado = false;
  String error = '';

  int entero(dynamic valor) => int.tryParse(valor.toString()) ?? 0;

  Map<String, dynamic> normalizar(Map item) {
    final p = item['platillo'] is Map ? item['platillo'] as Map : item;
    return {
      'id': entero(p['id'] ?? item['platillo_id']),
      'nombre': (p['nombre'] ?? p['NombrePlato'] ?? '').toString(),
      'descripcion': (p['descripcion'] ?? p['Descripcion'] ?? '').toString(),
      'precio': p['precio'] ?? p['Precio'] ?? 0,
      'categoria_id': entero(p['categoria_id'] ?? p['CategoriaId']),
      'imagen_url': (p['imagen_url'] ?? '').toString(),
    };
  }

  String moneda(dynamic valor) {
    final cantidad = (double.tryParse(valor.toString()) ?? 0).round().toString();
    return '\$' + cantidad.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    setState(() { cargando = true; error = ''; });
    try {
      final respuesta = await widget.api.pedir('GET', '/api/platillos');
      final lista = respuesta is Map ? respuesta['datos'] : null;
      if (lista is! List) throw Exception('No se recibieron platos');
      final nuevosPlatos = lista.whereType<Map>().map(normalizar).toList();
      List<Map<String, dynamic>> nuevosSeleccionados = [];
      try {
        final respuestaMenu = await widget.api.pedir('GET', '/api/menu-dia/hoy');
        final datos = respuestaMenu is Map ? respuestaMenu['datos'] : null;
        final items = datos is Map ? datos['items'] : datos;
        if (items is List) {
          nuevosSeleccionados = items.whereType<Map>().map(normalizar).toList();
        }
      } catch (_) {
        // Un menú aún no creado no impide administrar los platos.
      }
      if (!mounted) return;
      setState(() {
        platos = nuevosPlatos;
        seleccion = nuevosSeleccionados;
        publicado = seleccion.isNotEmpty;
      });
    } catch (e) {
      if (mounted) setState(() { error = e.toString(); });
    } finally {
      if (mounted) setState(() { cargando = false; });
    }
  }

  void avisar(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> limpiar() async {
    try {
      await widget.api.pedir('DELETE', '/api/menu-dia/limpiar');
      if (!mounted) return;
      setState(() { seleccion.clear(); publicado = false; });
    } catch (e) {
      avisar(e.toString());
    }
  }

  Future<void> publicar() async {
    if (seleccion.isEmpty) {
      avisar('Agrega al menos un plato');
      return;
    }
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('MENÚ DE HOY'),
        content: Text('Este será el menú de hoy. ¿Está todo correcto?\n'
          '${seleccion.where((p) => p['categoria_id'] != 4).length} platos · '
          '${seleccion.where((p) => p['categoria_id'] == 4).length} bebidas'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(contexto, false),
            child: const Text('No')),
          FilledButton(onPressed: () => Navigator.pop(contexto, true),
            child: const Text('¡Sí, subir!')),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    setState(() { publicando = true; });
    try {
      final fecha = DateTime.now().toIso8601String().substring(0, 10);
      await widget.api.pedir('PUT', '/api/menu-dia/$fecha', {
        'fecha': fecha,
        'publicado': true,
        'items': [
          for (var n = 0; n < seleccion.length; n++)
            {'platillo_id': seleccion[n]['id'], 'orden': n + 1},
        ],
      });
      if (!mounted) return;
      setState(() { publicado = true; });
      avisar('Menú del día publicado correctamente');
    } catch (e) {
      avisar(e.toString());
    } finally {
      if (mounted) setState(() { publicando = false; });
    }
  }

  Widget plato(Map<String, dynamic> p) => Card(
    color: const Color(0xFF321E1A),
    child: ListTile(
      onTap: () => setState(() {
        seleccion.add(Map<String, dynamic>.from(p));
        publicado = false;
      }),
      title: Text(p['nombre'].toString(),
        style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${p['descripcion']}\n${moneda(p['precio'])}',
        maxLines: 3, overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: dorado)),
      trailing: const Icon(Icons.add_circle_outline, color: naranja),
    ),
  );

  Widget grupo(String nombre, int? categoria) {
    final elementos = seleccion.where((p) =>
      categoria == 4 ? p['categoria_id'] == 4 : p['categoria_id'] != 4).toList();
    if (elementos.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Text(nombre, style: const TextStyle(
          color: dorado, fontSize: 17, fontWeight: FontWeight.bold))),
      for (final p in elementos)
        Card(color: vino, child: ListTile(
          title: Text(p['nombre'].toString()),
          subtitle: Text(moneda(p['precio']),
            style: const TextStyle(color: dorado)),
          trailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent),
            onPressed: () => setState(() {
              seleccion.removeAt(seleccion.indexOf(p));
              publicado = false;
            })),
        )),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final visibles = platos.where((p) =>
      filtro == 0 || p['categoria_id'] == filtro).toList();
    return Column(children: [
      ListTile(
        title: const Text('MENÚ HOY',
          style: TextStyle(color: dorado, fontSize: 25,
            fontWeight: FontWeight.bold)),
        subtitle: const Text('¡Arma el menú de hoy jefecillo!'),
        trailing: IconButton(onPressed: cargar,
          icon: const Icon(Icons.refresh)),
      ),
      if (cargando)
        const Expanded(child: Center(child: CircularProgressIndicator()))
      else if (error.isNotEmpty)
        Expanded(child: Center(child: Text(error)))
      else
        Expanded(child: ListView(padding: const EdgeInsets.all(12), children: [
          const Text('Platos', style: TextStyle(
            color: dorado, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SingleChildScrollView(scrollDirection: Axis.horizontal,
            child: Row(children: [
              for (final cat in categorias.entries)
                Padding(padding: const EdgeInsets.only(right: 7),
                  child: ChoiceChip(
                    label: Text(cat.value),
                    selected: filtro == cat.key,
                    onSelected: (_) => setState(() { filtro = cat.key; }),
                  )),
            ])),
          const SizedBox(height: 12),
          for (final p in visibles) plato(p),
          const SizedBox(height: 24),
          Row(children: [
            const Expanded(child: Text('MENÚ DEL DÍA',
              style: TextStyle(color: dorado, fontSize: 21,
                fontWeight: FontWeight.bold))),
            if (seleccion.isNotEmpty)
              TextButton(onPressed: limpiar,
                child: const Text('Limpiar todo',
                  style: TextStyle(color: Colors.redAccent))),
          ]),
          if (publicado) const Text(
            'Menú activo — visible para clientes y meseros',
            style: TextStyle(color: Colors.greenAccent)),
          if (seleccion.isEmpty)
            const Padding(padding: EdgeInsets.all(20),
              child: Text('Aún no hay platos\nToca un plato para agregarlo',
                textAlign: TextAlign.center)),
          grupo('Platos', null),
          grupo('Bebidas', 4),
          const SizedBox(height: 12),
          Text('Total platos en menú: ${seleccion.length}',
            style: const TextStyle(color: dorado)),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: naranja),
            onPressed: publicando ? null : publicar,
            child: Text(publicando ? 'Publicando...' : '↑ Subir Menú del Día'),
          )),
        ])),
    ]);
  }
}
