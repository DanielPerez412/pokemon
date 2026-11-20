import 'dart:math';

import 'package:flutter/material.dart';

import 'widgets/colors.dart';

void main() => runApp(const PokefoodApp());

class PokefoodApp extends StatelessWidget {
  const PokefoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokéfood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colores.rojo),
        scaffoldBackgroundColor: Colores.fondo,
      ),
      home: const Principal(),
    );
  }
}

// =====================================================================
//  DATOS DE EJEMPLO (no hay base de datos: esta lista es el menú)
// =====================================================================
const List<Plato> platos = [
  Plato(id: 1, pokemon: 'Bulbasaur', tipo: 'Planta', nombre: 'Ensalada del Bosque de Bulbasaur', descripcion: 'Hojas verdes, aguacate, quinoa y vinagreta de hierbas.', precio: 19700),
  Plato(id: 4, pokemon: 'Charmander', tipo: 'Fuego', nombre: 'Parrillada Ardiente de Charmander', descripcion: 'Carne a la brasa con salsa de ají habanero y papas rústicas.', precio: 19800),
  Plato(id: 7, pokemon: 'Squirtle', tipo: 'Agua', nombre: 'Ceviche Oceánico de Squirtle', descripcion: 'Pescado fresco curado en limón con cebolla morada y cilantro.', precio: 19800),
  Plato(id: 25, pokemon: 'Pikachu', tipo: 'Eléctrico', nombre: 'Hamburguesa Voltaje de Pikachu', descripcion: 'Hamburguesa doble con queso amarillo, chips crocantes y salsa eléctrica.', precio: 20000),
  Plato(id: 39, pokemon: 'Jigglypuff', tipo: 'Hada', nombre: 'Cupcake Encantado de Jigglypuff', descripcion: 'Cupcake de vainilla con crema rosa y glaseado de frutas.', precio: 17500),
  Plato(id: 92, pokemon: 'Gastly', tipo: 'Fantasma', nombre: 'Postre Fantasma de Gastly', descripcion: 'Merengón de fresa con crema chantilly y gelatina de uva.', precio: 18000),
  Plato(id: 131, pokemon: 'Lapras', tipo: 'Hielo', nombre: 'Copa Helada de Lapras', descripcion: 'Helado artesanal de vainilla con frutos azules y crujiente de menta.', precio: 24000),
  Plato(id: 23, pokemon: 'Ekans', tipo: 'Veneno', nombre: 'Tacos Tóxicos de Ekans', descripcion: 'Tortillas de maíz con cerdo adobado, piña y salsa morada.', precio: 18500),
  Plato(id: 63, pokemon: 'Abra', tipo: 'Psíquico', nombre: 'Sushi Mental de Abra', descripcion: 'Rollos de arroz con salmón, pepino y salsa de maracuyá.', precio: 21000),
  Plato(id: 66, pokemon: 'Machop', tipo: 'Lucha', nombre: 'Bowl Proteico de Machop', descripcion: 'Arroz integral, pechuga a la plancha, huevo y frijoles negros.', precio: 22000),
  Plato(id: 147, pokemon: 'Dratini', tipo: 'Dragón', nombre: 'Costillas del Dragón de Dratini', descripcion: 'Costillas BBQ ahumadas lentamente con maíz asado.', precio: 26000),
  Plato(id: 143, pokemon: 'Snorlax', tipo: 'Normal', nombre: 'Sándwich Clásico de Snorlax', descripcion: 'Pan artesanal, pollo desmechado, queso y vegetales frescos.', precio: 28000),
];

// =====================================================================
//  CARRITO (vive solo en la memoria de la app)
// =====================================================================
class ItemCarrito {
  final Plato plato;
  final int cantidad;
  const ItemCarrito(this.plato, this.cantidad);
  int get subtotal => plato.precio * cantidad;
}

// Una "caja" que avisa a las pantallas cuando su contenido cambia.
final ValueNotifier<List<ItemCarrito>> carrito = ValueNotifier([]);

void agregarAlCarrito(Plato plato, [int cantidad = 1]) {
  final lista = List<ItemCarrito>.from(carrito.value);
  final i = lista.indexWhere((e) => e.plato.id == plato.id);
  if (i >= 0) {
    lista[i] = ItemCarrito(plato, lista[i].cantidad + cantidad);
  } else {
    lista.add(ItemCarrito(plato, cantidad));
  }
  carrito.value = lista;
}

void quitarDelCarrito(int platoId) {
  carrito.value = carrito.value.where((e) => e.plato.id != platoId).toList();
}

int totalCarrito() => carrito.value.fold(0, (suma, e) => suma + e.subtotal);

// Agrega al carrito y muestra un aviso abajo.
void agregarYAvisar(BuildContext context, Plato plato, [int cantidad = 1]) {
  agregarAlCarrito(plato, cantidad);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text('${plato.nombre} agregado al carrito'),
      duration: const Duration(seconds: 2),
    ));
}

// =====================================================================
//  NAVEGACIÓN (barra de abajo con 3 pestañas)
// =====================================================================
class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  int pestana = 0;

  final List<Widget> paginas = const [
    MenuPantalla(),
    SorpresaPantalla(),
    CarritoPantalla(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: pestana, children: paginas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: pestana,
        onDestinationSelected: (i) => setState(() => pestana = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Menú'),
          const NavigationDestination(icon: Icon(Icons.casino), label: 'Sorpresa'),
          NavigationDestination(
            icon: ValueListenableBuilder<List<ItemCarrito>>(
              valueListenable: carrito,
              builder: (context, items, _) => Badge(
                isLabelVisible: items.isNotEmpty,
                label: Text('${items.length}'),
                child: const Icon(Icons.shopping_cart),
              ),
            ),
            label: 'Carrito',
          ),
        ],
      ),
    );
  }
}

// =====================================================================
//  PANTALLA 1: MENÚ
// =====================================================================
class MenuPantalla extends StatefulWidget {
  const MenuPantalla({super.key});

  @override
  State<MenuPantalla> createState() => _MenuPantallaState();
}

class _MenuPantallaState extends State<MenuPantalla> {
  String tipoElegido = 'Todos';

  @override
  Widget build(BuildContext context) {
    final tipos = ['Todos', ...platos.map((p) => p.tipo).toSet()];
    final visibles = tipoElegido == 'Todos'
        ? platos
        : platos.where((p) => p.tipo == tipoElegido).toList();

    return Scaffold(
      appBar: barra('Menú Pokéfood'),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              children: [
                for (final t in tipos)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChipTipo(
                      texto: t,
                      seleccionado: t == tipoElegido,
                      onTap: () => setState(() => tipoElegido = t),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.78,
              ),
              itemCount: visibles.length,
              itemBuilder: (context, i) {
                final p = visibles[i];
                return TarjetaPlato(
                  plato: p,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetallePantalla(plato: p)),
                  ),
                  onAgregar: () => agregarYAvisar(context, p),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
//  PANTALLA 2: DETALLE
// =====================================================================
class DetallePantalla extends StatefulWidget {
  const DetallePantalla({super.key, required this.plato});
  final Plato plato;

  @override
  State<DetallePantalla> createState() => _DetallePantallaState();
}

class _DetallePantallaState extends State<DetallePantalla> {
  int cantidad = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.plato;
    final color = colorDeTipo(p.tipo);

    return Scaffold(
      appBar: barra(p.pokemon),
      body: ListView(
        children: [
          Container(
            height: 260,
            color: color.withAlpha(60),
            padding: const EdgeInsets.all(16),
            child: ImagenPokemon(url: p.imagen),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.nombre,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ChipTipo(texto: p.tipo),
                const SizedBox(height: 12),
                Text(p.descripcion, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 16),
                Text(pesos(p.precio),
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w900, color: Colores.rojo)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: cantidad > 1 ? () => setState(() => cantidad--) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$cantidad',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () => setState(() => cantidad++),
                icon: const Icon(Icons.add_circle_outline),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BotonPrincipal(
                  texto: 'Agregar · ${pesos(p.precio * cantidad)}',
                  icono: Icons.add_shopping_cart,
                  onPressed: () {
                    agregarYAvisar(context, p, cantidad);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
//  PANTALLA 3: SORPRESA (plato al azar)
// =====================================================================
class SorpresaPantalla extends StatefulWidget {
  const SorpresaPantalla({super.key});

  @override
  State<SorpresaPantalla> createState() => _SorpresaPantallaState();
}

class _SorpresaPantallaState extends State<SorpresaPantalla> {
  Plato? plato;
  final azar = Random();

  void sortear() {
    setState(() {
      plato = platos[azar.nextInt(platos.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = plato;
    return Scaffold(
      appBar: barra('Plato sorpresa'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('¿No sabes qué pedir?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            BotonPrincipal(
              texto: p == null ? '¡Sorpréndeme!' : 'Otro distinto',
              icono: Icons.casino,
              onPressed: sortear,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: p == null
                  ? const Center(
                      child: Text('Presiona el botón para descubrir tu plato',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colores.gris)),
                    )
                  : _Resultado(plato: p),
            ),
          ],
        ),
      ),
    );
  }
}

class _Resultado extends StatelessWidget {
  const _Resultado({required this.plato});
  final Plato plato;

  @override
  Widget build(BuildContext context) {
    final color = colorDeTipo(plato.tipo);
    return ListView(
      children: [
        Container(
          height: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withAlpha(60),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ImagenPokemon(url: plato.imagen),
        ),
        const SizedBox(height: 12),
        Text(plato.nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Center(child: ChipTipo(texto: plato.tipo)),
        const SizedBox(height: 8),
        Text(pesos(plato.precio),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.w900, color: Colores.rojo)),
        const SizedBox(height: 16),
        BotonPrincipal(
          texto: 'Agregar al carrito',
          icono: Icons.add_shopping_cart,
          onPressed: () => agregarYAvisar(context, plato),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetallePantalla(plato: plato)),
          ),
          child: const Text('Ver detalle'),
        ),
      ],
    );
  }
}

// =====================================================================
//  PANTALLA 4: CARRITO
// =====================================================================
class CarritoPantalla extends StatelessWidget {
  const CarritoPantalla({super.key});

  void _pedir(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Pedido enviado!'),
        content: Text(
            'Total: ${pesos(totalCarrito())}\n(Es una simulación: todavía no hay base de datos.)'),
        actions: [
          TextButton(
            onPressed: () {
              carrito.value = [];
              Navigator.pop(ctx);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barra('Mi carrito'),
      body: ValueListenableBuilder<List<ItemCarrito>>(
        valueListenable: carrito,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const Center(
              child: Text('Tu carrito está vacío',
                  style: TextStyle(fontSize: 16, color: Colores.gris)),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colores.borde),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: ImagenPokemon(url: item.plato.imagen),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.plato.nombre,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('${item.cantidad} × ${pesos(item.plato.precio)}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colores.gris)),
                              ],
                            ),
                          ),
                          Text(pesos(item.subtotal),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, color: Colores.rojo)),
                          IconButton(
                            tooltip: 'Quitar',
                            onPressed: () => quitarDelCarrito(item.plato.id),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(pesos(totalCarrito()),
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colores.rojo)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    BotonPrincipal(
                      texto: 'Hacer pedido',
                      icono: Icons.delivery_dining,
                      onPressed: () => _pedir(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
