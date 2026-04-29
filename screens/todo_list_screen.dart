import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../database/database_helper.dart';
import 'todo_list_form.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();

  List<Todo> _todos = [];
  bool _isLoading = true;
  String _statusFilter = 'all'; // 'all' | 'active' | 'completed'
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    setState(() => _isLoading = true);
    final todos = await _dbHelper.getTodos(
      statusFilter: _statusFilter,
      keyword: _keyword,
    );
    setState(() {
      _todos = todos;
      _isLoading = false;
    });
  }

  Future<void> _toggleTodo(Todo todo) async {
    await _dbHelper.toggleTodoStatus(todo.id!, !todo.isDone);
    _loadTodos();
  }

  Future<void> _deleteTodo(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: const Text('Tugas ini akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _dbHelper.deleteTodo(id);
      _loadTodos();
    }
  }

  Future<void> _navigateToAddForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TodoFormScreen()),
    );
    _loadTodos();
  }

  Future<void> _navigateToEditForm(Todo todo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TodoFormScreen(todo: todo)),
    );
    _loadTodos();
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _filterLabel(String value) {
    switch (value) {
      case 'active':    return 'Belum Selesai';
      case 'completed': return 'Selesai';
      default:          return 'Semua';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Hapus semua yang selesai',
            onPressed: () async {
              await _dbHelper.clearCompletedTodos();
              _loadTodos();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari tugas...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _keyword.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _keyword = '');
                    _loadTodos();
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _keyword = value);
                _loadTodos();
              },
            ),
          ),

          // Filter Chip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: ['all', 'active', 'completed'].map((filter) {
                final isSelected = _statusFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_filterLabel(filter)),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _statusFilter = filter);
                      _loadTodos();
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Daftar Tugas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _todos.isEmpty
                ? const Center(
              child: Text(
                'Tidak ada tugas ditemukan.',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.isDone,
                      onChanged: (_) => _toggleTodo(todo),
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isDone
                            ? TextDecoration.lineThrough
                            : null,
                        color: todo.isDone ? Colors.grey : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (todo.description.isNotEmpty)
                          Text(todo.description),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(todo.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: todo.description.isNotEmpty,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () =>
                              _navigateToEditForm(todo),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 20,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteTodo(todo.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}