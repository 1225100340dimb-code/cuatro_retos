import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app_colors.dart';
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

  Future<void> _consultarPrecios() async {
    setState(() {
      _cargando = true;
      _mensaje = '';
    });

    try {
      final uri = Uri.https('api.coingecko.com', '/api/v3/simple/price', {
        'ids': 'bitcoin,ethereum,solana',
        'vs_currencies': 'usd',
      });
      final respuesta = await http.get(uri);
      if (respuesta.statusCode == 200) {
        setState(() => _precios = jsonDecode(respuesta.body));
      } else {
        setState(() => _mensaje =
            'No se pudieron obtener los precios (${respuesta.statusCode}). Inténtalo más tarde.');
      }
    } catch (e) {
      setState(() => _mensaje = 'Error de conexión: $e');
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
        if (_cargando) const Center(child: CircularProgressIndicator()),
        if (_mensaje.isNotEmpty) MensajeEstado(texto: _mensaje),
        if (monto == null || monto < 0)
          const MensajeEstado(
              texto: 'Escribe un monto válido, por ejemplo 100 o 25.50.'),
        ..._nombres.entries.map((cripto) {
          final precio = (_precios[cripto.key]?['usd'] as num?)?.toDouble();
          final cantidad = precio != null && monto != null && monto >= 0
              ? monto / precio
              : null;
          return Card(
            margin: const EdgeInsets.only(top: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorPrincipal.withValues(alpha: 0.12),
                    child: Text(cripto.value[0],
                        style: const TextStyle(
                            color: colorPrincipal,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cripto.value,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(precio == null
                            ? 'Precio no disponible'
                            : '1 ${cripto.value} = \$${precio.toStringAsFixed(2)} USD'),
                        if (cantidad != null)
                          Text(
                            'Con \$${monto?.toStringAsFixed(2)} obtendrías ${cantidad.toStringAsFixed(8)}',
                            style: const TextStyle(color: colorPrincipal),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        const Text(
          'Los precios cambian constantemente. Este cálculo es informativo y no incluye comisiones.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
