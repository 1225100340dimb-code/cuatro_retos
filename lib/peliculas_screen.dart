import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'reto_widgets.dart';

class PeliculasPage extends StatefulWidget {
  const PeliculasPage({super.key});

  @override
  State<PeliculasPage> createState() => _PeliculasPageState();
}

class _PeliculasPageState extends State<PeliculasPage> {
  final TextEditingController _apiController = TextEditingController();
  bool _cargando = false;
  String _genero = '28';
  String _mensaje = 'Escribe tu clave de TMDB y busca películas.';
  List<dynamic> _peliculas = [];

  final Map<String, String> _generos = {
    '28': 'Acción',
    '35': 'Comedia',
    '18': 'Drama',
    '27': 'Terror',
    '10749': 'Romance',
    '878': 'Ciencia ficción',
    '16': 'Animación',
  };

  Future<void> _buscarPeliculas() async {
    final apiKey = _apiController.text.trim();
    if (apiKey.isEmpty) {
      setState(() => _mensaje = 'Ingresa tu clave de API de TMDB.');
      return;
    }

    setState(() {
      _cargando = true;
      _mensaje = '';
      _peliculas = [];
    });

    try {
      final uri = Uri.https('api.themoviedb.org', '/3/discover/movie', {
        'api_key': apiKey,
        'language': 'es-MX',
        'sort_by': 'popularity.desc',
        'with_genres': _genero,
        'include_adult': 'false',
      });
      final respuesta = await http.get(uri);
      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);
        setState(() {
          _peliculas = datos['results'] ?? [];
          _mensaje = _peliculas.isEmpty
              ? 'No se encontraron películas para este género.'
              : '';
        });
      } else {
        setState(() => _mensaje =
            'No se pudo consultar TMDB (${respuesta.statusCode}). Revisa tu API key.');
      }
    } catch (e) {
      setState(() => _mensaje = 'Ocurrió un error de conexión: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _apiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const RetoEncabezado(
          numero: 'RETO 1',
          titulo: 'Recomendador de películas',
          descripcion:
              'Elige tu estado de ánimo y descubre películas populares usando la API de TMDB.',
          icono: Icons.movie_creation_outlined,
        ),
        TextField(
          controller: _apiController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Clave API de TMDB',
            hintText: 'Pega aquí tu API key',
            prefixIcon: Icon(Icons.key),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _genero,
          decoration: const InputDecoration(labelText: '¿Qué quieres ver?'),
          items: _generos.entries
              .map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value),
                  ))
              .toList(),
          onChanged: (valor) {
            if (valor != null) setState(() => _genero = valor);
          },
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _cargando ? null : _buscarPeliculas,
          icon: const Icon(Icons.search),
          label: const Text('Buscar películas'),
        ),
        const SizedBox(height: 16),
        if (_cargando) const Center(child: CircularProgressIndicator()),
        if (_mensaje.isNotEmpty) MensajeEstado(texto: _mensaje),
        ..._peliculas.map((pelicula) {
          final titulo = pelicula['title'] ?? 'Sin título';
          final poster = pelicula['poster_path'];
          final imagen = poster == null
              ? null
              : 'https://image.tmdb.org/t/p/w500$poster';
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            clipBehavior: Clip.antiAlias,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 112,
                  height: 160,
                  child: imagen == null
                      ? const Icon(Icons.image_not_supported, size: 40)
                      : Image.network(
                          imagen,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(titulo,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 6),
                        Text('⭐ ${pelicula['vote_average'] ?? 'Sin calificación'}'),
                        const SizedBox(height: 8),
                        Text(
                          pelicula['overview']?.toString().isNotEmpty == true
                              ? pelicula['overview']
                              : 'No hay descripción disponible.',
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
