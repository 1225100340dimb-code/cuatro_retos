import 'package:flutter/material.dart';

import 'app_colors.dart';

class RetoEncabezado extends StatelessWidget {
  final String numero;
  final String titulo;
  final String descripcion;
  final IconData icono;

  const RetoEncabezado({
    super.key,
    required this.numero,
    required this.titulo,
    required this.descripcion,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: colorPrincipal.withValues(alpha: 0.12),
              child: Icon(icono, color: colorPrincipal, size: 27),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(numero,
                      style: const TextStyle(
                          color: colorPrincipal,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  const SizedBox(height: 3),
                  Text(titulo,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 5),
                  Text(descripcion),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MensajeEstado extends StatelessWidget {
  final String texto;

  const MensajeEstado({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(texto, textAlign: TextAlign.center),
    );
  }
}
