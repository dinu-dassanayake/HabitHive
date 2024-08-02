import 'package:flutter/material.dart';

void main() {
  runApp(HabitHiveApp());
}

class HabitHiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Hive',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Habit> _habits = [];

  void _addHabit(String title) {
    setState(() {
      _habits.add(Habit(title: title));
    });
  }

  void _toggleHabit(Habit habit) {
    setState(() {
      habit.isCompleted = !habit.isCompleted;
      if (habit.isCompleted) {
        habit.completedDays.add(DateTime.now());
      } else {
        habit.completedDays.removeWhere((date) => isSameDay(date, DateTime.now()));
      }
    });
  }

  void _removeHabit(Habit habit) {
    setState(() {
      _habits.remove(habit);
    });
  }

  void _showAddHabitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddHabitDialog(
          onAdd: _addHabit,
        );
      },
    );
  }

  List<Widget> _pages() => [
        HabitListScreen(
          habits: _habits,
          onToggle: _toggleHabit,
          onRemove: _removeHabit,
          onAddHabit: _showAddHabitDialog,
        ),
        StatsScreen(habits: _habits),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages()[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}

class Habit {
  final String title;
  bool isCompleted;
  final Set<DateTime> completedDays;

  Habit({required this.title, this.isCompleted = false}) : completedDays = {};
}

class HabitListScreen extends StatelessWidget {
  final List<Habit> habits;
  final ValueChanged<Habit> onToggle;
  final ValueChanged<Habit> onRemove;
  final VoidCallback onAddHabit;

  HabitListScreen({
    required this.habits,
    required this.onToggle,
    required this.onRemove,
    required this.onAddHabit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Hive'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: onAddHabit,
          ),
        ],
      ),
      body: habits.isEmpty
          ? Center(
              child: Text('Start a new habit to track progress'),
            )
          : ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return HabitListItem(
                  habit: habit,
                  onToggle: onToggle,
                  onRemove: onRemove,
                );
              },
            ),
    );
  }
}

class HabitListItem extends StatelessWidget {
  final Habit habit;
  final ValueChanged<Habit> onToggle;
  final ValueChanged<Habit> onRemove;

  HabitListItem({
    required this.habit,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: habit.isCompleted,
        onChanged: (bool? value) {
          onToggle(habit);
        },
      ),
      title: Text(habit.title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${habit.completedDays.length} days'),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              onRemove(habit);
            },
          ),
        ],
      ),
    );
  }
}

class AddHabitDialog extends StatelessWidget {
  final Function(String) onAdd;
  final TextEditingController _controller = TextEditingController();

  AddHabitDialog({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Habit'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: 'Enter habit title'),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Add'),
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              onAdd(_controller.text);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

class StatsScreen extends StatelessWidget {
  final List<Habit> habits;

  StatsScreen({required this.habits});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Stats'),
      ),
      body: habits.isEmpty
          ? Center(
              child: Text('Start a new habit to track progress'),
            )
          : ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return ListTile(
                  title: Text(habit.title),
                  subtitle: Text('Completed: ${habit.completedDays.length} days'),
                );
              },
            ),
    );
  }
}
