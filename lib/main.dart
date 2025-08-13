import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quest Adventure+',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QuestMapScreen(),
    );
  }
}

class QuestMapScreen extends StatefulWidget {
  const QuestMapScreen({super.key});

  @override
  State<QuestMapScreen> createState() => _QuestMapScreenState();
}

class _QuestMapScreenState extends State<QuestMapScreen> 
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int _level = 1;
  int _xp = 0;
  int _totalQuestsCompleted = 0;
  final int _xpToNextLevel = 100;
  String _currentGoal = "Дойти до замка";
  bool _isLoading = true;
  bool _isSudokuCompleted = false;

  final List<String> _goals = [
    "Дойти до реки",
    "Перейти мост",
    "Исследовать лес",
    "Взойти на гору",
    "Найти пещеру",
    "Дойти до водопада",
    "Перейти пустыню",
    "Достичь замка"
  ];

  final List<Map<String, dynamic>> _quests = [
    {'id': 1, 'title': 'Пройти 10,000 шагов', 'xp': 30, 'completed': false, 'type': 'steps'},
    {'id': 2, 'title': 'Сделать 40 отжиманий', 'xp': 40, 'completed': false, 'type': 'exercise'},
    {'id': 3, 'title': '1-2 часа без телефона', 'xp': 25, 'completed': false, 'type': 'mindfulness'},
    {'id': 4, 'title': 'Выпить 2 литра воды', 'xp': 20, 'completed': false, 'type': 'health'},
    {'id': 5, 'title': 'Прочитать 30 страниц', 'xp': 35, 'completed': false, 'type': 'study'},
    {'id': 6, 'title': 'Сделать 50 приседаний', 'xp': 45, 'completed': false, 'type': 'exercise'},
    {'id': 7, 'title': 'Лечь спать до 23:00', 'xp': 30, 'completed': false, 'type': 'health'},
    {'id': 8, 'title': 'Выучить 10 новых слов', 'xp': 25, 'completed': false, 'type': 'study'},
    {'id': 9, 'title': 'Сделать 5 минут планки', 'xp': 35, 'completed': false, 'type': 'exercise'},
    {'id': 10, 'title': 'Решить Судоку', 'xp': 70, 'completed': false, 'type': 'puzzle'},
  ];

  List<List<int>> _sudokuGrid = List.generate(9, (_) => List.filled(9, 0));

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _generateSudoku();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('level', _level);
    await prefs.setInt('xp', _xp);
    await prefs.setInt('totalQuests', _totalQuestsCompleted);
    await prefs.setBool('sudokuCompleted', _isSudokuCompleted);
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _level = prefs.getInt('level') ?? 1;
      _xp = prefs.getInt('xp') ?? 0;
      _totalQuestsCompleted = prefs.getInt('totalQuests') ?? 0;
      _isSudokuCompleted = prefs.getBool('sudokuCompleted') ?? false;
      _updateGoal();
      
      if (_isSudokuCompleted) {
        for (var quest in _quests) {
          if (quest['type'] == 'puzzle') {
            quest['completed'] = true;
            break;
          }
        }
      }
      _isLoading = false;
    });
  }

  void _completeQuest(int index) {
    if (_quests[index]['completed']) return;

    setState(() {
      _quests[index]['completed'] = true;
      _xp += _quests[index]['xp'] as int;
      _totalQuestsCompleted++;

      if (_xp >= _xpToNextLevel) {
        _level++;
        _xp = 0;
        _updateGoal();
      }
      _saveProgress();
    });
  }

  void _completeSudoku() {
    if (!_isSudokuCompleted) {
      setState(() {
        _isSudokuCompleted = true;
        for (var quest in _quests) {
          if (quest['type'] == 'puzzle' && !quest['completed']) {
            quest['completed'] = true;
            _xp += quest['xp'] as int;
            _totalQuestsCompleted++;
            break;
          }
        }

        if (_xp >= _xpToNextLevel) {
          _level++;
          _xp = 0;
          _updateGoal();
        }
        _saveProgress();
      });
    }
  }

  void _updateGoal() {
    if (_level - 1 < _goals.length) {
      _currentGoal = _goals[_level - 1];
    } else {
      _currentGoal = "Поздравляем! Вы достигли конечной цели!";
    }
  }

  void _generateSudoku() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        _sudokuGrid[i][j] = (i + j) % 9 + 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final progress = _totalQuestsCompleted / _quests.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Квест Приключение+'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProgressSection(progress),
            _buildSudokuGame(),
            _buildQuestsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(double progress) {
    return Column(
      children: [
        Container(
          height: 200,
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.brown, width: 3),
            borderRadius: BorderRadius.circular(10),
            color: Colors.green[100],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 300 * progress,
                top: 50,
                child: Column(
                  children: [
                    const Icon(Icons.person, size: 40, color: Colors.red),
                    Text(
                      'Ур. $_level',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 10,
                top: 80,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(128),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Цель: $_currentGoal',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            color: Colors.green,
            minHeight: 20,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${(progress * 100).toStringAsFixed(1)}% пути пройдено',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Card(
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.star, Colors.amber, '$_xp/$_xpToNextLevel XP'),
                _buildStatItem(Icons.flag, Colors.green, '$_totalQuestsCompleted/${_quests.length} квестов'),
                _buildStatItem(Icons.terrain, Colors.blue, 'Ур. $_level'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String text) {
    return Column(
      children: [
        Icon(icon, color: color),
        Text(text),
      ],
    );
  }

  Widget _buildSudokuGame() {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Решите Судоку',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 9,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  int row = index ~/ 9;
                  int col = index % 9;
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: _sudokuGrid[row][col] == 0 ? Colors.white : Colors.grey[200],
                    ),
                    child: Center(
                      child: _sudokuGrid[row][col] == 0 
                          ? const Text('')
                          : Text(
                              _sudokuGrid[row][col].toString(),
                              style: const TextStyle(fontSize: 18),
                            ),
                    ),
                  );
                },
                itemCount: 81,
              ),
            ),
            const SizedBox(height: 10),
            if (!_isSudokuCompleted)
              ElevatedButton(
                onPressed: _completeSudoku,
                child: const Text('Завершить Судоку'),
              )
            else
              const Text(
                'Судоку решено!',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestsList() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Активные квесты:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ..._quests.map((quest) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: _getQuestIcon(quest['type'] as String),
            title: Text(quest['title'] as String),
            subtitle: Text('Награда: ${quest['xp']} XP'),
            trailing: IconButton(
              icon: Icon(
                quest['completed']
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: quest['completed'] ? Colors.green : Colors.grey,
              ),
              onPressed: () => _completeQuest(_quests.indexOf(quest)),
            ),
          ),
        )).toList(),
      ],
    );
  }

  Icon _getQuestIcon(String type) {
    switch (type) {
      case 'steps':
        return const Icon(Icons.directions_walk, color: Colors.blue);
      case 'exercise':
        return const Icon(Icons.fitness_center, color: Colors.red);
      case 'health':
        return const Icon(Icons.local_hospital, color: Colors.green);
      case 'study':
        return const Icon(Icons.menu_book, color: Colors.purple);
      case 'mindfulness':
        return const Icon(Icons.phone_disabled, color: Colors.orange);
      case 'puzzle':
        return const Icon(Icons.casino, color: Colors.indigo);
      default:
        return const Icon(Icons.help_outline);
    }
  }
}