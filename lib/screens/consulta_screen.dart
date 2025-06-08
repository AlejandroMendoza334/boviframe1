// lib/screens/consulta_screen.dart

import 'package:flutter/material.dart';
import 'consulta_animal_screen.dart';
import 'consulta_finca_screen.dart';

class ConsultaScreen extends StatefulWidget {
  const ConsultaScreen({Key? key}) : super(key: key);

  @override
  State<ConsultaScreen> createState() => _ConsultaScreenState();
}

class _ConsultaScreenState extends State<ConsultaScreen> {
  int _currentIndex = 1;
  final List<String> _rutas = [
    '/main_menu',
    '/consulta',
    '/epmuras',
    '/index',
    '/settings',
  ];

  void _onTapNav(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    Navigator.pushReplacementNamed(context, _rutas[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'CONSULTA PÚBLICA',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ─── Botón "Consultar Animal" con logo1.png ───
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConsultaAnimalScreen(),
                  ),
                );
              },
              icon: Image.asset(
                'assets/icons/logo1.png',
                width: 24,
                height: 24,
                color: Colors.white,
              ),
              label: const Text(
                'CONSULTAR ANIMAL',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ─── Botón "Consultar Finca" con logo1.png ───
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConsultaFincaScreen(),
                  ),
                );
              },
              icon: Image.asset(
                'assets/icons/logo1.png',
                width: 24,
                height: 24,
                color: Colors.white,
              ),
              label: const Text(
                'CONSULTAR FINCA',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey[600],
        onTap: _onTapNav,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Menú',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'EPMURAS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart_outlined),
            label: 'Índices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Más',
          ),
        ],
      ),
    );
  }
}
