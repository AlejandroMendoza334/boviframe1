import 'package:flutter/material.dart';

class EpmurasInfographicWidget extends StatefulWidget {
  const EpmurasInfographicWidget({Key? key}) : super(key: key);

  @override
  State<EpmurasInfographicWidget> createState() => _EpmurasInfographicWidgetState();
}

class _EpmurasInfographicWidgetState extends State<EpmurasInfographicWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,

      // --------------------
      // Agrego aquí el AppBar azul con título centrado y flecha de retorno
      // --------------------
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        centerTitle: true,
        title: const Text(
          'Bases Teóricas',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Ajusta esta línea según cómo tengas definida la ruta principal:
            Navigator.pushNamed(context, '/main_menu');
            // Si prefieres hacer un pop simple:
            // Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),

      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --------------------
            // Aquí puedes conservar o quitar este Container si prefieres
            // que el "header" azul sea solo el AppBar. Si quieres mantener
            // parte de este contenido, lo dejo tal cual, pero se mostrará
            // debajo del AppBar.
            // --------------------
            Container(
              width: double.infinity,
              color: const Color(0xFF005082),
              padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    'EPMURAS: La Revolución Genética en su Hato',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width > 768 ? 48.0 : 36.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Maximice la rentabilidad y el potencial de su ganadería a través de la evaluación fenotípica de precisión.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width > 768 ? 20.0 : 18.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 48.0, bottom: 40.0),
                    child: Column(
                      children: [
                        Text(
                          '¿Qué es la Técnica EPMURAS?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: const Color(0xFF005082),
                            fontSize: MediaQuery.of(context).size.width > 768 ? 32.0 : 28.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'La técnica EPMURAS (Evaluación de Parámetros Morfológicos, Productivos y Reproductivos de Animales Superiores) es una metodología integral que permite identificar y seleccionar a los mejores animales basándose en sus características observables. Es la herramienta clave para un progreso genético acelerado y decisiones estratégicas informadas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 768) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: _buildParameterCard(
                                '📏',
                                'Parámetros Morfológicos',
                                'Evalúa la estructura corporal, conformación, aplomos y desarrollo muscular. La base para animales funcionales y longevos.',
                              ),
                            ),
                            Expanded(
                              child: _buildParameterCard(
                                '📈',
                                'Parámetros Productivos',
                                'Mide la eficiencia en la producción de carne o leche, como la ganancia de peso y la conversión alimenticia.',
                              ),
                            ),
                            Expanded(
                              child: _buildParameterCard(
                                '🧬',
                                'Parámetros Reproductivos',
                                'Analiza indicadores clave de fertilidad, como la edad al primer parto y la circunferencia escrotal en machos.',
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildParameterCard(
                              '📏',
                              'Parámetros Morfológicos',
                              'Evalúa la estructura corporal, conformación, aplomos y desarrollo muscular. La base para animales funcionales y longevos.',
                            ),
                            _buildParameterCard(
                              '📈',
                              'Parámetros Productivos',
                              'Mide la eficiencia en la producción de carne o leche, como la ganancia de peso y la conversión alimenticia.',
                            ),
                            _buildParameterCard(
                              '🧬',
                              'Parámetros Reproductivos',
                              'Analiza indicadores clave de fertilidad, como la edad al primer parto y la circunferencia escrotal en machos.',
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 48.0, bottom: 40.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10.0,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 16.0),
                      child: Column(
                        children: [
                          Text(
                            'El Flujo de Trabajo EPMURAS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: const Color(0xFF005082),
                              fontSize: MediaQuery.of(context).size.width > 768 ? 32.0 : 28.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            'Un proceso sistemático en 5 pasos para transformar datos en decisiones rentables.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 32.0),
                          _buildFlowchartStep(
                            '1',
                            'Identificación Individual',
                            'Cada animal recibe un identificador único para un seguimiento preciso.',
                          ),
                          _buildFlowchartLine(),
                          _buildFlowchartStep(
                            '2',
                            'Definir Puntos de Medición',
                            'Se establecen qué características medir y con qué frecuencia.',
                          ),
                          _buildFlowchartLine(),
                          _buildFlowchartStep(
                            '3',
                            'Recopilación de Datos',
                            'Mediciones periódicas de peso, altura, eventos reproductivos, etc.',
                          ),
                          _buildFlowchartLine(),
                          _buildFlowchartStep(
                            '4',
                            'Digitalización y Análisis',
                            'Los datos se registran y procesan en una plataforma digital.',
                          ),
                          _buildFlowchartLine(),
                          _buildFlowchartStep(
                            '5',
                            'Toma de Decisiones',
                            'Los informes clasifican animales y guían la selección y el manejo.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 48.0, bottom: 40.0),
                    child: Column(
                      children: [
                        Text(
                          'Beneficios Clave: Antes y Después',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: const Color(0xFF005082),
                            fontSize: MediaQuery.of(context).size.width > 768 ? 32.0 : 28.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'La implementación de EPMURAS marca una diferencia medible en la eficiencia y rentabilidad del hato. La gráfica compara los resultados de un manejo tradicional frente a uno basado en EPMURAS.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 32.0),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10.0,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Gráfico de Barras: Comparativa de Beneficios',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0077C0),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              const Text(
                                'Los datos presentados a continuación se visualizan en un gráfico de barras. En una aplicación real de FlutterFlow, aquí se integraría un widget de gráfico (por ejemplo, de la librería fl_chart o charts_flutter) para una representación interactiva.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: 'Roboto', fontSize: 14.0),
                              ),
                              const SizedBox(height: 16.0),
                              Container(
                                height: 300,
                                color: Colors.grey[200],
                                alignment: Alignment.center,
                                child: const Text(
                                  'Placeholder para Gráfico de Barras\n(Usa fl_chart o similar en FlutterFlow)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey, fontSize: 16.0),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Column(
                                children: [
                                  _buildBarDataRow('Precisión de Selección', 40, 90),
                                  _buildBarDataRow('Eficiencia Productiva', 60, 85),
                                  _buildBarDataRow('Retorno de Inversión', 50, 80),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 48.0, bottom: 40.0),
                    child: Column(
                      children: [
                        Text(
                          'EPMURAS en Acción: Casos Prácticos',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: const Color(0xFF005082),
                            fontSize: MediaQuery.of(context).size.width > 768 ? 32.0 : 28.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'Descubra cómo se aplica EPMURAS para resolver desafíos específicos en ganadería de carne y leche.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 32.0),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 768) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildCaseStudyCard(
                                      'Caso 1: Selección de Toros (Carne)',
                                      'Se priorizan los factores más influyentes en la rentabilidad de la producción de carne para seleccionar al reproductor ideal. El objetivo es maximizar la ganancia de peso y la fertilidad.',
                                      'doughnut',
                                      [
                                        {'label': 'Ganancia de Peso', 'value': 40, 'color': const Color(0xFF005082)},
                                        {'label': 'Circunferencia Escrotal', 'value': 30, 'color': const Color(0xFF0077C0)},
                                        {'label': 'Conformación', 'value': 30, 'color': const Color(0xFF00A1E4)},
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildCaseStudyCard(
                                      'Caso 2: Producción Lechera',
                                      'Comparativa de la curva de lactancia entre una vaca promedio y una vaca superior, seleccionada mediante EPMURAS por su alta producción y persistencia.',
                                      'line',
                                      [
                                        {
                                          'label': 'Vaca Promedio',
                                          'data': [450, 550, 600, 580, 550, 500, 450, 400, 350, 300],
                                          'color': const Color(0xFF00A1E4)
                                        },
                                        {
                                          'label': 'Vaca Seleccionada con EPMURAS',
                                          'data': [550, 680, 750, 720, 680, 620, 550, 500, 450, 400],
                                          'color': const Color(0xFF005082)
                                        },
                                      ],
                                      xAxisLabels: [
                                        'Mes 1',
                                        'Mes 2',
                                        'Mes 3',
                                        'Mes 4',
                                        'Mes 5',
                                        'Mes 6',
                                        'Mes 7',
                                        'Mes 8',
                                        'Mes 9',
                                        'Mes 10'
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  _buildCaseStudyCard(
                                    'Caso 1: Selección de Toros (Carne)',
                                    'Se priorizan los factores más influyentes en la rentabilidad de la producción de carne para seleccionar al reproductor ideal. El objetivo es maximizar la ganancia de peso y la fertilidad.',
                                    'doughnut',
                                    [
                                      {'label': 'Ganancia de Peso', 'value': 40, 'color': const Color(0xFF005082)},
                                      {'label': 'Circunferencia Escrotal', 'value': 30, 'color': const Color(0xFF0077C0)},
                                      {'label': 'Conformación', 'value': 30, 'color': const Color(0xFF00A1E4)},
                                    ],
                                  ),
                                  _buildCaseStudyCard(
                                    'Caso 2: Producción Lechera',
                                    'Comparativa de la curva de lactancia entre una vaca promedio y una vaca superior, seleccionada mediante EPMURAS por su alta producción y persistencia.',
                                    'line',
                                    [
                                      {
                                        'label': 'Vaca Promedio',
                                        'data': [450, 550, 600, 580, 550, 500, 450, 400, 350, 300],
                                        'color': const Color(0xFF00A1E4)
                                      },
                                      {
                                        'label': 'Vaca Seleccionada con EPMURAS',
                                        'data': [550, 680, 750, 720, 680, 620, 550, 500, 450, 400],
                                        'color': const Color(0xFF005082)
                                      },
                                    ],
                                    xAxisLabels: [
                                      'Mes 1',
                                      'Mes 2',
                                      'Mes 3',
                                      'Mes 4',
                                      'Mes 5',
                                      'Mes 6',
                                      'Mes 7',
                                      'Mes 8',
                                      'Mes 9',
                                      'Mes 10'
                                    ],
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF005082),
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10.0,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 32.0),
                    child: Column(
                      children: [
                        Text(
                          'El Futuro es Digital: Potencie EPMURAS con Tecnología',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width > 768 ? 32.0 : 28.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'Una aplicación móvil lleva EPMURAS directamente al campo, simplificando cada paso del proceso y poniendo el poder de los datos en la palma de su mano.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 32.0),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 992) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: _buildFeatureCard(
                                      '📱',
                                      'Registro Intuitivo',
                                      'Capture datos en campo de forma rápida y sin errores.',
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildFeatureCard(
                                      '👤',
                                      'Perfiles Individuales',
                                      'Consulte el historial completo de cada animal al instante.',
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildFeatureCard(
                                      '📊',
                                      'Análisis Visual',
                                      'Gráficos y alertas que facilitan la interpretación de datos.',
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildFeatureCard(
                                      '📋',
                                      'Informes de Decisión',
                                      'Obtenga resúmenes para guiar la selección y el manejo.',
                                    ),
                                  ),
                                ],
                              );
                            } else if (constraints.maxWidth > 768) {
                              return Wrap(
                                spacing: 16.0,
                                runSpacing: 16.0,
                                alignment: WrapAlignment.center,
                                children: [
                                  _buildFeatureCard(
                                    '📱',
                                    'Registro Intuitivo',
                                    'Capture datos en campo de forma rápida y sin errores.',
                                  ),
                                  _buildFeatureCard(
                                    '👤',
                                    'Perfiles Individuales',
                                    'Consulte el historial completo de cada animal al instante.',
                                  ),
                                  _buildFeatureCard(
                                    '📊',
                                    'Análisis Visual',
                                    'Gráficos y alertas que facilitan la interpretación de datos.',
                                  ),
                                  _buildFeatureCard(
                                    '📋',
                                    'Informes de Decisión',
                                    'Obtenga resúmenes para guiar la selección y el manejo.',
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  _buildFeatureCard(
                                    '📱',
                                    'Registro Intuitivo',
                                    'Capture datos en campo de forma rápida y sin errores.',
                                  ),
                                  _buildFeatureCard(
                                    '👤',
                                    'Perfiles Individuales',
                                    'Consulte el historial completo de cada animal al instante.',
                                  ),
                                  _buildFeatureCard(
                                    '📊',
                                    'Análisis Visual',
                                    'Gráficos y alertas que facilitan la interpretación de datos.',
                                  ),
                                  _buildFeatureCard(
                                    '📋',
                                    'Informes de Decisión',
                                    'Obtenga resúmenes para guiar la selección y el manejo.',
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterCard(String icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(
              fontSize: 48.0,
              color: Color(0xFF00A1E4),
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
              color: Color(0xFF003366),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowchartStep(String number, String title, String description) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56.0,
            height: 56.0,
            decoration: BoxDecoration(
              color: const Color(0xFF00A1E4),
              borderRadius: BorderRadius.circular(28.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                fontFamily: 'Roboto',
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 24.0),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowchartLine() {
    return Container(
      width: 2.0,
      height: 40.0,
      color: const Color(0xFF0077C0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
    );
  }

  Widget _buildBarDataRow(String label, int traditional, int epmuras) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Text(
                'Tradicional ($traditional%)',
                style: const TextStyle(fontFamily: 'Roboto', fontSize: 13.0, color: Color(0xFF00A1E4)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: LinearProgressIndicator(
                    value: traditional / 100,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00A1E4)),
                    minHeight: 10.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Row(
            children: [
              Text(
                'EPMURAS ($epmuras%)',
                style: const TextStyle(fontFamily: 'Roboto', fontSize: 13.0, color: Color(0xFF005082)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: LinearProgressIndicator(
                    value: epmuras / 100,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF005082)),
                    minHeight: 10.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaseStudyCard(
    String title,
    String description,
    String chartType,
    List<Map<String, dynamic>> chartData, {
    List<String>? xAxisLabels,
  }) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0077C0),
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 16.0),
          Container(
            height: 250,
            color: Colors.grey[200],
            alignment: Alignment.center,
            child: Text(
              'Placeholder para Gráfico de ${chartType == 'doughnut' ? 'Dona' : 'Línea'}\n(Usa fl_chart o similar en FlutterFlow)',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 16.0),
            ),
          ),
          const SizedBox(height: 16.0),
          if (chartType == 'doughnut')
            Column(
              children: chartData.map((data) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: data['color'],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        '${data['label']}: ${data['value']}%',
                        style: const TextStyle(fontFamily: 'Roboto', fontSize: 14.0),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          if (chartType == 'line' && xAxisLabels != null)
            Column(
              children: [
                const Text(
                  'Datos de Producción (Litros/Mes):',
                  style: TextStyle(fontFamily: 'Roboto', fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                ...chartData.map((data) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: data['color'],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            '${data['label']}: ${data['data'].join(', ')}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(fontFamily: 'Roboto', fontSize: 13.0),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 8.0),
                Text(
                  'Meses: ${xAxisLabels.join(', ')}',
                  style: const TextStyle(fontFamily: 'Roboto', fontSize: 13.0, fontStyle: FontStyle.italic),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0077C0),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(
              fontSize: 48.0,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14.0,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
