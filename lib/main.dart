import 'package:flutter/material.dart';

void main() {
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

class _QuestMapScreenState extends State<QuestMapScreen> {
  int _level = 1;
  int _xp = 0;
  int _totalQuestsCompleted = 0;
  double _progress = 0.0;
  final int _xpToNextLevel = 100;
  final double _mapWidth = 300.0;
  double _characterPosition = 0.0;
  String _currentGoal = "Дойти до замка";
  bool _showSudoku = false;
  // Убрали неиспользуемое поле _sudokuCompleted

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
    {
      'id': 1,
      'title': 'Пройти 10,000 шагов',
      'xp': 30,
      'completed': false,
      'type': 'steps',
    },
    {
      'id': 2,
      'title': 'Сделать 40 отжиманий',
      'xp': 40,
      'completed': false,
      'type': 'exercise',
    },
    {
      'id': 3,
      'title': '1-2 часа без телефона',
      'xp': 25,
      'completed': false,
      'type': 'mindfulness',
    },
    {
      'id': 4,
      'title': 'Выпить 2 литра воды',
      'xp': 20,
      'completed': false,
      'type': 'health',
    },
    {
      'id': 5,
      'title': 'Прочитать 30 страниц',
      'xp': 35,
      'completed': false,
      'type': 'study',
    },
    {
      'id': 6,
      'title': 'Сделать 50 приседаний',
      'xp': 45,
      'completed': false,
      'type': 'exercise',
    },
    {
      'id': 7,
      'title': 'Лечь спать до 23:00',
      'xp': 30,
      'completed': false,
      'type': 'health',
    },
    {
      'id': 8,
      'title': 'Выучить 10 новых слов',
      'xp': 25,
      'completed': false,
      'type': 'study',
    },
    {
      'id': 9,
      'title': 'Сделать 5 минут планки',
      'xp': 35,
      'completed': false,
      'type': 'exercise',
    },
    {
      'id': 10,
      'title': 'Решить Судоку',
      'xp': 70,
      'completed': false,
      'type': 'puzzle',
    },
  ];

  void _completeQuest(int index) {
    if (_quests[index]['completed']) return;

    setState(() {
      _quests[index]['completed'] = true;
      _xp += _quests[index]['xp'] as int;
      _totalQuestsCompleted++;
      
      if (_quests[index]['type'] == 'puzzle') {
        _showSudoku = true;
        return;
      }

      _updateProgress();
    });
  }

  void _completeSudoku() {
    setState(() {
      _showSudoku = false;
      _xp += 70;
      _totalQuestsCompleted++;
      _updateProgress();
    });
  }

  void _updateProgress() {
    _progress = _totalQuestsCompleted / _quests.length;
    _characterPosition = _mapWidth * _progress;
    
    if (_xp >= _xpToNextLevel) {
      _level++;
      _xp = 0;
      _updateGoal();
    }
  }

  void _updateGoal() {
    if (_level - 1 < _goals.length) {
      _currentGoal = _goals[_level - 1];
    } else {
      _currentGoal = "Поздравляем! Вы достигли конечной цели!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Квест Приключение+'),
        centerTitle: true,
      ),
      body: _showSudoku ? _buildSudokuGame() : _buildMainScreen(),
    );
  }

  Widget _buildMainScreen() {
    return Column(
      children: [
        // Карта с персонажем
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
                left: _characterPosition,
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
                    color: Colors.black.withOpacity(0.5),
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
        
        // Прогресс и статистика
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[300],
            color: Colors.green,
            minHeight: 20,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${(_progress * 100).toStringAsFixed(1)}% пути пройдено',
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
                Column(children: [
                  const Icon(Icons.star, color: Colors.amber),
                  Text('$_xp/$_xpToNextLevel XP'),
                ]),
                Column(children: [
                  const Icon(Icons.flag, color: Colors.green),
                  Text('$_totalQuestsCompleted/${_quests.length} квестов'),
                ]),
                Column(children: [
                  const Icon(Icons.terrain, color: Colors.blue),
                  Text('Ур. $_level'),
                ]),
              ],
            ),
          ),
        ),
        
        // Список квестов
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
        Expanded(
          child: ListView.builder(
            itemCount: _quests.length,
            itemBuilder: (context, index) {
              final quest = _quests[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: _getQuestIcon(quest['type'] as String),
                  title: Text(quest['title'] as String),
                  subtitle: Text('Награда: ${quest['xp']} XP'),
                  trailing: IconButton(
                    icon: Icon(
                      quest['completed'] ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: quest['completed'] ? Colors.green : Colors.grey,
                    ),
                    onPressed: () => _completeQuest(index),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSudokuGame() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Решите Судоку',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            width: 300,
            height: 300,
            color: Colors.grey[200],
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(2),
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      (index + 1).toString(),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              },
              itemCount: 9,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _completeSudoku,
            child: const Text('Завершить Судоку'),
          ),
        ],
      ),
    );
  }

  Icon _getQuestIcon(String type) {
    switch (type) {
      case 'steps': return const Icon(Icons.directions_walk, color: Colors.blue);
      case 'exercise': return const Icon(Icons.fitness_center, color: Colors.red);
      case 'health': return const Icon(Icons.local_hospital, color: Colors.green);
      case 'study': return const Icon(Icons.menu_book, color: Colors.purple);
      case 'mindfulness': return const Icon(Icons.phone_disabled, color: Colors.orange);
      case 'puzzle': return const Icon(Icons.casino, color: Colors.indigo);
      default: return const Icon(Icons.help_outline);
    }
  }
}