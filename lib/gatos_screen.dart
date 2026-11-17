import 'package:flutter/material.dart';

import 'reto_widgets.dart';

class GatosPage extends StatefulWidget {
  const GatosPage({super.key});

  @override
  State<GatosPage> createState() => _GatosPageState();
}

class _GatosPageState extends State<GatosPage> {
  final TextEditingController _textoController = TextEditingController();
  String _frase = 'Escribe una frase para tu meme';
  int _actualizacion = 0;
  bool _cargando = false;

  Future<void> _crearMeme() async {
    final texto = _textoController.text.trim();
    if (texto.isEmpty) {
      setState(() => _frase = 'Primero escribe una frase.');
      return;
    }
    setState(() {
      _frase = texto;
      _cargando = true;
    });
    // Cataas genera una imagen con el texto indicado en la propia URL.
    setState(() {
      _actualizacion++;
      _cargando = false;
    });
  }

  @override
  void dispose() {
    _textoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texto = Uri.encodeComponent(_frase);
    final url = 'https://cataas.com/cat/says/$texto?fontSize=40&fontColor=white&v=$_actualizacion';

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
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _cargando ? null : _crearMeme,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Crear meme'),
        ),
        const SizedBox(height: 18),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  url,
                  key: ValueKey(_actualizacion),
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
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
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_frase,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
