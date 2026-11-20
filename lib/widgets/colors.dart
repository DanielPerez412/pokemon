import 'package:flutter/material.dart';

// ---------- Colores ----------
class Colores {
  static const Color rojo = Color(0xFFE3350D);
  static const Color amarillo = Color(0xFFFFCB05);
  static const Color texto = Color(0xFF1F2430);
  static const Color gris = Color(0xFF6B7280);
  static const Color fondo = Color(0xFFFFF8F0);
  static const Color borde = Color(0xFFEADFD3);
}

const Map<String, Color> coloresDeTipo = {
  'Planta': Color(0xFF7AC74C),
  'Fuego': Color(0xFFEE8130),
  'Agua': Color(0xFF6390F0),
  'Eléctrico': Color(0xFFF7D02C),
  'Hada': Color(0xFFD685AD),
  'Fantasma': Color(0xFF735797),
  'Hielo': Color(0xFF96D9D6),
  'Veneno': Color(0xFFA33EA1),
  'Psíquico': Color(0xFFF95587),
  'Lucha': Color(0xFFC22E28),
  'Dragón': Color(0xFF6F35FC),
  'Normal': Color(0xFFA8A77A),
};

Color colorDeTipo(String tipo) => coloresDeTipo[tipo] ?? Colores.gris;

// ---------- Modelo ----------
class Plato {
  final int id; // número del Pokémon (sirve para la imagen)
  final String nombre;
  final String pokemon;
  final String tipo;
  final String descripcion;
  final int precio;

  const Plato({
    required this.id,
    required this.nombre,
    required this.pokemon,
    required this.tipo,
    required this.descripcion,
    required this.precio,
  });

  String get imagen =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}

// Convierte 25400 en $25.400
String pesos(int valor) {
  final texto = valor.toString();
  final sb = StringBuffer();
  for (var i = 0; i < texto.length; i++) {
    final faltan = texto.length - i;
    sb.write(texto[i]);
    if (faltan > 1 && faltan % 3 == 1) sb.write('.');
  }
  return '\$${sb.toString()}';
}

// ---------- Widgets ----------

// Barra roja de arriba con el título de cada pantalla.
AppBar barra(String titulo) {
  return AppBar(
    title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
    centerTitle: true,
    backgroundColor: Colores.rojo,
    foregroundColor: Colors.white,
  );
}

// Imagen de internet; si falla, muestra un icono.
class ImagenPokemon extends StatelessWidget {
  const ImagenPokemon({super.key, required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (c, e, s) =>
          const Center(child: Icon(Icons.fastfood, size: 48, color: Colores.gris)),
    );
  }
}

// Etiqueta de color con el tipo. También sirve como filtro.
class ChipTipo extends StatelessWidget {
  const ChipTipo({super.key, required this.texto, this.seleccionado = true, this.onTap});
  final String texto;
  final bool seleccionado;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = texto == 'Todos' ? Colores.texto : colorDeTipo(texto);
    final textoSobreColor =
        color.computeLuminance() > 0.5 ? Colores.texto : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: seleccionado ? color : Colores.borde),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: seleccionado ? textoSobreColor : Colores.texto,
          ),
        ),
      ),
    );
  }
}

// Botón grande, rojo y redondeado.
class BotonPrincipal extends StatelessWidget {
  const BotonPrincipal({super.key, required this.texto, required this.onPressed, this.icono});
  final String texto;
  final VoidCallback? onPressed;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Colores.rojo,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icono != null) ...[Icon(icono), const SizedBox(width: 8)],
            Flexible(
              child: Text(texto,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// Tarjeta de un plato para la cuadrícula del menú.
class TarjetaPlato extends StatelessWidget {
  const TarjetaPlato({
    super.key,
    required this.plato,
    required this.onTap,
    required this.onAgregar,
  });
  final Plato plato;
  final VoidCallback onTap;
  final VoidCallback onAgregar;

  @override
  Widget build(BuildContext context) {
    final color = colorDeTipo(plato.tipo);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colores.borde),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: color.withAlpha(50),
                padding: const EdgeInsets.all(8),
                child: ImagenPokemon(url: plato.imagen),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Text(
                plato.nombre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 2, 4, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      pesos(plato.precio),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, color: Colores.rojo),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Agregar al carrito',
                    onPressed: onAgregar,
                    icon: const Icon(Icons.add_circle, color: Colores.rojo),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
