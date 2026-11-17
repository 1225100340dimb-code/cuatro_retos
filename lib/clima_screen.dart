import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app_colors.dart';
import 'reto_widgets.dart';

class ClimaPage extends StatefulWidget {
  const ClimaPage({super.key});

  @override
  State<ClimaPage> createState() => _ClimaPageState();
}

class _ClimaPageState extends State<ClimaPage> {
  final TextEditingController _apiController = TextEditingController();
  final TextEditingController _ciudadController =
      TextEditingController(text: 'Dolores Hidalgo');
  bool _cargando = false;
  Map<String, dynamic>? _clima;
  String _mensaje = 'Ingresa tu clave de WeatherAPI para consultar el clima.';

  Future<void> _consultarClima() async {
    final apiKey = _apiController.text.trim();
    final ciudad = _ciudadController.text.trim();
    if (apiKey.isEmpty || ciudad.isEmpty) {
      setState(() => _mensaje = 'Completa la clave API y la ciudad.');
      return;
    }

    setState(() {
      _cargando = true;
      _clima = null;
      _mensaje = '';
    });

    try {
      final uri = Uri.https('api.weatherapi.com', '/v1/current.json', {
        'key': apiKey,
        'q': ciudad,
        'lang': 'es',
      });
      final respuesta = await http.get(uri);
      if (respuesta.statusCode == 200) {
        setState(() => _clima = jsonDecode(respuesta.body));
      } else {
        setState(() => _mensaje =
            'No se pudo consultar el clima (${respuesta.statusCode}). Revisa la clave o el nombre de la ciudad.');
      }
    } catch (e) {
      setState(() => _mensaje = 'Error de conexión: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _apiController.dispose();
    _ciudadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ubicacion = _clima?['location'];
    final actual = _clima?['current'];
    final condicion = actual?['condition'];

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
          controller: _apiController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Clave API de WeatherAPI',
            prefixIcon: Icon(Icons.key),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _ciudadController,
          decoration: const InputDecoration(
            labelText: 'Ciudad',
            prefixIcon: Icon(Icons.location_city),
          ),
          onSubmitted: (_) => _consultarClima(),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _cargando ? null : _consultarClima,
          icon: const Icon(Icons.wb_sunny_outlined),
          label: const Text('Consultar clima'),
        ),
        const SizedBox(height: 16),
        if (_cargando) const Center(child: CircularProgressIndicator()),
        if (_mensaje.isNotEmpty) MensajeEstado(texto: _mensaje),
        if (_clima != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Text(
                    '${ubicacion?['name'] ?? ''}, ${ubicacion?['country'] ?? ''}',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (condicion?['icon'] != null)
                    Image.network(
                      'https:${condicion['icon']}',
                      width: 90,
                      height: 90,
                    ),
                  Text(
                    '${actual?['temp_c'] ?? '--'} °C',
                    style: const TextStyle(
                        fontSize: 42, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    condicion?['text'] ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Divider(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      DatoClima(
                        icono: Icons.water_drop_outlined,
                        titulo: 'Humedad',
                        valor: '${actual?['humidity'] ?? '--'}%',
                      ),
                      DatoClima(
                        icono: Icons.air,
                        titulo: 'Viento',
                        valor: '${actual?['wind_kph'] ?? '--'} km/h',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('Actualizado: ${actual?['last_updated'] ?? '--'}'),
                ],
              ),
            ),
          ),
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
    return Column(
      children: [
        Icon(icono, size: 26, color: colorPrincipal),
        const SizedBox(height: 5),
        Text(titulo),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
