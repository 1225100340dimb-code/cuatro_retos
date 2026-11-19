import 'package:flutter/material.dart';

/// Banner superior de cada reto.
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
    final esquema = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [esquema.primary, esquema.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Icon(icono, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(numero,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1)),
                const SizedBox(height: 3),
                Text(titulo,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(descripcion,
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mensaje de estado (error, vacío, ayuda) con icono y reintento opcional.
class MensajeEstado extends StatelessWidget {
  final String texto;
  final IconData icono;
  final VoidCallback? alReintentar;

  const MensajeEstado({
    super.key,
    required this.texto,
    this.icono = Icons.info_outline,
    this.alReintentar,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: esquema.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icono, size: 32, color: esquema.outline),
          const SizedBox(height: 8),
          Text(texto, textAlign: TextAlign.center),
          if (alReintentar != null) ...[
            const SizedBox(height: 10),
            FilledButton.tonal(
              onPressed: alReintentar,
              child: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Da formato numérico con separador de miles: 67432.1 -> 67,432.10
String formatoNumero(double valor, {int decimales = 2}) {
  final partes = valor.toStringAsFixed(decimales).split('.');
  final entero = partes[0]
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return decimales > 0 ? '$entero.${partes[1]}' : entero;
}
