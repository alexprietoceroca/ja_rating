import 'package:flutter/material.dart';
import 'package:ja_rating/coloresApp.dart';
import 'package:ja_rating/Components/pagina_principal/productos_cartas.dart';

class SeccionConScroll extends StatefulWidget {
  final String titulo;
  final String? subtitulo;
  final String? etiqueta;
  final IconData icono;
  final List<Map<String, dynamic>> items;
  final bool esWeb;

  const SeccionConScroll({
    super.key,
    required this.titulo,
    required this.icono,
    required this.items,
    required this.esWeb,
    this.subtitulo,
    this.etiqueta,
  });

  @override
  State<SeccionConScroll> createState() => _SeccionConScrollState();
}

class _SeccionConScrollState extends State<SeccionConScroll> {
  final ScrollController _controladorScroll = ScrollController();
  bool _puedeIrIzquierda = false;
  bool _puedeIrDerecha = true;

  @override
  void initState() {
    super.initState();
    _controladorScroll.addListener(_actualizarBotones);
  }

  @override
  void dispose() {
    _controladorScroll.removeListener(_actualizarBotones);
    _controladorScroll.dispose();
    super.dispose();
  }

  void _actualizarBotones() {
    setState(() {
      _puedeIrIzquierda = _controladorScroll.offset > 0;
      _puedeIrDerecha = _controladorScroll.offset < _controladorScroll.position.maxScrollExtent;
    });
  }

  void _scrollIzquierda() {
    _controladorScroll.animateTo(
      _controladorScroll.offset - 300,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollDerecha() {
    _controladorScroll.animateTo(
      _controladorScroll.offset + 300,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double anchoCarta = widget.esWeb ? 200 : 160;
    final double padding = widget.esWeb ? 40 : 20;

    // altura imagen + padding arriba + titulo + genero + estrellas + padding abajo
    final double altoImagen = anchoCarta * 1.25;
    final double altoInfo = 10 + 36 + 4 + 16 + 6 + 16 + 10;
    final double altoCarta = altoImagen + altoInfo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Row(
            children: [
              Icon(widget.icono, color: Coloresapp.colorPrimario, size: 22),
              const SizedBox(width: 8),
              Text(
                widget.titulo,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111111),
                ),
              ),
              if (widget.etiqueta != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Coloresapp.colorPrimario,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.etiqueta!,
                    style: const TextStyle(
                      color: Coloresapp.colorBlanco,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
              if (widget.subtitulo != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.subtitulo!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Coloresapp.colorTextoFlojo,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (widget.esWeb) ...[
                const Spacer(),
                _BotonScroll(
                  icono: Icons.arrow_back_ios_rounded,
                  activo: _puedeIrIzquierda,
                  alPresionar: _scrollIzquierda,
                ),
                const SizedBox(width: 8),
                _BotonScroll(
                  icono: Icons.arrow_forward_ios_rounded,
                  activo: _puedeIrDerecha,
                  alPresionar: _scrollDerecha,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: altoCarta,
          child: ListView.builder(
            controller: _controladorScroll,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: padding),
            itemCount: widget.items.length,
            itemBuilder: (context, i) {
              return ProductosCarta(
                titulo: widget.items[i]['titulo'],
                tituloIngles: widget.items[i]['tituloIngles'],
                tituloOriginal: widget.items[i]['tituloOriginal'],
                genero: widget.items[i]['genero'],
                tipo: widget.items[i]['tipo'],
                puntuacion: widget.items[i]['puntuacion'].toDouble(),
                urlImagen: widget.items[i]['img'],
                anchoCarta: anchoCarta,
              );
            },
          ),
        ),
        if (widget.esWeb) ...[
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: _BarraProgreso(controladorScroll: _controladorScroll),
          ),
        ],
      ],
    );
  }
}

class _BotonScroll extends StatelessWidget {
  final IconData icono;
  final bool activo;
  final VoidCallback alPresionar;

  const _BotonScroll({
    required this.icono,
    required this.activo,
    required this.alPresionar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: activo ? alPresionar : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: activo ? Coloresapp.colorPrimario : Coloresapp.colorFondo,
          borderRadius: BorderRadius.circular(10),
          boxShadow: activo
              ? [BoxShadow(
                  color: Coloresapp.colorPrimario.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )]
              : [],
        ),
        child: Icon(
          icono,
          size: 16,
          color: activo ? Coloresapp.colorBlanco : Coloresapp.colorTextoFlojo,
        ),
      ),
    );
  }
}

class _BarraProgreso extends StatefulWidget {
  final ScrollController controladorScroll;

  const _BarraProgreso({required this.controladorScroll});

  @override
  State<_BarraProgreso> createState() => _BarraProgresoState();
}

class _BarraProgresoState extends State<_BarraProgreso> {
  double _progreso = 0.0;

  @override
  void initState() {
    super.initState();
    widget.controladorScroll.addListener(_actualizarProgreso);
  }

  @override
  void dispose() {
    widget.controladorScroll.removeListener(_actualizarProgreso);
    super.dispose();
  }

  void _actualizarProgreso() {
    if (widget.controladorScroll.position.maxScrollExtent > 0) {
      setState(() {
        _progreso = widget.controladorScroll.offset /
            widget.controladorScroll.position.maxScrollExtent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double anchoBarra = constraints.maxWidth;
        final double anchoIndicador = (anchoBarra * 0.25).clamp(60.0, anchoBarra);

        return Container(
          height: 4,
          width: anchoBarra,
          decoration: BoxDecoration(
            color: Coloresapp.colorTextoFlojo.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 100),
                left: _progreso * (anchoBarra - anchoIndicador),
                child: Container(
                  height: 4,
                  width: anchoIndicador,
                  decoration: BoxDecoration(
                    color: Coloresapp.colorPrimario,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}