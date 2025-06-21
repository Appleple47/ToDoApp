import 'package:flutter/material.dart';
import 'package:mytodo/screens/add_todo_screen.dart';
// 日本語などロケール情報を読み込む
import '../models/todo.dart'; // 作成したTodoクラス
import '../widgets/todo_card.dart'; // 作成したTodoCardウィジェット

class TodoList extends StatefulWidget {
  final dynamic todoService;

  const TodoList({super.key, required this.todoService});

  @override
  State<TodoList> createState() => TodoListState();
}

class TodoListState extends State<TodoList> {
  List<Todo> _todos = [];
  bool _isLoading = true;
  
  // get service => null; // ←追加

  @override
  void initState() {
    super.initState();
    _loadTodos(); // ←追加 SharedPreferences から読み込み
  }

  // データ読み込み処理関数を追加
  Future<void> _loadTodos() async {
    final todos = await widget.todoService.getTodos();
    setState(() {
      _todos = todos;
      _isLoading = false;
    });
  }

  // 追加画面から呼ばれる追加関数を追加
  void addTodo(Todo newTodo) async {
    setState(() => _todos.add(newTodo));
    await widget.todoService.saveTodos(_todos);
  }
  void editTodo(Todo todo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTodoScreen(
          todoService: widget.todoService, // ← これでOK！
          editingTodo: todo,
        ),
      ),
    ).then((updated) {
      if (updated == true) {
        _loadTodos(); // 編集後リスト更新
      }
    });
  }
  Future<void> _deleteTodo(Todo todo) async {
    setState(() => _todos.removeWhere((t) => t.id == todo.id));
    await widget.todoService.saveTodos(_todos);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) { // 読込中はローディングインジケーターを表示
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      itemCount: _todos.length,
      itemBuilder: (context, index) {
        final todo = _todos[index]; // ←追加
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: TodoCard(
            todo: todo,
            onToggle: () => _deleteTodo(todo), // チェックで削除する処理を追加
            onEdit: () => editTodo(todo),
          ),
          
        );  
      }
    );
  }
}