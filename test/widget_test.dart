import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logiclab/login_home_view.dart';

void main() {
  testWidgets('renders both access panels and their actions', (tester) async {
    final usuarioController = TextEditingController();
    final contrasenaController = TextEditingController();
    var menuOpened = false;
    var pqrsOpened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: LoginHomeView(
          usuarioController: usuarioController,
          contrasenaController: contrasenaController,
          cargando: false,
          error: '',
          onLogin: () async {},
          onMenu: () => menuOpened = true,
          onPqrs: () => pqrsOpened = true,
          onRecovery: () {},
        ),
      ),
    );

    expect(find.text('Inicio de Sesión'), findsOneWidget);
    expect(find.text('Menú Digital - Cliente'), findsOneWidget);
    expect(find.text('VER MENÚ'), findsOneWidget);
    expect(find.text('REGISTRAR PQRS'), findsOneWidget);

    await tester.ensureVisible(find.text('VER MENÚ'));
    await tester.tap(find.text('VER MENÚ'));
    await tester.pump();
    expect(menuOpened, isTrue);

    await tester.ensureVisible(find.text('REGISTRAR PQRS'));
    await tester.tap(find.text('REGISTRAR PQRS'));
    await tester.pump();
    expect(pqrsOpened, isTrue);

    usuarioController.dispose();
    contrasenaController.dispose();
  });
}
