import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config/api_keys.dart';
import 'reto_widgets.dart';

class ClimaPage extends StatefulWidget {
  const ClimaPage({super.key});

  @override
  State<ClimaPage> createState() => _ClimaPageState();
}

class _ClimaPageState extends State<ClimaPage> {
  final TextEditingController _ciudadController =
      TextEditingController(text: 'Dolores Hidalgo');
  bool _cargando = false;
  Map<String, dynamic>? _clima;
  String _mensaje = '';

  @override
  void initState() {
    super.initState();
    _consultarClima();
  }

  Future<void> _consultarClima() async {
    final ciudad = _ciudadController.text.trim();
    if (ciudad.isEmpty) {
      setState(() => _mensaje = 'Escribe el nombre de una ciudad.');
      return;
    }
    FocusScope.of(context).unfocus();

    setState(() {
      _cargando = true;
      _clima = null;
      _mensaje = '';
    });

    try {
      final uri = Uri.https('api.weatherapi.com', '/v1/current.json', {
        'key': ApiKeys.weather,
        'q': ciudad,
        'lang': 'es',
      });
      final respuesta = await http.get(uri);
      if (!mounted) return;
      if (respuesta.statusCode == 200) {
        setState(() =>
            _clima = jsonDecode(utf8.decode(respuesta.bodyBytes)));
      } else {
        setState(() => _mensaje =
            'No se pudo consultar el clima (${respuesta.statusCode}). Revisa el nombre de la ciudad.');
      }
    } catch (e) {
      if (mounted) setState(() => _mensaje = 'Error de conexión: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _ciudadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ubicacion = _clima?['location'];
    final actual = _clima?['current'];
    final condicion = actual?['condition'];
    final esDia = (actual?['is_day'] ?? 1) == 1;
    final colores = esDia
        ? [const Color(0xFF4FA3F7), const Color(0xFF5B5BD6)]
        : [const Color(0xFF1E2A5A), const Color(0xFF3B2F7A)];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const RetoEncabezado(
          numero: 'RETO 3 · OPCIONAL',
          titulo: 'Clima minimalista',
          descripcion:
              'Consulta la temperatura y las condiciones actuales de cualquier ciudad con WeatherAPI.',
          icono: Icons.cloud,
        ),
        TextField(
          controller: _ciudadController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: 'Ciudad',
            prefixIcon: const Icon(Icons.location_city),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: _cargando ? null : _consultarClima,
            ),
          ),
          onSubmitted: (_) => _consultarClima(),
        ),
        const SizedBox(height: 16),
        if (_cargando)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (_mensaje.isNotEmpty)
          MensajeEstado(
            texto: _mensaje,
            icono: Icons.cloud_off,
            alReintentar: _consultarClima,
          ),
        if (_clima != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colores,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Text(
                  '${ubicacion?['name'] ?? ''}, ${ubicacion?['country'] ?? ''}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (condicion?['icon'] != null)
                      Image.network(
                        'https:${(condicion['icon'] as String).replaceFirst('64x64', '128x128')}',
                        width: 90,
                        height: 90,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.wb_cloudy,
                            size: 64,
                            color: Colors.white),
                      ),
                    Text(
                      '${(actual?['temp_c'] as num?)?.round() ?? '--'}°',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 68,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
                Text(
                  condicion?['text'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sensación térmica ${(actual?['feelslike_c'] as num?)?.round() ?? '--'}°',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              DatoClima(
                icono: Icons.water_drop_outlined,
                titulo: 'Humedad',
                valor: '${actual?['humidity'] ?? '--'}%',
              ),
              const SizedBox(width: 10),
              DatoClima(
                icono: Icons.air,
                titulo: 'Viento',
                valor: '${(actual?['wind_kph'] as num?)?.round() ?? '--'} km/h',
              ),
              const SizedBox(width: 10),
              DatoClima(
                icono: Icons.wb_sunny_outlined,
                titulo: 'UV',
                valor: '${(actual?['uv'] as num?)?.round() ?? '--'}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Actualizado: ${actual?['last_updated'] ?? '--'}',
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ],
    );
  }
}

class DatoClima extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const DatoClima({
    super.key,
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: esquema.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icono, size: 26, color: esquema.primary),
            const SizedBox(height: 6),
            Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(titulo,
                style: TextStyle(
                    fontSize: 12, color: esquema.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
