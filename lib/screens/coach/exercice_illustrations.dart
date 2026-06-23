import 'package:flutter/material.dart';

// Illustrations anatomiques style SVG — fond blanc, corps gris, muscles rouge
class ExerciceIllustration extends StatelessWidget {
  final String nom;
  final Color accentColor;
  final double size;

  const ExerciceIllustration({
    super.key,
    required this.nom,
    this.accentColor = const Color(0xFFE8410A),
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      color: Colors.white,
      child: CustomPaint(
        painter: _ExercicePainter(nom: nom, accent: accentColor),
      ),
    );
  }
}

class _ExercicePainter extends CustomPainter {
  final String nom;
  final Color accent;
  const _ExercicePainter({required this.nom, required this.accent});

  // Couleurs style anatomique
  static const _body    = Color(0xFFD0D0D0); // corps gris clair
  static const _bodyDark= Color(0xFFB0B0B0); // ombre corps
  static const _outline = Color(0xFF888888); // contour
  static const _muscle  = Color(0xFFE53935); // muscle actif rouge

  @override
  void paint(Canvas canvas, Size size) {
    final n = nom.toLowerCase();

    // Fond blanc
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white);

    // Choisir illustration selon exercice
    if (n.contains('squat') || n.contains('hack squat')) {
      _drawSquat(canvas, size);
    } else if (n.contains('hip thrust') || n.contains('fessier') || n.contains('kickback') || n.contains('abducteur') || n.contains('donkey')) {
      _drawHipThrust(canvas, size);
    } else if (n.contains('fente') || n.contains('lunge') || n.contains('step') || n.contains('bulgarian')) {
      _drawLunge(canvas, size);
    } else if (n.contains('développé couché') || n.contains('bench') || n.contains('pec deck') || n.contains('écarté')) {
      _drawBenchPress(canvas, size);
    } else if (n.contains('développé incliné') || n.contains('incline')) {
      _drawInclinePress(canvas, size);
    } else if (n.contains('développé militaire') || n.contains('arnold') || n.contains('shoulder press')) {
      _drawShoulderPress(canvas, size);
    } else if (n.contains('élévation latérale') || n.contains('élévations latérales') || n.contains('élévation frontale')) {
      _drawLateralRaise(canvas, size);
    } else if (n.contains('curl biceps') || n.contains('curl barre') || n.contains('curl marteau') || n.contains('curl incliné') || n.contains('curl concentré') || n.contains('curl machine')) {
      _drawCurl(canvas, size);
    } else if (n.contains('traction') || n.contains('tirage poulie') || n.contains('lat pulldown')) {
      _drawLatPulldown(canvas, size);
    } else if (n.contains('rowing') || n.contains('tirage horizontal') || n.contains('rowing machine')) {
      _drawRowing(canvas, size);
    } else if (n.contains('soulevé') || n.contains('romanian') || n.contains('deadlift') || n.contains('good morning')) {
      _drawDeadlift(canvas, size);
    } else if (n.contains('dips')) {
      _drawDips(canvas, size);
    } else if (n.contains('pompes') || n.contains('push') || n.contains('diamond')) {
      _drawPushUp(canvas, size);
    } else if (n.contains('crunch') || n.contains('relevés') || n.contains('bicycle') || n.contains('ab roller')) {
      _drawCrunch(canvas, size);
    } else if (n.contains('planche') || n.contains('gainage') || n.contains('mountain') || n.contains('russian')) {
      _drawPlank(canvas, size);
    } else if (n.contains('extension triceps') || n.contains('skull') || n.contains('kickback haltère') || n.contains('pushdown')) {
      _drawTricepExtension(canvas, size);
    } else if (n.contains('presse') || n.contains('leg press')) {
      _drawLegPress(canvas, size);
    } else if (n.contains('leg extension') || n.contains('leg curl') || n.contains('mollet')) {
      _drawLegExtension(canvas, size);
    } else if (n.contains('shrug') || n.contains('upright') || n.contains('face pull')) {
      _drawShrug(canvas, size);
    } else {
      _drawGeneric(canvas, size);
    }
  }

  // ─── UTILITAIRES ───
  Paint _fill(Color c) => Paint()..color = c..style = PaintingStyle.fill;
  Paint _stroke(Color c, double w) => Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = w..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

  void _drawOval(Canvas c, Offset center, double rx, double ry, Color color) {
    c.drawOval(Rect.fromCenter(center: center, width: rx * 2, height: ry * 2), _fill(color));
    c.drawOval(Rect.fromCenter(center: center, width: rx * 2, height: ry * 2), _stroke(_outline, 0.8));
  }

  // Dessiner un membre (rectangle arrondi)
  void _drawLimb(Canvas c, Offset from, Offset to, double width, Color fill) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final len = (dx * dx + dy * dy).abs();
    if (len < 0.001) return;
    final angle = (dy / (len == 0 ? 1 : len.abs()));
    final path = Path();
    final perp = Offset(-dy, dx) * (width / 2) / (len == 0 ? 1 : (len * len).abs().clamp(0.1, 100));
    path.moveTo(from.dx + perp.dx, from.dy + perp.dy);
    path.lineTo(to.dx + perp.dx, to.dy + perp.dy);
    path.lineTo(to.dx - perp.dx, to.dy - perp.dy);
    path.lineTo(from.dx - perp.dx, from.dy - perp.dy);
    path.close();
    c.drawPath(path, _fill(fill));
    c.drawPath(path, _stroke(_outline, 0.7));
  }

  // ─── SQUAT ───
  void _drawSquat(Canvas canvas, Size s) {
    final cx = s.width / 2;
    // Barre
    canvas.drawRect(Rect.fromLTWH(cx - s.width * 0.35, s.height * 0.12, s.width * 0.7, s.height * 0.04),
        _fill(const Color(0xFF555555)));
    // Tête
    _drawOval(canvas, Offset(cx, s.height * 0.22), s.width * 0.07, s.height * 0.07, _body);
    // Torse
    _drawTorse(canvas, Offset(cx, s.height * 0.35), s.width * 0.13, s.height * 0.14, true);
    // Cuisses (muscles actifs rouge)
    _drawOval(canvas, Offset(cx - s.width * 0.1, s.height * 0.58), s.width * 0.09, s.height * 0.13, _muscle);
    _drawOval(canvas, Offset(cx + s.width * 0.1, s.height * 0.58), s.width * 0.09, s.height * 0.13, _muscle);
    // Genoux
    _drawOval(canvas, Offset(cx - s.width * 0.1, s.height * 0.72), s.width * 0.06, s.height * 0.05, _bodyDark);
    _drawOval(canvas, Offset(cx + s.width * 0.1, s.height * 0.72), s.width * 0.06, s.height * 0.05, _bodyDark);
    // Mollets
    _drawOval(canvas, Offset(cx - s.width * 0.12, s.height * 0.84), s.width * 0.07, s.height * 0.09, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.12, s.height * 0.84), s.width * 0.07, s.height * 0.09, _body);
    // Fessiers
    _drawOval(canvas, Offset(cx, s.height * 0.47), s.width * 0.16, s.height * 0.1, _muscle);
    _drawLabel(canvas, s, 'SQUAT');
  }

  // ─── HIP THRUST ───
  void _drawHipThrust(Canvas canvas, Size s) {
    final cx = s.width / 2;
    // Banc
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - s.width * 0.35, s.height * 0.58, s.width * 0.7, s.height * 0.08),
        const Radius.circular(4)), _fill(const Color(0xFF888888)));
    // Corps allongé — tête
    _drawOval(canvas, Offset(cx + s.width * 0.3, s.height * 0.48), s.width * 0.07, s.height * 0.07, _body);
    // Épaules appuyées sur banc
    _drawOval(canvas, Offset(cx + s.width * 0.15, s.height * 0.57), s.width * 0.12, s.height * 0.07, _body);
    // Hanches levées (muscle actif)
    _drawOval(canvas, Offset(cx - s.width * 0.1, s.height * 0.42), s.width * 0.18, s.height * 0.12, _muscle);
    // Cuisses
    _drawOval(canvas, Offset(cx - s.width * 0.05, s.height * 0.55), s.width * 0.15, s.height * 0.1, _body);
    // Jambes
    _drawOval(canvas, Offset(cx - s.width * 0.25, s.height * 0.7), s.width * 0.08, s.height * 0.14, _body);
    _drawOval(canvas, Offset(cx - s.width * 0.05, s.height * 0.75), s.width * 0.08, s.height * 0.12, _body);
    // Barre sur hanches
    canvas.drawRect(Rect.fromLTWH(cx - s.width * 0.38, s.height * 0.38, s.width * 0.32, s.height * 0.04),
        _fill(const Color(0xFF555555)));
    _drawLabel(canvas, s, 'HIP THRUST');
  }

  // ─── FENTE ───
  void _drawLunge(Canvas canvas, Size s) {
    final cx = s.width / 2;
    _drawOval(canvas, Offset(cx, s.height * 0.12), s.width * 0.07, s.height * 0.07, _body);
    _drawTorse(canvas, Offset(cx, s.height * 0.26), s.width * 0.11, s.height * 0.12, false);
    // Jambe avant (genou fléchi — muscle actif)
    _drawOval(canvas, Offset(cx - s.width * 0.08, s.height * 0.48), s.width * 0.09, s.height * 0.12, _muscle);
    _drawOval(canvas, Offset(cx - s.width * 0.08, s.height * 0.63), s.width * 0.06, s.height * 0.05, _bodyDark);
    _drawOval(canvas, Offset(cx - s.width * 0.05, s.height * 0.75), s.width * 0.07, s.height * 0.1, _body);
    // Jambe arrière
    _drawOval(canvas, Offset(cx + s.width * 0.12, s.height * 0.52), s.width * 0.08, s.height * 0.11, _muscle);
    _drawOval(canvas, Offset(cx + s.width * 0.15, s.height * 0.65), s.width * 0.06, s.height * 0.05, _bodyDark);
    _drawOval(canvas, Offset(cx + s.width * 0.18, s.height * 0.8), s.width * 0.06, s.height * 0.09, _body);
    // Bras
    _drawOval(canvas, Offset(cx - s.width * 0.18, s.height * 0.3), s.width * 0.05, s.height * 0.11, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.18, s.height * 0.3), s.width * 0.05, s.height * 0.11, _body);
    // Haltères
    _drawOval(canvas, Offset(cx - s.width * 0.22, s.height * 0.42), s.width * 0.05, s.height * 0.04, const Color(0xFF555555));
    _drawOval(canvas, Offset(cx + s.width * 0.22, s.height * 0.42), s.width * 0.05, s.height * 0.04, const Color(0xFF555555));
    _drawLabel(canvas, s, 'FENTE');
  }

  // ─── BENCH PRESS ───
  void _drawBenchPress(Canvas canvas, Size s) {
    final cx = s.width / 2;
    // Banc
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - s.width * 0.38, s.height * 0.55, s.width * 0.76, s.height * 0.07),
        const Radius.circular(4)), _fill(const Color(0xFF888888)));
    canvas.drawRect(Rect.fromLTWH(cx - s.width * 0.08, s.height * 0.62, s.width * 0.16, s.height * 0.25),
        _fill(const Color(0xFF777777)));
    // Corps allongé
    _drawOval(canvas, Offset(cx - s.width * 0.3, s.height * 0.44), s.width * 0.08, s.height * 0.07, _body);
    _drawOval(canvas, Offset(cx, s.height * 0.46), s.width * 0.2, s.height * 0.1, _body);
    // Pectoraux actifs
    _drawOval(canvas, Offset(cx - s.width * 0.07, s.height * 0.43), s.width * 0.1, s.height * 0.07, _muscle);
    _drawOval(canvas, Offset(cx + s.width * 0.07, s.height * 0.43), s.width * 0.1, s.height * 0.07, _muscle);
    // Bras levés
    _drawOval(canvas, Offset(cx - s.width * 0.22, s.height * 0.35), s.width * 0.06, s.height * 0.1, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.22, s.height * 0.35), s.width * 0.06, s.height * 0.1, _body);
    // Barre
    canvas.drawRect(Rect.fromLTWH(cx - s.width * 0.35, s.height * 0.25, s.width * 0.7, s.height * 0.04),
        _fill(const Color(0xFF555555)));
    _drawLabel(canvas, s, 'BENCH PRESS');
  }

  // ─── SHOULDER PRESS ───
  void _drawShoulderPress(Canvas canvas, Size s) {
    final cx = s.width / 2;
    _drawOval(canvas, Offset(cx, s.height * 0.13), s.width * 0.07, s.height * 0.07, _body);
    _drawTorse(canvas, Offset(cx, s.height * 0.3), s.width * 0.12, s.height * 0.14, false);
    // Épaules actives
    _drawOval(canvas, Offset(cx - s.width * 0.17, s.height * 0.26), s.width * 0.07, s.height * 0.07, _muscle);
    _drawOval(canvas, Offset(cx + s.width * 0.17, s.height * 0.26), s.width * 0.07, s.height * 0.07, _muscle);
    // Bras levés
    _drawOval(canvas, Offset(cx - s.width * 0.2, s.height * 0.18), s.width * 0.06, s.height * 0.1, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.2, s.height * 0.18), s.width * 0.06, s.height * 0.1, _body);
    // Barre au-dessus
    canvas.drawRect(Rect.fromLTWH(cx - s.width * 0.3, s.height * 0.08, s.width * 0.6, s.height * 0.04),
        _fill(const Color(0xFF555555)));
    // Avant-bras
    _drawOval(canvas, Offset(cx - s.width * 0.2, s.height * 0.3), s.width * 0.05, s.height * 0.1, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.2, s.height * 0.3), s.width * 0.05, s.height * 0.1, _body);
    // Jambes assis
    _drawOval(canvas, Offset(cx - s.width * 0.1, s.height * 0.62), s.width * 0.09, s.height * 0.13, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.1, s.height * 0.62), s.width * 0.09, s.height * 0.13, _body);
    _drawLabel(canvas, s, 'SHOULDER PRESS');
  }

  // ─── LATERAL RAISE ───
  void _drawLateralRaise(Canvas canvas, Size s) {
    final cx = s.width / 2;
    _drawOval(canvas, Offset(cx, s.height * 0.13), s.width * 0.07, s.height * 0.07, _body);
    _drawTorse(canvas, Offset(cx, s.height * 0.3), s.width * 0.11, s.height * 0.13, false);
    // Bras écartés (muscles actifs)
    _drawOval(canvas, Offset(cx - s.width * 0.28, s.height * 0.3), s.width * 0.1, s.height * 0.06, _muscle);
    _drawOval(canvas, Offset(cx + s.width * 0.28, s.height * 0.3), s.width * 0.1, s.height * 0.06, _muscle);
    // Épaules
    _drawOval(canvas, Offset(cx - s.width * 0.16, s.height * 0.27), s.width * 0.06, s.height * 0.06, _muscle);
    _drawOval(canvas, Offset(cx + s.width * 0.16, s.height * 0.27), s.width * 0.06, s.height * 0.06, _muscle);
    // Haltères
    _drawOval(canvas, Offset(cx - s.width * 0.36, s.height * 0.3), s.width * 0.05, s.height * 0.04, const Color(0xFF555555));
    _drawOval(canvas, Offset(cx + s.width * 0.36, s.height * 0.3), s.width * 0.05, s.height * 0.04, const Color(0xFF555555));
    // Jambes
    _drawOval(canvas, Offset(cx - s.width * 0.07, s.height * 0.62), s.width * 0.07, s.height * 0.15, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.07, s.height * 0.62), s.width * 0.07, s.height * 0.15, _body);
    _drawOval(canvas, Offset(cx - s.width * 0.07, s.height * 0.82), s.width * 0.06, s.height * 0.1, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.07, s.height * 0.82), s.width * 0.06, s.height * 0.1, _body);
    _drawLabel(canvas, s, 'ÉLÉVATION LATÉRALE');
  }

  // ─── CURL BICEPS ───
  void _drawCurl(Canvas canvas, Size s) {
    final cx = s.width / 2;
    _drawOval(canvas, Offset(cx, s.height * 0.12), s.width * 0.07, s.height * 0.07, _body);
    _drawTorse(canvas, Offset(cx, s.height * 0.29), s.width * 0.11, s.height * 0.13, false);
    // Bras droit avec biceps actif
    _drawOval(canvas, Offset(cx + s.width * 0.17, s.height * 0.28), s.width * 0.06, s.height * 0.09, _muscle);
    // Avant-bras fléchi
    _drawOval(canvas, Offset(cx + s.width * 0.22, s.height * 0.42), s.width * 0.05, s.height * 0.1, _body);
    // Haltère
    _drawOval(canvas, Offset(cx + s.width * 0.24, s.height * 0.53), s.width * 0.05, s.height * 0.04, const Color(0xFF555555));
    // Bras gauche tendu
    _drawOval(canvas, Offset(cx - s.width * 0.17, s.height * 0.32), s.width * 0.06, s.height * 0.09, _body);
    _drawOval(canvas, Offset(cx - s.width * 0.18, s.height * 0.46), s.width * 0.05, s.height * 0.1, _body);
    _drawOval(canvas, Offset(cx - s.width * 0.19, s.height * 0.58), s.width * 0.05, s.height * 0.04, const Color(0xFF555555));
    // Jambes
    _drawOval(canvas, Offset(cx - s.width * 0.07, s.height * 0.62), s.width * 0.07, s.height * 0.14, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.07, s.height * 0.62), s.width * 0.07, s.height * 0.14, _body);
    _drawOval(canvas, Offset(cx - s.width * 0.07, s.height * 0.81), s.width * 0.06, s.height * 0.1, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.07, s.height * 0.81), s.width * 0.06, s.height * 0.1, _body);
    _drawLabel(canvas, s, 'CURL BICEPS');
  }

  // ─── LAT PULLDOWN ───
  void _drawLatPulldown(Canvas canvas, Size s) {
    final cx = s.width / 2;
    // Câble
    canvas.drawLine(Offset(cx - s.width * 0.15, 0), Offset(cx - s.width * 0.15, s.height * 0.22),
        _stroke(const Color(0xFF888888), 1.5));
    canvas.drawLine(Offset(cx + s.width * 0.15, 0), Offset(cx + s.width * 0.15, s.height * 0.22),
        _stroke(const Color(0xFF888888), 1.5));
    // Barre poulie
    canvas.drawRect(Rect.fromLTWH(cx - s.width * 0.3, s.height * 0.18, s.width * 0.6, s.height * 0.04),
        _fill(const Color(0xFF555555)));
    _drawOval(canvas, Offset(cx, s.height * 0.26), s.width * 0.07, s.height * 0.07, _body);
    _drawTorse(canvas, Offset(cx, s.height * 0.4), s.width * 0.12, s.height * 0.14, false);
    // Dos actif
    _drawOval(canvas, Offset(cx, s.height * 0.38), s.width * 0.14, s.height * 0.12, _muscle);
    // Bras levés
    _drawOval(canvas, Offset(cx - s.width * 0.2, s.height * 0.28), s.width * 0.06, s.height * 0.1, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.2, s.height * 0.28), s.width * 0.06, s.height * 0.1, _body);
    // Avant-bras
    _drawOval(canvas, Offset(cx - s.width * 0.24, s.height * 0.2), s.width * 0.05, s.height * 0.08, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.24, s.height * 0.2), s.width * 0.05, s.height * 0.08, _body);
    // Jambes assis
    _drawOval(canvas, Offset(cx - s.width * 0.12, s.height * 0.64), s.width * 0.1, s.height * 0.11, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.12, s.height * 0.64), s.width * 0.1, s.height * 0.11, _body);
    _drawLabel(canvas, s, 'TIRAGE POULIE');
  }

  // ─── ROWING ───
  void _drawRowing(Canvas canvas, Size s) {
    final cx = s.width / 2;
    _drawOval(canvas, Offset(cx - s.width * 0.25, s.height * 0.22), s.width * 0.07, s.height * 0.07, _body);
    // Corps penché
    _drawOval(canvas, Offset(cx, s.height * 0.35), s.width * 0.2, s.height * 0.09, _body);
    // Dos actif
    _drawOval(canvas, Offset(cx, s.height * 0.32), s.width * 0.18, s.height * 0.07, _muscle);
    // Bras tirant
    _drawOval(canvas, Offset(cx + s.width * 0.22, s.height * 0.3), s.width * 0.06, s.height * 0.1, _body);
    _drawOval(canvas, Offset(cx - s.width * 0.22, s.height * 0.38), s.width * 0.06, s.height * 0.1, _body);
    // Haltère
    _drawOval(canvas, Offset(cx + s.width * 0.28, s.height * 0.38), s.width * 0.06, s.height * 0.04, const Color(0xFF555555));
    // Jambes
    _drawOval(canvas, Offset(cx - s.width * 0.12, s.height * 0.6), s.width * 0.08, s.height * 0.14, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.08, s.height * 0.6), s.width * 0.08, s.height * 0.14, _body);
    _drawOval(canvas, Offset(cx - s.width * 0.18, s.height * 0.79), s.width * 0.07, s.height * 0.1, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.13, s.height * 0.79), s.width * 0.07, s.height * 0.1, _body);
    _drawLabel(canvas, s, 'ROWING');
  }

  // ─── DEADLIFT ───
  void _drawDeadlift(Canvas canvas, Size s) {
    final cx = s.width / 2;
    _drawOval(canvas, Offset(cx, s.height * 0.13), s.width * 0.07, s.height * 0.07, _body);
    _drawTorse(canvas, Offset(cx, s.height * 0.3), s.width * 0.12, s.height * 0.14, true);
    // Dos lombaire actif
    _drawOval(canvas, Offset(cx, s.height * 0.37), s.width * 0.11, s.height * 0.08, _muscle);
    // Ischio actifs
    _drawOval(canvas, Offset(cx - s.width * 0.09, s.height * 0.53), s.width * 0.09, s.height * 0.12, _muscle);
    _drawOval(canvas, Offset(cx + s.width * 0.09, s.height * 0.53), s.width * 0.09, s.height * 0.12, _muscle);
    // Bras
    _drawOval(canvas, Offset(cx - s.width * 0.18, s.height * 0.33), s.width * 0.05, s.height * 0.11, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.18, s.height * 0.33), s.width * 0.05, s.height * 0.11, _body);
    // Barre sol
    canvas.drawRect(Rect.fromLTWH(cx - s.width * 0.38, s.height * 0.62, s.width * 0.76, s.height * 0.04),
        _fill(const Color(0xFF555555)));
    // Disques
    _drawOval(canvas, Offset(cx - s.width * 0.35, s.height * 0.64), s.width * 0.04, s.height * 0.1, const Color(0xFF333333));
    _drawOval(canvas, Offset(cx + s.width * 0.35, s.height * 0.64), s.width * 0.04, s.height * 0.1, const Color(0xFF333333));
    // Genoux
    _drawOval(canvas, Offset(cx - s.width * 0.09, s.height * 0.67), s.width * 0.06, s.height * 0.05, _bodyDark);
    _drawOval(canvas, Offset(cx + s.width * 0.09, s.height * 0.67), s.width * 0.06, s.height * 0.05, _bodyDark);
    _drawLabel(canvas, s, 'SOULEVÉ DE TERRE');
  }

  // ─── DIPS ───
  void _drawDips(Canvas canvas, Size s) {
    final cx = s.width / 2;
    // Barres parallèles
    canvas.drawRect(Rect.fromLTWH(cx - s.width * 0.35, s.height * 0.38, s.width * 0.08, s.height * 0.45),
        _fill(const Color(0xFF888888)));
    canvas.drawRect(Rect.fromLTWH(cx + s.width * 0.27, s.height * 0.38, s.width * 0.08, s.height * 0.45),
        _fill(const Color(0xFF888888)));
    canvas.drawRect(Rect.fromLTWH(cx - s.width * 0.35, s.height * 0.36, s.width * 0.7, s.height * 0.04),
        _fill(const Color(0xFF666666)));
    _drawOval(canvas, Offset(cx, s.height * 0.14), s.width * 0.07, s.height * 0.07, _body);
    _drawTorse(canvas, Offset(cx, s.height * 0.28), s.width * 0.11, s.height * 0.11, false);
    // Triceps actifs
    _drawOval(canvas, Offset(cx - s.width * 0.16, s.height * 0.28), s.width * 0.06, s.height * 0.09, _muscle);
    _drawOval(canvas, Offset(cx + s.width * 0.16, s.height * 0.28), s.width * 0.06, s.height * 0.09, _muscle);
    // Avant-bras
    _drawOval(canvas, Offset(cx - s.width * 0.28, s.height * 0.34), s.width * 0.05, s.height * 0.08, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.28, s.height * 0.34), s.width * 0.05, s.height * 0.08, _body);
    // Jambes
    _drawOval(canvas, Offset(cx, s.height * 0.52), s.width * 0.07, s.height * 0.13, _body);
    _drawOval(canvas, Offset(cx, s.height * 0.72), s.width * 0.07, s.height * 0.1, _body);
    _drawLabel(canvas, s, 'DIPS');
  }

  // ─── PUSH UP ───
  void _drawPushUp(Canvas canvas, Size s) {
    final cx = s.width / 2;
    _drawOval(canvas, Offset(cx - s.width * 0.28, s.height * 0.3), s.width * 0.07, s.height * 0.07, _body);
    // Corps horizontal
    _drawOval(canvas, Offset(cx, s.height * 0.42), s.width * 0.28, s.height * 0.08, _body);
    // Pectoraux actifs
    _drawOval(canvas, Offset(cx - s.width * 0.1, s.height * 0.39), s.width * 0.12, s.height * 0.06, _muscle);
    _drawOval(canvas, Offset(cx + s.width * 0.1, s.height * 0.39), s.width * 0.12, s.height * 0.06, _muscle);
    // Bras
    _drawOval(canvas, Offset(cx - s.width * 0.25, s.height * 0.5), s.width * 0.05, s.height * 0.12, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.25, s.height * 0.5), s.width * 0.05, s.height * 0.12, _body);
    // Jambes
    _drawOval(canvas, Offset(cx + s.width * 0.1, s.height * 0.57), s.width * 0.14, s.height * 0.07, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.3, s.height * 0.65), s.width * 0.06, s.height * 0.12, _body);
    _drawLabel(canvas, s, 'POMPES');
  }

  // ─── CRUNCH ───
  void _drawCrunch(Canvas canvas, Size s) {
    final cx = s.width / 2;
    // Sol
    canvas.drawRect(Rect.fromLTWH(0, s.height * 0.82, s.width, s.height * 0.03),
        _fill(const Color(0xFFEEEEEE)));
    _drawOval(canvas, Offset(cx - s.width * 0.25, s.height * 0.48), s.width * 0.07, s.height * 0.07, _body);
    // Corps fléchi (crunch)
    _drawOval(canvas, Offset(cx, s.height * 0.6), s.width * 0.22, s.height * 0.08, _body);
    // Abdos actifs
    _drawOval(canvas, Offset(cx - s.width * 0.05, s.height * 0.57), s.width * 0.11, s.height * 0.07, _muscle);
    _drawOval(canvas, Offset(cx + s.width * 0.08, s.height * 0.59), s.width * 0.09, s.height * 0.07, _muscle);
    // Jambes
    _drawOval(canvas, Offset(cx + s.width * 0.15, s.height * 0.7), s.width * 0.1, s.height * 0.1, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.28, s.height * 0.78), s.width * 0.08, s.height * 0.07, _body);
    // Mains derrière tête
    _drawOval(canvas, Offset(cx - s.width * 0.18, s.height * 0.43), s.width * 0.06, s.height * 0.09, _body);
    _drawOval(canvas, Offset(cx - s.width * 0.08, s.height * 0.42), s.width * 0.06, s.height * 0.09, _body);
    _drawLabel(canvas, s, 'CRUNCH');
  }

  // ─── PLANCHE ───
  void _drawPlank(Canvas canvas, Size s) {
    final cx = s.width / 2;
    canvas.drawRect(Rect.fromLTWH(0, s.height * 0.72, s.width, s.height * 0.03),
        _fill(const Color(0xFFEEEEEE)));
    _drawOval(canvas, Offset(cx - s.width * 0.3, s.height * 0.5), s.width * 0.07, s.height * 0.07, _body);
    // Corps horizontal
    _drawOval(canvas, Offset(cx, s.height * 0.55), s.width * 0.3, s.height * 0.07, _body);
    // Abdos actifs
    _drawOval(canvas, Offset(cx - s.width * 0.05, s.height * 0.53), s.width * 0.15, s.height * 0.05, _muscle);
    // Avant-bras au sol
    _drawOval(canvas, Offset(cx - s.width * 0.28, s.height * 0.65), s.width * 0.05, s.height * 0.1, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.28, s.height * 0.65), s.width * 0.05, s.height * 0.1, _body);
    // Pieds
    _drawOval(canvas, Offset(cx + s.width * 0.35, s.height * 0.68), s.width * 0.05, s.height * 0.06, _body);
    _drawLabel(canvas, s, 'PLANCHE');
  }

  // ─── TRICEP EXTENSION ───
  void _drawTricepExtension(Canvas canvas, Size s) {
    final cx = s.width / 2;
    _drawOval(canvas, Offset(cx, s.height * 0.12), s.width * 0.07, s.height * 0.07, _body);
    _drawTorse(canvas, Offset(cx, s.height * 0.29), s.width * 0.11, s.height * 0.13, false);
    // Bras levé (triceps actif)
    _drawOval(canvas, Offset(cx + s.width * 0.17, s.height * 0.2), s.width * 0.06, s.height * 0.1, _muscle);
    // Avant-bras plié derrière la tête
    _drawOval(canvas, Offset(cx + s.width * 0.22, s.height * 0.33), s.width * 0.05, s.height * 0.1, _body);
    // Haltère
    _drawOval(canvas, Offset(cx + s.width * 0.23, s.height * 0.44), s.width * 0.05, s.height * 0.04, const Color(0xFF555555));
    // Bras gauche sur côté
    _drawOval(canvas, Offset(cx - s.width * 0.18, s.height * 0.32), s.width * 0.06, s.height * 0.11, _body);
    // Jambes
    _drawOval(canvas, Offset(cx - s.width * 0.07, s.height * 0.62), s.width * 0.07, s.height * 0.14, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.07, s.height * 0.62), s.width * 0.07, s.height * 0.14, _body);
    _drawOval(canvas, Offset(cx - s.width * 0.07, s.height * 0.81), s.width * 0.06, s.height * 0.1, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.07, s.height * 0.81), s.width * 0.06, s.height * 0.1, _body);
    _drawLabel(canvas, s, 'TRICEPS');
  }

  // ─── LEG PRESS ───
  void _drawLegPress(Canvas canvas, Size s) {
    final cx = s.width / 2;
    // Machine (dossier incliné)
    final path = Path()
      ..moveTo(cx + s.width * 0.35, s.height * 0.2)
      ..lineTo(cx - s.width * 0.1, s.height * 0.55)
      ..lineTo(cx - s.width * 0.1, s.height * 0.65)
      ..lineTo(cx + s.width * 0.38, s.height * 0.3)
      ..close();
    canvas.drawPath(path, _fill(const Color(0xFF999999)));
    // Corps
    _drawOval(canvas, Offset(cx + s.width * 0.25, s.height * 0.35), s.width * 0.08, s.height * 0.08, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.15, s.height * 0.48), s.width * 0.13, s.height * 0.1, _body);
    // Jambes poussant (muscles actifs)
    _drawOval(canvas, Offset(cx - s.width * 0.02, s.height * 0.4), s.width * 0.09, s.height * 0.12, _muscle);
    _drawOval(canvas, Offset(cx - s.width * 0.14, s.height * 0.32), s.width * 0.09, s.height * 0.1, _muscle);
    _drawOval(canvas, Offset(cx - s.width * 0.25, s.height * 0.24), s.width * 0.08, s.height * 0.08, _bodyDark);
    // Plateforme
    canvas.drawRect(Rect.fromLTWH(cx - s.width * 0.38, s.height * 0.16, s.width * 0.16, s.height * 0.16),
        _fill(const Color(0xFF777777)));
    _drawLabel(canvas, s, 'LEG PRESS');
  }

  // ─── LEG EXTENSION ───
  void _drawLegExtension(Canvas canvas, Size s) {
    final cx = s.width / 2;
    // Siège machine
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - s.width * 0.28, s.height * 0.38, s.width * 0.56, s.height * 0.1),
        const Radius.circular(4)), _fill(const Color(0xFF888888)));
    canvas.drawRect(Rect.fromLTWH(cx - s.width * 0.05, s.height * 0.48, s.width * 0.1, s.height * 0.35),
        _fill(const Color(0xFF777777)));
    _drawOval(canvas, Offset(cx, s.height * 0.2), s.width * 0.07, s.height * 0.07, _body);
    _drawOval(canvas, Offset(cx, s.height * 0.32), s.width * 0.14, s.height * 0.09, _body);
    // Cuisses assis
    _drawOval(canvas, Offset(cx - s.width * 0.12, s.height * 0.42), s.width * 0.1, s.height * 0.07, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.12, s.height * 0.42), s.width * 0.1, s.height * 0.07, _body);
    // Jambes étendues (quadriceps actifs)
    _drawOval(canvas, Offset(cx - s.width * 0.2, s.height * 0.68), s.width * 0.08, s.height * 0.16, _muscle);
    _drawOval(canvas, Offset(cx + s.width * 0.2, s.height * 0.68), s.width * 0.08, s.height * 0.16, _muscle);
    _drawLabel(canvas, s, 'LEG EXTENSION');
  }

  // ─── SHRUG ───
  void _drawShrug(Canvas canvas, Size s) {
    final cx = s.width / 2;
    _drawOval(canvas, Offset(cx, s.height * 0.12), s.width * 0.07, s.height * 0.07, _body);
    // Trapèzes actifs (épaules montées)
    _drawOval(canvas, Offset(cx - s.width * 0.14, s.height * 0.23), s.width * 0.08, s.height * 0.07, _muscle);
    _drawOval(canvas, Offset(cx + s.width * 0.14, s.height * 0.23), s.width * 0.08, s.height * 0.07, _muscle);
    _drawTorse(canvas, Offset(cx, s.height * 0.35), s.width * 0.12, s.height * 0.12, false);
    // Bras tendus avec barre
    _drawOval(canvas, Offset(cx - s.width * 0.17, s.height * 0.35), s.width * 0.06, s.height * 0.11, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.17, s.height * 0.35), s.width * 0.06, s.height * 0.11, _body);
    canvas.drawRect(Rect.fromLTWH(cx - s.width * 0.35, s.height * 0.48, s.width * 0.7, s.height * 0.04),
        _fill(const Color(0xFF555555)));
    _drawOval(canvas, Offset(cx - s.width * 0.35, s.height * 0.5), s.width * 0.04, s.height * 0.09, const Color(0xFF333333));
    _drawOval(canvas, Offset(cx + s.width * 0.35, s.height * 0.5), s.width * 0.04, s.height * 0.09, const Color(0xFF333333));
    _drawOval(canvas, Offset(cx - s.width * 0.08, s.height * 0.66), s.width * 0.07, s.height * 0.14, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.08, s.height * 0.66), s.width * 0.07, s.height * 0.14, _body);
    _drawOval(canvas, Offset(cx - s.width * 0.08, s.height * 0.84), s.width * 0.06, s.height * 0.1, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.08, s.height * 0.84), s.width * 0.06, s.height * 0.1, _body);
    _drawLabel(canvas, s, 'SHRUG');
  }

  // ─── INCLINE PRESS ───
  void _drawInclinePress(Canvas canvas, Size s) {
    final cx = s.width / 2;
    // Banc incliné
    canvas.save();
    canvas.translate(cx, s.height * 0.5);
    canvas.rotate(-0.3);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(-s.width * 0.35, -s.height * 0.06, s.width * 0.7, s.height * 0.12),
        const Radius.circular(6)), _fill(const Color(0xFF888888)));
    canvas.restore();
    _drawOval(canvas, Offset(cx - s.width * 0.22, s.height * 0.28), s.width * 0.07, s.height * 0.07, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.05, s.height * 0.42), s.width * 0.17, s.height * 0.09, _body);
    // Pec haut actif
    _drawOval(canvas, Offset(cx - s.width * 0.02, s.height * 0.37), s.width * 0.12, s.height * 0.07, _muscle);
    _drawOval(canvas, Offset(cx + s.width * 0.13, s.height * 0.38), s.width * 0.1, s.height * 0.07, _muscle);
    _drawOval(canvas, Offset(cx - s.width * 0.15, s.height * 0.27), s.width * 0.06, s.height * 0.1, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.25, s.height * 0.32), s.width * 0.06, s.height * 0.1, _body);
    canvas.drawRect(Rect.fromLTWH(cx - s.width * 0.3, s.height * 0.16, s.width * 0.6, s.height * 0.04),
        _fill(const Color(0xFF555555)));
    _drawLabel(canvas, s, 'INCLINE PRESS');
  }

  // ─── GÉNÉRIQUE ───
  void _drawGeneric(Canvas canvas, Size s) {
    final cx = s.width / 2;
    _drawOval(canvas, Offset(cx, s.height * 0.13), s.width * 0.07, s.height * 0.07, _body);
    _drawTorse(canvas, Offset(cx, s.height * 0.3), s.width * 0.12, s.height * 0.14, false);
    _drawOval(canvas, Offset(cx - s.width * 0.17, s.height * 0.32), s.width * 0.06, s.height * 0.12, _muscle);
    _drawOval(canvas, Offset(cx + s.width * 0.17, s.height * 0.32), s.width * 0.06, s.height * 0.12, _muscle);
    _drawOval(canvas, Offset(cx - s.width * 0.07, s.height * 0.62), s.width * 0.07, s.height * 0.14, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.07, s.height * 0.62), s.width * 0.07, s.height * 0.14, _body);
    _drawOval(canvas, Offset(cx - s.width * 0.07, s.height * 0.81), s.width * 0.06, s.height * 0.1, _body);
    _drawOval(canvas, Offset(cx + s.width * 0.07, s.height * 0.81), s.width * 0.06, s.height * 0.1, _body);
    _drawLabel(canvas, s, 'EXERCICE');
  }

  // ─── TORSE ───
  void _drawTorse(Canvas canvas, Offset center, double rx, double ry, bool withGlutes) {
    canvas.drawOval(Rect.fromCenter(center: center, width: rx * 2, height: ry * 2), _fill(_body));
    canvas.drawOval(Rect.fromCenter(center: center, width: rx * 2, height: ry * 2), _stroke(_outline, 0.8));
    if (withGlutes) {
      _drawOval(canvas, Offset(center.dx, center.dy + ry * 0.7), rx * 0.9, ry * 0.4, _bodyDark);
    }
  }

  // Label bas
  void _drawLabel(Canvas canvas, Size s, String text) {
    // Ligne décorative
    canvas.drawLine(Offset(s.width * 0.15, s.height * 0.91),
        Offset(s.width * 0.85, s.height * 0.91),
        _stroke(const Color(0xFFE8410A), 1));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
