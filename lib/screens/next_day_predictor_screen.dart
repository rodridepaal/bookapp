import 'dart:async';
import 'package:flutter/material.dart';

class NextDayPredictorScreen extends StatefulWidget {
  const NextDayPredictorScreen({super.key});

  @override
  State<NextDayPredictorScreen> createState() => _NextDayPredictorScreenState();
}

class _NextDayPredictorScreenState extends State<NextDayPredictorScreen> {
  String? _selectedDay;
  bool _isProcessing = false;
  String _loadingText = "";
  String? _result;

  final List<String> _days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  String _getNextDay(String currentDay) {
    int index = _days.indexOf(currentDay);
    if (index == -1) return 'Kiamat';
    int nextIndex = (index + 1) % _days.length;
    return _days[nextIndex];
  }

  void _startPrediction() async {
    if (_selectedDay == null) return;

    setState(() {
      _isProcessing = true;
      _result = null;
    });

    final steps = [
      "Menghubungkan ke satelit NASA...",
      "Menganalisis kalender suku Maya...",
      "Server bekerja keras dan hampir meletup...",
      "Pak bagus ganteng bismillah A...",
      "Hampir selesai..."
    ];

    for (var step in steps) {
      if (!mounted) return;
      setState(() {
        _loadingText = step;
      });
      await Future.delayed(Duration(milliseconds: 900 + (step.length * 20)));
    }

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _result = "Hari setelah $_selectedDay adalah ${_getNextDay(_selectedDay!)}!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 26, 26),
      appBar: AppBar(
        title: const Text("Mesin Peramal Hari", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // icon crystal
              const Icon(Icons.auto_awesome, size: 80, color: Color.fromARGB(255, 255, 255, 255)),
              const SizedBox(height: 20),
              
              const Text(
                "Pilih hari ini, dan dukun digital kami akan meramal hari esok dengan akurasi 100%!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // dropdown input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDay,
                    hint: const Text("Pilih Hari"),
                    isExpanded: true,
                    items: _days.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: _isProcessing ? null : (newValue) {
                      setState(() {
                        _selectedDay = newValue;
                        _result = null;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // tombo trut
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_selectedDay == null || _isProcessing) 
                      ? null 
                      : _startPrediction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("RAMAL MASA DEPAN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 40),

              // Output Area
              if (_isProcessing) ...[
                const CircularProgressIndicator(color: Color.fromARGB(255, 255, 255, 255)),
                const SizedBox(height: 16),
                Text(
                  _loadingText,
                  style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 20, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ] else if (_result != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text("HASIL RAMALAN:", style: TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text(
                        _result!,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}