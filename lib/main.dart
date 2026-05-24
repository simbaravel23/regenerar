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
  int _selectedEvolutionPhase = 0; // 0 = Fase 1, 1 = Fase 2, etc.

  // Contadores de metas
  int _waterCount = 0;
  final int _waterGoal = 8;

  int _physicalCount = 0;
  final int _physicalGoal = 1;

  int _mentalCount = 0;
  final int _mentalGoal = 1;
  
  // Listas fixas com 30 dias
  final List<bool> _fase1Dias = List<bool>.filled(30, false, growable: false);
  final List<bool> _fase2Dias = List<bool>.filled(30, false, growable: false);
  final List<bool> _fase3Dias = List<bool>.filled(30, false, growable: false);
  final List<bool> _fase4Dias = List<bool>.filled(30, false, growable: false);

  bool _alertAgua = false;
  bool _alertTreinoFisico = false;
  bool _alertTreinoMental = false;

  // Controladores de texto para a aba de evolução
  final TextEditingController _pesoInicialController = TextEditingController();
  final TextEditingController _pesoFinalController = TextEditingController();
  final TextEditingController _roupasController = TextEditingController();
  final TextEditingController _videoController = TextEditingController();
  bool _usoImagemAutorizado = false;

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
      
      for (int i = 0; i < 30; i++) {
        _fase1Dias[i] = prefs.getBool('fase1_$i') ?? false;
        _fase2Dias[i] = prefs.getBool('fase2_$i') ?? false;
        _fase3Dias[i] = prefs.getBool('fase3_$i') ?? false;
        _fase4Dias[i] = prefs.getBool('fase4_$i') ?? false;
      }

      _loadPhaseEvolutionData();
    });
  }

  // Carrega dados específicos da aba de evolução baseados na fase selecionada
  void _loadPhaseEvolutionData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pesoInicialController.text = prefs.getString('ev_peso_init_$_selectedEvolutionPhase') ?? '';
      _pesoFinalController.text = prefs.getString('ev_peso_fim_$_selectedEvolutionPhase') ?? '';
      _roupasController.text = prefs.getString('ev_roupas_$_selectedEvolutionPhase') ?? '';
      _videoController.text = prefs.getString('ev_video_$_selectedEvolutionPhase') ?? '';
      _usoImagemAutorizado = prefs.getBool('ev_autoriza_$_selectedEvolutionPhase') ?? false;
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

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
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

      // ABA 3: ABA DE EVOLUÇÃO VISUAL E DEPOIMENTOS
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Minha Evolução', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 10),
            const Text('Monitore suas transformações físicas e depoimentos ao longo das fases.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 15),

            // Seletor de Fase de Evolução
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return ChoiceChip(
                  label: Text('Fase ${index + 1}'),
                  selected: _selectedEvolutionPhase == index,
                  selectedColor: Colors.green,
                  labelStyle: TextStyle(color: _selectedEvolutionPhase == index ? Colors.white : Colors.black),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedEvolutionPhase = index;
                        _loadPhaseEvolutionData();
                      });
                    }
                  },
                );
              }),
            ),
            const SizedBox(height: 20),

            // CARD 1: FOTOS E PESOS (INÍCIO VS FINAL)
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Acompanhamento Antropométrico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        // Coluna Início
                        Expanded(
                          child: Column(
                            children: [
                              const Text('Início da Fase', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                              const SizedBox(height: 10),
                              _buildPhotoPlaceholder('Foto Inicial'),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _pesoInicialController,
                                decoration: const InputDecoration(labelText: 'Peso Inicial (kg)', border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                                onChanged: (val) => _saveString('ev_peso_init_$_selectedEvolutionPhase', val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Coluna Fim
                        Expanded(
                          child: Column(
                            children: [
                              const Text('Fim da Fase', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                              const SizedBox(height: 10),
                              _buildPhotoPlaceholder('Foto Final'),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _pesoFinalController,
                                decoration: const InputDecoration(labelText: 'Peso Final (kg)', border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                                onChanged: (val) => _saveString('ev_peso_fim_$_selectedEvolutionPhase', val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // CARD 2: ROUPAS QUE SERVIRAM
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.checkroom, color: Colors.amber),
                        SizedBox(width: 8),
                        Text('Conquistas no Guarda-Roupa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _roupasController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Ex: Aquela calça jeans antiga voltou a fechar; o vestido não está mais apertado...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => _saveString('ev_roupas_$_selectedEvolutionPhase', val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // CARD 3: DEPOIMENTO EM VÍDEO & TERMO DE USO DE IMAGEM
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.video_call, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Depoimento em Vídeo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _videoController,
                      decoration: const InputDecoration(
                        labelText: 'Link do Vídeo (YouTube / Drive)',
                        prefixIcon: Icon(Icons.link),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => _saveString('ev_video_$_selectedEvolutionPhase', val),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                      ),
                      child: CheckboxListTile(
                        title: const Text(
                          'Autorizo o uso da minha imagem e depoimento para divulgação de resultados.',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        activeColor: Colors.red,
                        value: _usoImagemAutorizado,
                        onChanged: (val) {
                          setState(() { _usoImagemAutorizado = val ?? false; });
                          _saveBool('ev_autoriza_$_selectedEvolutionPhase', val ?? false);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ABA 4: ALERTAS E SAÚDE
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saúde & Lembretes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 20),
            
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
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() { _currentIndex = index; });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.language), label: 'Plataforma'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in), label: 'Fases'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Evolução'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Saúde'),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder(String label) {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_a_photo, color: Colors.grey, size: 30),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
              backgroundColor: barColor.withValues(alpha: 0.15),
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