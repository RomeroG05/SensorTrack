import 'package:flutter/material.dart';

/// Fila "Etiqueta ........ valor" usada en varias pantallas.
class DatoFila extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const DatoFila(this.etiqueta, this.valor, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(etiqueta),
          const Spacer(),
          Text(valor, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
