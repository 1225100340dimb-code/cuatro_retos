import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'reto_widgets.dart';

class CriptoPage extends StatefulWidget {
  const CriptoPage({super.key});

  @override
  State<CriptoPage> createState() => _CriptoPageState();
}

class _CriptoPageState extends State<CriptoPage> {
  final TextEditingController _montoController =
      TextEditingController(text: '100');
  bool _cargando = false;
  String _mensaje = '';
  Map<String, dynamic> _precios = {};

  final Map<String, String> _nombres = {
    'bitcoin': 'Bitcoin',
    'ethereum': 'Ethereum',
    'solana': 'Solana',
  };

  final Map<String, Color> _colores = {
    'bitcoin': const Color(0xFFF7931A),
    'ethereum': const Color(0xFF627EEA),
    'solana': const Color(0xFF14C48A),
  };

  Future<void> _consultarPrecios() async {
    setState(() {
      _cargando = true;
      _mensaje = '';
    });

    try {
      final uri = Uri.https('api.coingecko.com', '/api/v3/simple/price', {
        'ids': 'bitcoin,ethereum,solana',
        'vs_currencies': 'usd',
        'include_24hr_change': 'true',
      });
      final respuesta = await http.get(uri);
      if (!mounted) return;
      if (respuesta.statusCode == 200) {
        setState(() => _precios = jsonDecode(respuesta.body));
      } else {
        setState(() => _mensaje =
            'No se pudieron obtener los precios (${respuesta.statusCode}). Inténtalo más tarde.');
      }
    } catch (e) {
      if (mounted) setState(() => _mensaje = 'Error de conexión: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  double? _obtenerMonto() {
    return double.tryParse(_montoController.text.trim().replaceAll(',', '.'));
  }

  @override
  void initState() {
    super.initState();
    _consultarPrecios();
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final monto = _obtenerMonto();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const RetoEncabezado(
          numero: 'RETO 4',
          titulo: 'Convertidor de criptomonedas',
          descripcion:
              'Consulta precios en dólares y calcula cuántas fracciones de criptomoneda puedes obtener.',
          icono: Icons.currency_exchange,
        ),
        TextField(
          controller: _montoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Monto que tienes en USD',
            prefixText: '\$ ',
            prefixIcon: Icon(Icons.attach_money),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _cargando ? null : _consultarPrecios,
          icon: const Icon(Icons.refresh),
          label: const Text('Actualizar precios'),
        ),
        const SizedBox(height: 8),
        if (_cargando)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (_mensaje.isNotEmpty)
          MensajeEstado(
            texto: _mensaje,
            icono: Icons.cloud_off,
            alReintentar: _consultarPrecios,
          ),
        if (monto == null || monto < 0)
          const MensajeEstado(
              texto: 'Escribe un monto válido, por ejemplo 100 o 25.50.'),
        ..._nombres.entries.map((cripto) {
          final datos = _precios[cripto.key];
          final precio = (datos?['usd'] as num?)?.toDouble();
          final cambio = (datos?['usd_24h_change'] as num?)?.toDouble();
          final cantidad = precio != null && monto != null && monto >= 0
              ? monto / precio
              : null;
          final color = _colores[cripto.key]!;
          final sube = (cambio ?? 0) >= 0;
          return Card(
            margin: const EdgeInsets.only(top: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: color.withValues(alpha: 0.18),
                    child: Text(cripto.value[0],
                        style: TextStyle(
                            color: color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(cripto.value,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                            if (cambio != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    sube
                                        ? Icons.arrow_drop_up
                                        : Icons.arrow_drop_down,
                                    color: sube
                                        ? Colors.green
                                        : Colors.redAccent,
                                  ),
                                  Text(
                                    '${cambio.abs().toStringAsFixed(2)}%',
                                    style: TextStyle(
                                        color: sube
                                            ? Colors.green
                                            : Colors.redAccent,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        Text(
                          precio == null
                              ? 'Precio no disponible'
                              : '1 ${cripto.value} = \$${formatoNumero(precio)} USD',
                          style:
                              TextStyle(color: esquema.onSurfaceVariant),
                        ),
                        if (cantidad != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Con \$${formatoNumero(monto!)} obtendrías ${cantidad.toStringAsFixed(8)}',
                            style: TextStyle(
                                color: esquema.primary,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 14),
        Text(
          'Los precios cambian constantemente. Este cálculo es informativo y no incluye comisiones.',
          style: TextStyle(fontSize: 12, color: esquema.onSurfaceVariant),
        ),
      ],
    );
  }
}
