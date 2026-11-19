import 'package:flutter/material.dart';

import 'reto_widgets.dart';

class GatosPage extends StatefulWidget {
  const GatosPage({super.key});

  @override
  State<GatosPage> createState() => _GatosPageState();
}

class _GatosPageState extends State<GatosPage> {
  final TextEditingController _textoController = TextEditingController();
  String _frase = '¡Hola humano!';
  int _actualizacion = 0;

  final List<String> _sugerencias = [
    'Lunes otra vez',
    'Cinco minutos más',
    'Hoy sí hago ejercicio',
    'Dame de comer',
  ];

  void _crearMeme([String? sugerida]) {
    final texto = (sugerida ?? _textoController.text).trim();
    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero escribe una frase.')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _frase = texto;
      _actualizacion++;
    });
  }

  void _otroGato() => setState(() => _actualizacion++);

  @override
  void dispose() {
    _textoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final texto = Uri.encodeComponent(_frase);
    // Cataas genera una imagen con el texto indicado en la propia URL.
    final url =
        'https://cataas.com/cat/says/$texto?fontSize=40&fontColor=white&v=$_actualizacion';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const RetoEncabezado(
          numero: 'RETO 2',
          titulo: 'Generador de memes de gatos',
          descripcion:
              'Escribe una frase y Cataas la coloca sobre una fotografía aleatoria de un gato.',
          icono: Icons.pets,
        ),
        TextField(
          controller: _textoController,
          maxLength: 60,
          decoration: const InputDecoration(
            labelText: 'Frase para el meme',
            hintText: 'Ej. Cuando por fin es viernes...',
            prefixIcon: Icon(Icons.edit),
          ),
          onSubmitted: (_) => _crearMeme(),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _sugerencias
              .map((s) => ActionChip(
                    label: Text(s),
                    onPressed: () {
                      _textoController.text = s;
                      _crearMeme(s);
                    },
                  ))
              .toList(),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _crearMeme,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Crear meme'),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              onPressed: _otroGato,
              tooltip: 'Otro gato',
              icon: const Icon(Icons.shuffle),
              style: IconButton.styleFrom(minimumSize: const Size(50, 50)),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Card(
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              url,
              key: ValueKey(_actualizacion),
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progreso) {
                if (progreso == null) return child;
                return Container(
                  color: esquema.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (_, __, ___) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No se pudo cargar el gato. Revisa tu conexión e inténtalo otra vez.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
