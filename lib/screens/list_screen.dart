import 'package:flutter/material.dart';
import 'package:mytodo/screens/add_todo_screen.dart';
import 'package:mytodo/services/todo_service.dart';
import '../widgets/todo_list.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key, required this.todoService});
  final TodoService todoService;
  @override
  ListScreenState createState() => ListScreenState();
}

class ListScreenState extends State<ListScreen> {
  Key _listKey = UniqueKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODOリスト'),
        backgroundColor: const Color.fromARGB(255, 196, 241, 255),
      ),
      // Stack を使って複数の FloatingActionButton を配置する
      body: Stack(
        children: [
          // メインの Todo リスト
          TodoList(
            key: _listKey, // ←追加
            todoService: widget.todoService, // ←追加
          ),
          Positioned(
            bottom: 40,
            left: 16,
            child: FloatingActionButton.extended(
              onPressed: () async {
                // 優先度で降順ソートする
                final todos = await widget.todoService.getTodos();
                todos.sort((a, b) => b.priority.compareTo(a.priority));
                await widget.todoService.saveTodos(todos);
                setState(() {
                  _listKey = UniqueKey();
                });
              },
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.sort),
              label: const Text(
                'Sort by Priority',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),

          // 左下ボタン
          Positioned(
            bottom: 120,
            left: 16,
            child: FloatingActionButton.extended(
              onPressed: () async {
                // 締切で昇順ソートする
                final todos = await widget.todoService.getTodos();
                todos.sort((a, b) => a.dueDate.compareTo(b.dueDate));
                await widget.todoService.saveTodos(todos);
                setState(() {
                  _listKey = UniqueKey();
                });
              },
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.sort),
              label: const Text(
                'Sort by Time order',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          // 右下ボタン（新規追加）
          Positioned(
            bottom: 40,
            right: 16,
            child: FloatingActionButton(
              onPressed: () async {
                // 画面遷移し、戻ってきたら結果（新規 Todo）を受け取る
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTodoScreen(
                      todoService: widget.todoService, // ←追加
                    ),
                  ),
                );
                if (updated == true) {
                  setState(() {
                    _listKey = UniqueKey(); // 新しいキーで TodoList を再構築
                  });
                }
              },
              backgroundColor: const Color.fromARGB(255, 0, 0, 255,), // ボタン色（RGBAでも指定できます）
              foregroundColor: Colors.white,
              child: const Icon(Icons.add), // Flutter標準の「＋」アイコン
            ),
          ),
        ],
      ),
    );
  }
}
