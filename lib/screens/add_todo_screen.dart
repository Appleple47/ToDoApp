import 'package:flutter/material.dart';
import 'package:mytodo/services/todo_service.dart';

import '../models/todo.dart';

// タスクの追加/編集画面を表示するクラス.
class AddTodoScreen extends StatefulWidget {
  final TodoService todoService;
  final Todo? editingTodo;                  // 編集対象のタスク(新規作成時はnull).
  const AddTodoScreen({
    super.key,
    required this.todoService,
    this.editingTodo,
  });
  @override
  State<AddTodoScreen> createState() => AddTodoScreenState();
}

class AddTodoScreenState extends State<AddTodoScreen> {
  // 入力内容を管理するコントローラ.
  final TextEditingController _titleController  = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _dateController   = TextEditingController(); // 期日表示用.
  double _currentValue = 5;
  DateTime? _selectedDate; // 選択された期日.

  // フォームの入力検証用.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isFormValid = false; // フォーム入力が完了しているか.

  @override
  void initState() {
    super.initState();
    // 編集モードな既存の内容を得る. 
    if (widget.editingTodo != null) {
      _titleController.text = widget.editingTodo!.title;
      _detailController.text = widget.editingTodo!.detail;
      _selectedDate = widget.editingTodo!.dueDate;
      _dateController.text =
          '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}';
      _currentValue = widget.editingTodo!.priority.toDouble();
    }
    // 変化後のテキストを評価.
    _titleController.addListener(_updateFormValid);
    _detailController.addListener(_updateFormValid);
  }

  // 全入力欄が埋まっているかを判定し, ボタンの有効化に反映する. 
  void _updateFormValid() {
    setState(() {
      _isFormValid =
          _titleController.text.isNotEmpty &&
          _detailController.text.isNotEmpty &&
          _selectedDate != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((widget.editingTodo == null) ? '新しいタスクを追加' : 'タスクの編集'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(                            // 入力フォーム.
          key: _formKey,
          child: Column(
            children: [
              TextFormField(                    // タイトル入力.
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'タスクのタイトル',
                  hintText: '20文字以内で入力してください',
                  border: OutlineInputBorder(),
                ),

                validator: (value) {            // タイトルの確認. 
                  if (value == null || value.isEmpty) {
                    return 'タイトルを入力してください';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(                    // 詳細の入力.
                controller: _detailController,
                decoration: const InputDecoration(
                  labelText: 'タスクの詳細',
                  hintText: '入力してください',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,                    // 入力行数の制限. 
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '詳細を入力してください';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              
              TextFormField(                    // 期日の入力. 
                controller: _dateController,
                readOnly: true,                 // キーボードを表示しない.
                decoration: const InputDecoration(
                  labelText: '期日',
                  hintText: '年/月/日',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {               // 日付選択ダイアログを開く.
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {         // 選択した日付をコントローラに反映.
                    _selectedDate = picked;
                    _dateController.text =
                        '${picked.year}/${picked.month}/${picked.day}';
                    _updateFormValid();         // 期日を選んだあともフォーム状態を再評価.
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '期日を選択してください';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              Text('優先度: ${_currentValue.toInt()}'),
              Slider(
                value: _currentValue,
                min: 0,
                max: 10,
                label: _currentValue.toInt().toString(),
                onChanged: (double value) {
                  setState(() {
                    _currentValue = value;
                  });
                },
              ),
              ElevatedButton(                 // 作成ボタン.
                onPressed: _isFormValid
                    ? () => _saveTodo()
                    : null,                   // 作成時に保存する処理を追加.
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid
                      ? const Color.fromARGB(255, 0, 0, 255)
                      : Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),                            // 入力完了.
                child: Text(
                  'タスクを追加',
                  style: TextStyle(           // テキストのスタイルの指定. 
                    color: _isFormValid ? Colors.white : Colors.grey,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveTodo() async {
    if (_formKey.currentState!.validate()) {
      final todos = await widget.todoService.getTodos();    // 既存リストを取得.

      if (widget.editingTodo != null) {                     // 編集モードに入る.
        final index = todos.indexWhere((t) => t.id == widget.editingTodo!.id);
        if (index != -1) {
          todos[index] = Todo(
            id: widget.editingTodo!.id,                     // 元のIDを使う.
            title: _titleController.text,
            detail: _detailController.text,
            dueDate: _selectedDate!,
            isCompleted: widget.editingTodo!.isCompleted,
            priority: _currentValue.toInt(),
          );
        }
      } else {
        // 入力チェック.
        // 新しいTodoを作成.
        todos.add(
          Todo(
            title: _titleController.text,
            detail: _detailController.text,
            dueDate: _selectedDate!,
            priority: _currentValue.toInt(),
          ),
        );
      }
      // 保存.
      await widget.todoService.saveTodos(todos);
      // この画面がまだ非表示にならずに残ってるか確認.
      if (!mounted) return;
      Navigator.pop(context, true); // 変更を反映.
    }
  }
}

// extension on Todo {
//   void operator []=(index, Todo newValue) {}
// }
