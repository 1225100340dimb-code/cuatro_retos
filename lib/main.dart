import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'peliculas_screen.dart';
import 'gatos_screen.dart';
import 'clima_screen.dart';
import 'cripto_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cuatro retos Flutter',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: colorPrincipal),
        scaffoldBackgroundColor: colorFondo,
        appBarTheme: const AppBarTheme(
          backgroundColor: colorFondo,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      ),
      home: const InicioPage(),
    );
  }
}

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int _indice = 0;

  final List<Widget> _pantallas = const [
    PeliculasPage(),
    GatosPage(),
    ClimaPage(),
    CriptoPage(),
  ];

  final List<String> _titulos = [
    'Películas',
    'Memes de gatos',
    'Clima',
    'Criptomonedas',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cuatro retos'),
            Text(
              _titulos[_indice],
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _indice, children: _pantallas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (indice) {
          setState(() {
            _indice = indice;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: 'Películas',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'Gatos',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            selectedIcon: Icon(Icons.cloud),
            label: 'Clima',
          ),
          NavigationDestination(
            icon: Icon(Icons.currency_bitcoin),
            label: 'Cripto',
          ),
        ],
      ),
    );
  }
}
