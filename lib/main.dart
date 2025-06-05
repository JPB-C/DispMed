import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'ecg_grid.dart'; // Asegúrate de que este archivo exista

void main() => runApp(ECGApp());

class ECGApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ECG Simulado',
      home: ECGScreen(),
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.greenAccent, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.greenAccent),
          titleLarge: TextStyle(color: Colors.greenAccent, fontSize: 20),
        ),
      ),
    );
  }
}

class ECGScreen extends StatefulWidget {
  @override
  _ECGScreenState createState() => _ECGScreenState();
}

class _ECGScreenState extends State<ECGScreen> {
  List<FlSpot> ecgData = [];
  Timer? timer;
  double xValue = 0;
  bool isRunning = true;
  double bpm = 30;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 50), (_) {
      if (!isRunning) return;
      setState(() {
        ecgData.add(FlSpot(xValue, _simularECG(xValue)));
        xValue += 0.1;
        if (ecgData.length > 200) ecgData.removeAt(0);
      });
    });
  }

  double _simularECG(double t) {
    double periodo = 30 / bpm;
    double fase = t % periodo;

    if (fase < 0.1) {
      return 0.12 * sin(2 * pi * 5 * fase); // P
    } else if (fase < 0.14) {
      return -0.15 * exp(-50 * pow(fase - 0.12, 2)); // Q
    } else if (fase < 0.18) {
      return 1.2 * exp(-500 * pow(fase - 0.16, 2)); // R
    } else if (fase < 0.22) {
      return -0.25 * exp(-200 * pow(fase - 0.20, 2)); // S
    } else if (fase < 0.4) {
      return 0.25 * sin(2 * pi * 2 * (fase - 0.25)); // T
    }
    return 0.0;
  }

  void togglePlay() {
    setState(() {
      isRunning = !isRunning;
    });
  }

  Widget _buildChart() {
    return LineChart(
      LineChartData(
        minY: -2,
        maxY: 2,
        lineBarsData: [
          LineChartBarData(
            spots: ecgData,
            isCurved: false,
            color: const Color.fromARGB(255,2,230,120),
            barWidth: 2.5,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Cuadrícula como fondo
          Positioned.fill(
            child: CustomPaint(
              painter: ECGGridPainter(),
            ),
          ),

          // Contenido visual encima
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'SEÑAL ECG',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: _buildChart()),
                      const SizedBox(height: 20),
                      Text(
                        'BPM: ${bpm.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: togglePlay,
        child: Icon(
          isRunning ? Icons.pause : Icons.play_arrow,
          color: Colors.black,
        ),
      ),
    );
  }
}
