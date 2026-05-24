import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;
import 'dart:html' as html;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    ui.platformViewRegistry.registerViewFactory(
      'iframe-site',
      (int viewId) => html.IFrameElement()
        ..src = 'https://regeneraremagrecimento.onrender.com/'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%',
    );
  }

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Contadores de metas
  int _waterCount = 0;
  final int _waterGoal = 8;

  int _physicalCount = 0;
  final int _physicalGoal = 1;

  int _mentalCount = 0;
  final int _mentalGoal = 1;
  
  // Garantindo listas com tamanho fixo de 30 dias
  final List<bool> _fase1Dias = List<bool>.filled(30, false, growable: false);
  final List<bool> _fase2Dias = List<bool>.filled(30, false, growable: false);
  final List<bool> _fase3Dias = List<bool>.filled(30, false, growable: false);
  final List<bool> _fase4Dias = List<bool>.filled(30, false, growable: false);

  bool _alertAgua = false;
  bool _alertTreinoFisico = false;
  bool _alertTreinoMental = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _waterCount = prefs.getInt('waterCount') ?? 0;
      _physicalCount = prefs.getInt('physicalCount') ?? 0;
      _mentalCount = prefs.getInt('mentalCount') ?? 0;

      _alertAgua = prefs.getBool('alertAgua') ?? false;
      _alertTreinoFisico = prefs.getBool('alertTreinoFisico') ?? false;
      _alertTreinoMental = prefs.getBool('alertTreinoMental') ?? false;
      
      // Carregamento seguro limitando estritamente a 30 iterações
      for (int i = 0; i < 30; i++) {
        _fase1Dias[i] = prefs.getBool('fase1_$i') ?? false;
        _fase2Dias[i] = prefs.getBool('fase2_$i') ?? false;
        _fase3Dias[i] = prefs.getBool('fase3_$i') ?? false;
        _fase4Dias[i] = prefs.getBool('fase4_$i') ?? false;
      }
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      // ABA 1: PLATAFORMA (IFRAME)
      const HtmlElementView(viewType: 'iframe-site'),
      
      // ABA 2: DIÁRIO DE FASES
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Meu Progresso', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 20),
            _buildFaseCard('Fase 1: Estalo Inicial', _fase1Dias, 'fase1'),
            const SizedBox(height: 16),
            _buildFaseCard('Fase 2: Cura pelo Som', _fase2Dias, 'fase2'),
            const SizedBox(height: 16),
            _buildFaseCard('Fase 3: Fase 3', _fase3Dias, 'fase3'),
            const SizedBox(height: 16),
            _buildFaseCard('Fase 4: Fase 4', _fase4Dias, 'fase4'),
          ],
        ),
      ),

      // ABA 3: ALERTAS E SAÚDE
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saúde & Lembretes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 20),
            
            // CARD 1: BEBER ÁGUA
            _buildCounterCard(
              title: 'Beber Água',
              current: _waterCount,
              goal: _waterGoal,
              labelSuffix: 'copos',
              icon: Icons.local_drink,
              iconColor: Colors.blue,
              barColor: Colors.blue,
              onRemove: () async {
                if (_waterCount > 0) {
                  setState(() { _waterCount--; });
                  _saveInt('waterCount', _waterCount);
                }
              },
              onAdd: () async {
                setState(() { _waterCount++; });
                _saveInt('waterCount', _waterCount);
              },
            ),
            const SizedBox(height: 16),

            // CARD 2: TREINO FÍSICO
            _buildCounterCard(
              title: 'Realizar Treino Físico',
              current: _physicalCount,
              goal: _physicalGoal,
              labelSuffix: 'feito',
              icon: Icons.fitness_center,
              iconColor: Colors.orange,
              barColor: Colors.orange,
              onRemove: () async {
                if (_physicalCount > 0) {
                  setState(() { _physicalCount--; });
                  _saveInt('physicalCount', _physicalCount);
                }
              },
              onAdd: () async {
                setState(() { _physicalCount++; });
                _saveInt('physicalCount', _physicalCount);
              },
            ),
            const SizedBox(height: 16),

            // CARD 3: TREINO MENTAL
            _buildCounterCard(
              title: 'Treino Mental / Meditação',
              current: _mentalCount,
              goal: _mentalGoal,
              labelSuffix: 'feito',
              icon: Icons.psychology,
              iconColor: Colors.purple,
              barColor: Colors.purple,
              onRemove: () async {
                if (_mentalCount > 0) {
                  setState(() { _mentalCount--; });
                  _saveInt('mentalCount', _mentalCount);
                }
              },
              onAdd: () async {
                setState(() { _mentalCount++; });
                _saveInt('mentalCount', _mentalCount);
              },
            ),
            const SizedBox(height: 20),

            const Text('Ativar Notificações no Celular:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Lembrete de Beber Água (De 2 em 2h)'),
              value: _alertAgua,
              activeColor: Colors.green,
              onChanged: (val) {
                setState(() { _alertAgua = val; });
                _saveBool('alertAgua', val);
              },
            ),
            SwitchListTile(
              title: const Text('Alerta de Treino Físico Diário'),
              value: _alertTreinoFisico,
              activeColor: Colors.green,
              onChanged: (val) {
                setState(() { _alertTreinoFisico = val; });
                _saveBool('alertTreinoFisico', val);
              },
            ),
            SwitchListTile(
              title: const Text('Alerta de Treino Mental / Meditação'),
              value: _alertTreinoMental,
              activeColor: Colors.green,
              onChanged: (val) {
                setState(() { _alertTreinoMental = val; });
                _saveBool('alertTreinoMental', val);
              },
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      body: SafeArea(child: screens[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() { _currentIndex = index; });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.language), label: 'Plataforma'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in), label: 'Fases'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Saúde'),
        ],
      ),
    );
  }

  Widget _buildCounterCard({
    required String title,
    required int current,
    required int goal,
    required String labelSuffix,
    required IconData icon,
    required Color iconColor,
    required Color barColor,
    required VoidCallback onRemove,
    required VoidCallback onAdd,
  }) {
    double factor = current / goal;
    if (factor > 1.0) factor = 1.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: iconColor, size: 30),
                    const SizedBox(width: 10),
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text('$current / $goal $labelSuffix', style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: factor,
              backgroundColor: barColor.withOpacity(0.15),
              color: barColor,
              minHeight: 10,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onRemove,
                  child: const Icon(Icons.remove),
                ),
                ElevatedButton(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(backgroundColor: barColor, foregroundColor: Colors.white),
                  child: const Icon(Icons.add),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFaseCard(String title, List<bool> diasList, String keyPrefix) {
    int concluidos = diasList.where((item) => item == true).length;
    
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text('$concluidos de 30 dias feitos', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: List.generate(30, (index) {
                return ChoiceChip(
                  label: Text('D${index + 1}'),
                  selected: diasList[index],
                  selectedColor: Colors.green,
                  labelStyle: TextStyle(
                    color: diasList[index] ? Colors.white : Colors.black,
                  ),
                  onSelected: (selected) async {
                    setState(() { diasList[index] = selected; });
                    _saveBool('${keyPrefix}_$index', selected);
                  },
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}