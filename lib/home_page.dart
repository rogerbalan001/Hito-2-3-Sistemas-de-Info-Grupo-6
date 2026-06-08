import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio - EcoSpot'),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              color: Colors.green[700],
              child: Column(
                children: [
                  const Text('Viaja Más, Gasta Menos', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('Encuentra alojamientos económicos y sostenibles.', style: TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/search'),
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar Ahora'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.green[800]),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('¿Cómo Funciona?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const ListTile(leading: Icon(Icons.search, color: Colors.green), title: Text('1. Busca destinos')),
            const ListTile(leading: Icon(Icons.shield, color: Colors.green), title: Text('2. Reserva segura')),
            const ListTile(leading: Icon(Icons.star, color: Colors.green), title: Text('3. Disfruta y califica')),
          ],
        ),
      ),
    );
  }
}
