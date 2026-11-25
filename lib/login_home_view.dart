import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

class LoginHomeView extends StatelessWidget {
  const LoginHomeView({
    super.key,
    required this.usuarioController,
    required this.contrasenaController,
    required this.cargando,
    required this.error,
    required this.onLogin,
    required this.onMenu,
    required this.onPqrs,
    required this.onRecovery,
  });

  final TextEditingController usuarioController;
  final TextEditingController contrasenaController;
  final bool cargando;
  final String error;
  final Future<void> Function() onLogin;
  final VoidCallback onMenu;
  final VoidCallback onPqrs;
  final VoidCallback onRecovery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF181212), Color(0xFF2A1313), Color(0xFF1F1411)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -110,
              left: -130,
              child: _AmbientGlow(size: 420, color: Color(0x52E8582A)),
            ),
            const Positioned(
              right: -90,
              bottom: -140,
              child: _AmbientGlow(size: 380, color: Color(0x3DFF6E2A)),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _AmbientGridPainter()),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth <= 600;
                  final desktop = constraints.maxWidth > 900;
                  final padding = desktop
                      ? 24.0
                      : compact
                      ? 10.0
                      : 16.0;
                  final gap = desktop
                      ? 42.0
                      : compact
                      ? 18.0
                      : 26.0;
                  final availableWidth = math.max(
                    0.0,
                    constraints.maxWidth - padding * 2,
                  );
                  final panelWidth = math.min(
                    desktop ? 500.0 : 610.0,
                    availableWidth,
                  );

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(padding),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: math.max(
                          0.0,
                          constraints.maxHeight - padding * 2,
                        ),
                      ),
                      child: Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            SizedBox(
                              width: panelWidth,
                              child: _staffCard(compact, desktop),
                            ),
                            SizedBox(
                              width: panelWidth,
                              child: _clientCard(compact, desktop),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _staffCard(bool compact, bool desktop) {
    return _LoginPanel(
      compact: compact,
      desktop: desktop,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _LoginChip(label: 'Zona de personal'),
          const SizedBox(height: 10),
          _LoginTitle(title: 'Inicio de Sesión', fontSize: compact ? 27 : 31),
          const Text(
            'Ingresa para gestionar pedidos en tiempo real.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF63463F),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: usuarioController,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: Color(0xFF261C1B), fontSize: 14),
            decoration: _inputDecoration('Nombre de usuario'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: contrasenaController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => unawaited(onLogin()),
            style: const TextStyle(color: Color(0xFF261C1B), fontSize: 14),
            decoration: _inputDecoration('Contraseña'),
          ),
          if (error.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFB82220), fontSize: 13),
            ),
          ],
          const SizedBox(height: 14),
          _GradientButton(
            label: 'Siguiente',
            compact: compact,
            loading: cargando,
            onPressed: cargando ? null : () => unawaited(onLogin()),
          ),
          TextButton(
            onPressed: onRecovery,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF823626),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.only(top: 16),
            ),
            child: const Text('Recuperación contraseña'),
          ),
        ],
      ),
    );
  }

  Widget _clientCard(bool compact, bool desktop) {
    return _LoginPanel(
      compact: compact,
      desktop: desktop,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _LoginChip(label: 'Acceso clientes'),
          const SizedBox(height: 10),
          _LoginTitle(
            title: 'Menú Digital - Cliente',
            fontSize: compact ? 27 : 31,
          ),
          const Text(
            'Explora el menú y registra tus PQRS de forma rápida.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF63463F),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          _GradientButton(
            label: 'Ver Menú',
            compact: compact,
            onPressed: onMenu,
          ),
          const SizedBox(height: 10),
          _GradientButton(
            label: 'Registrar PQRS',
            compact: compact,
            colors: const [Color(0xFF5F1311), Color(0xFF9A2217)],
            shadowColor: const Color(0x54681813),
            onPressed: onPqrs,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0x8063433D), fontSize: 14),
      filled: true,
      fillColor: const Color(0xC2FFFFFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x47BD4C28)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xB3E0562B), width: 1.5),
      ),
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.child,
    required this.compact,
    required this.desktop,
  });

  final Widget child;
  final bool compact;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(compact ? 14 : 18);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            desktop ? 34 : 24,
            desktop ? 38 : 32,
            desktop ? 34 : 24,
            desktop ? 32 : 28,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xF7FFF5EC), Color(0xF2FFEDDE)],
            ),
            borderRadius: borderRadius,
            border: Border.all(color: const Color(0x47FF7A38)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x6B000000),
                blurRadius: 60,
                offset: Offset(0, 22),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _LoginChip extends StatelessWidget {
  const _LoginChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xE074170F),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0x61C63016)),
        ),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFFFF6F1),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.9,
          ),
        ),
      ),
    );
  }
}

class _LoginTitle extends StatelessWidget {
  const _LoginTitle({required this.title, required this.fontSize});

  final String title;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF221615),
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        Container(
          width: 64,
          height: 3,
          margin: const EdgeInsets.only(top: 13, bottom: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB2201F), Color(0xFFFF6F2F)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onPressed,
    this.compact = false,
    this.loading = false,
    this.colors = const [
      Color(0xFFB61E1C),
      Color(0xFFE24F24),
      Color(0xFFFF7E2A),
    ],
    this.shadowColor = const Color(0x59B22B19),
  });

  final String label;
  final VoidCallback? onPressed;
  final bool compact;
  final bool loading;
  final List<Color> colors;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    return SizedBox(
      height: compact ? 39 : 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: borderRadius,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        color: const Color(0xFFFFF8F3),
                        fontSize: compact ? 12 : 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
            stops: const [0, 0.72],
          ),
        ),
      ),
    );
  }
}

class _AmbientGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x01FFFFFF)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 44) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 44) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
