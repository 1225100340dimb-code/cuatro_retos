import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config/api_keys.dart';
import 'reto_widgets.dart';

class PeliculasPage extends StatefulWidget {
  const PeliculasPage({super.key});

  @override
  State<PeliculasPage> createState() => _PeliculasPageState();
}

class _PeliculasPageState extends State<PeliculasPage> {
  bool _cargando = false;
  String _animo = 'feliz';
  String _mensaje = '';
  List<Map<String, dynamic>> _peliculas = [];

  // Cada estado de ánimo se traduce a géneros de TMDB.
  // "|" significa "cualquiera de estos géneros".
  final Map<String, _Animo> _animos = const {
    'feliz': _Animo('😄', 'Feliz', '35|10402', 'Comedia y música'),
    'triste': _Animo('😢', 'Triste', '18', 'Drama para desahogarte'),
    'emocionado': _Animo('🤩', 'Con adrenalina', '28|12', 'Acción y aventura'),
    'romantico': _Animo('😍', 'Romántico', '10749', 'Romance'),
    'miedo': _Animo('😱', 'Con ganas de miedo', '27|53', 'Terror y suspenso'),
    'pensativo': _Animo('🤔', 'Pensativo', '878|9648', 'Ciencia ficción y misterio'),
    'relajado': _Animo('😌', 'Relajado', '16|10751|14', 'Animación, familia y fantasía'),
  };

  @override
  void initState() {
    super.initState();
    _buscarPeliculas();
  }

  Future<void> _buscarPeliculas() async {
    setState(() {
      _cargando = true;
      _mensaje = '';
      _peliculas = [];
    });

    try {
      final uri = Uri.https('api.themoviedb.org', '/3/discover/movie', {
        'api_key': ApiKeys.tmdb,
        'language': 'es-MX',
        'sort_by': 'popularity.desc',
        'with_genres': _animos[_animo]!.generos,
        'vote_count.gte': '100',
        'include_adult': 'false',
      });
      final respuesta = await http.get(uri);
      if (!mounted) return;
      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
        final lista = (datos['results'] as List? ?? [])
            .cast<Map<String, dynamic>>();
        setState(() {
          _peliculas = lista;
          _mensaje = lista.isEmpty
              ? 'No se encontraron películas para este estado de ánimo.'
              : '';
        });
      } else {
        setState(() => _mensaje =
            'No se pudo consultar TMDB (${respuesta.statusCode}). Revisa tu API key.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _mensaje = 'Ocurrió un error de conexión: $e');
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _verDetalle(Map<String, dynamic> pelicula) {
    final titulo = pelicula['title'] ?? 'Sin título';
    final fondo = pelicula['backdrop_path'];
    final resumen = pelicula['overview']?.toString() ?? '';
    final fecha = pelicula['release_date']?.toString() ?? '';
    final nota = (pelicula['vote_average'] as num?)?.toDouble();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.95,
        builder: (context, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            if (fondo != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w780$fondo',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            const SizedBox(height: 14),
            Text(titulo,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [
              if (nota != null) ...[
                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(nota.toStringAsFixed(1)),
                const SizedBox(width: 16),
              ],
              if (fecha.isNotEmpty) ...[
                const Icon(Icons.calendar_today_outlined, size: 16),
                const SizedBox(width: 4),
                Text(fecha),
              ],
            ]),
            const SizedBox(height: 14),
            Text(
              resumen.isEmpty ? 'No hay descripción disponible.' : resumen,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
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
        Text('¿Cómo te sientes hoy?',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _animos.entries
              .map((e) => ChoiceChip(
                    avatar: Text(e.value.emoji),
                    label: Text(e.value.nombre),
                    selected: _animo == e.key,
                    onSelected: _cargando
                        ? null
                        : (_) {
                            setState(() => _animo = e.key);
                            _buscarPeliculas();
                          },
                  ))
              .toList(),
        ),
        const SizedBox(height: 10),
        Text(
          'Para ese ánimo: ${_animos[_animo]!.descripcion}',
          style: TextStyle(color: esquema.onSurfaceVariant),
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
            alReintentar: _buscarPeliculas,
          ),
        ..._peliculas.map((pelicula) {
          final titulo = pelicula['title'] ?? 'Sin título';
          final poster = pelicula['poster_path'];
          final resumen = pelicula['overview']?.toString() ?? '';
          final fecha = pelicula['release_date']?.toString() ?? '';
          final anio = fecha.length >= 4 ? fecha.substring(0, 4) : '';
          final nota = (pelicula['vote_average'] as num?)?.toDouble();
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _verDetalle(pelicula),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 105,
                    height: 158,
                    child: poster == null
                        ? Container(
                            color: esquema.surfaceContainerHighest,
                            child: const Icon(Icons.image_not_supported,
                                size: 36),
                          )
                        : Image.network(
                            'https://image.tmdb.org/t/p/w342$poster',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: esquema.surfaceContainerHighest,
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titulo,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 6),
                          Row(children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 18),
                            const SizedBox(width: 3),
                            Text(nota == null
                                ? 'Sin calificación'
                                : nota.toStringAsFixed(1)),
                            if (anio.isNotEmpty) ...[
                              const SizedBox(width: 12),
                              Text(anio,
                                  style: TextStyle(
                                      color: esquema.onSurfaceVariant)),
                            ],
                          ]),
                          const SizedBox(height: 8),
                          Text(
                            resumen.isNotEmpty
                                ? resumen
                                : 'No hay descripción disponible.',
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style:
                                TextStyle(color: esquema.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _Animo {
  final String emoji;
  final String nombre;
  final String generos;
  final String descripcion;

  const _Animo(this.emoji, this.nombre, this.generos, this.descripcion);
}
