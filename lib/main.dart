import 'package:flutter/material.dart';

void main() {
  runApp(HabitHiveApp());
}

class HabitHiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Hive',
      theme: _customTheme(),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _customTheme() {
    return ThemeData(
      primarySwatch: Colors.teal,
      colorScheme: ColorScheme.light(
        primary: Color.fromARGB(255, 77, 118, 255),
        secondary: Color.fromARGB(255, 77, 118, 255),
        background: Colors.grey[100],
        onPrimary: Colors.white,
        onSecondary: Colors.black,
      ),
      appBarTheme: AppBarTheme(
        color: Color.fromARGB(255, 247, 247, 247),
        foregroundColor: const Color.fromARGB(255, 0, 0, 0), // Text color in AppBar
        titleTextStyle: TextStyle(
          fontSize: 37,
          fontWeight: FontWeight.bold,
          color: const Color.fromARGB(255, 77, 118, 255),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: Color.fromARGB(255, 77, 118, 255), fontSize: 24, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: Color.fromARGB(255, 77, 118, 255), fontSize: 22, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.teal,
        textTheme: ButtonTextTheme.primary,
      ),
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
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.black54,
        backgroundColor: Colors.grey[200],
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
        title: Text('Habit Hive', style: Theme.of(context).appBarTheme.titleTextStyle),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: onAddHabit,
          ),
        ],
      ),
      body: habits.isEmpty
          ? Center(
              child: Text('Start a new habit to track progress!', style: Theme.of(context).textTheme.bodyLarge),
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
        activeColor: Theme.of(context).colorScheme.secondary,
      ),
      title: Text(habit.title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${habit.completedDays.length} days', style: Theme.of(context).textTheme.bodyMedium),
          IconButton(
            icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
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
      title: Text('New Habit', style: Theme.of(context).textTheme.displayMedium),
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
        title: Text('Habit Hive', style: Theme.of(context).appBarTheme.titleTextStyle),
      ),
      body: habits.isEmpty
          ? Center(
              child: Text('Start a new habit to track progress!', style: Theme.of(context).textTheme.bodyLarge),
            )
          : ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return ListTile(
                  title: Text(habit.title, style: Theme.of(context).textTheme.displayMedium),
                  subtitle: Text('Completed: ${habit.completedDays.length} days', style: Theme.of(context).textTheme.bodyMedium),
                );
              },
            ),
    );
  }
}
