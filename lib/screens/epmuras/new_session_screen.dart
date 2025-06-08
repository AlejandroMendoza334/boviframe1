import 'package:flutter/material.dart';
import '../../widgets/custom_app_scaffold.dart';

class NewSessionScreen extends StatelessWidget {
  final String? sessionId;

  const NewSessionScreen({Key? key, required this.sessionId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomAppScaffold(
      currentIndex: 2, // EPMURAS
      title: 'Nueva Sesión',
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
        child: Column(
          children: [
            _buildSectionButton(
              context,
              label: 'Datos Productor',
              onTap: () => Navigator.pushNamed(
                context,
                '/datos_productor',
                arguments: {'sessionId': sessionId},
              ),
              highlighted: true, // botón destacado
            ),
            const SizedBox(height: 16),
            _buildSectionButton(
              context,
              label: 'Evaluación',
              onTap: () => Navigator.pushNamed(
                context,
                '/animal_evaluation',
                arguments: {'sessionId': sessionId},
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionButton(
              context,
              label: 'Reporte (Sin Uso)',
              onTap: () => Navigator.pushNamed(
                context,
                '/report_screen',
                arguments: {'sessionId': sessionId},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    // Colores inspirados en tu diseño
    final Color bgColor = highlighted
        ? const Color(0xFFD0E8FF)  // un celeste más intenso para el destacado
        : const Color(0xFFEAF6FF); // un celeste muy suave para los demás
    final Color textColor = const Color(0xFF007AFF); // azul vivo

    return SizedBox(
      width: double.infinity,
      height: 50, // altura similar a tu captura
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0, // sin sombra
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25), // bordes muy redondeados
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
