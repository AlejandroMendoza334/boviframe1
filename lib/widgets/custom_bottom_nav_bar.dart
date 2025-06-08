import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/main');
            break;
          case 1:
            Navigator.pushNamed(context, '/consulta');
            break;
          case 2:
            Navigator.pushNamed(context, '/epmuras');
            break;
          case 3:
            Navigator.pushNamed(context, '/index');
            break;
          case 4:
            Navigator.pushNamed(context, '/settings');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Menu'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'EPMURAS'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Índices'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Más'),
      ],
    );
  }
}
