import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const EcoHuertaApp());
}

class EcoHuertaApp extends StatelessWidget {
  const EcoHuertaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoHuerta',
      debugShowCheckedModeBanner: false,
      home: const CatalogoScreen(),
    );
  }
}

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {

  void agregarAlCarrito(Map producto) {
    
    setState(() {
      carrito.add(producto);
      total += double.parse(producto['precio']);
    });
  }


  List carrito = [];
  double total = 0;
  List productos = [];

  int pagina = 1;
  bool cargando = false;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  // 🔥 ESTA es la función importante
  Future<void> cargarProductos() async {
    
    if (cargando) return;
    cargando = true;

    final url = Uri.parse(
    'https://ecohuerta-app.onrender.com/productos?page=$pagina');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);

      if (!body.trim().startsWith('[')) {
        print("ERROR: respuesta no es JSON");
        print(body);
        cargando = false;
        return;
      }

      final data = json.decode(body);

      List lista = data;

      List productosDetallados = lista;

      setState(() {
        productos.addAll(productosDetallados);
      });

      cargando = false;

      } else {
        print("ERROR STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");

        cargando = false;
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vivero EcoHuerta 🌱")),
      body: productos.isEmpty
          ? const Center(child: Text("Cargando o error..."))
          : ListView.builder(
              itemCount: productos.length + 1,
              itemBuilder: (context, index) {

                if (index == productos.length) {
                  return ElevatedButton(
                    onPressed: cargando
                        ? null
                        : () {
                            pagina++;
                            cargarProductos();
                          },
                    child: cargando
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(),
                          )
                        : const Text("Cargar más"),
                  );
                }

                final producto = productos[index];

                String nombre = producto['nombre'] ?? 'Sin nombre';

                String imagenUrl = producto['id_imagen'] != null
                    ? "https://ecohuerta.ar/ecotienda/api/images/products/${producto['id']}/${producto['id_imagen']}"
                    : "https://picsum.photos/50";

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.network(
                      imagenUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                    ),
                    title: Text(nombre),
                    subtitle: Text(
                      "Precio: \$${double.parse(producto['precio']).toStringAsFixed(0)}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () {
                        agregarAlCarrito(producto);
                      },
                    ),
                  ),
                );
              },
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(15),
          color: Colors.green,
          child: Text(
            "Total: \$${total.toStringAsFixed(0)}",
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        );
  }
}