import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mytodo/models/todo.dart'; // 日付フォーマット用パッケージ

class TodoCard extends StatelessWidget {
  final Todo todo; // 表示する Todo データ
  final VoidCallback? onToggle; // 完了トグル用コールバック（任意）
  final VoidCallback? onEdit;
  final int? priority;
  const TodoCard({
    super.key,
    required this.todo,
    this.onToggle,
    this.onEdit,
    this.priority,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(
        255,
        (5 * (10 - todo.priority)).clamp(0, 100),
        (20 * (10 - todo.priority)).clamp(0, 200),
        255, // B: 常に強い青
      ),
      // color: Colors.blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: SizedBox(
        width: double.infinity,
        height: 190,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── 左端：チェックアイコン（タップでトグル）
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  iconSize: 32,
                  icon: Icon(
                    todo.isCompleted
                        ? Icons
                              .check_circle // チェック済み
                        : Icons.radio_button_unchecked, // 未チェック
                    color: Colors.white,
                  ),
                  onPressed: onToggle,
                ),
                const SizedBox(width: 8),
                Text("finish!", style: TextStyle(color: Colors.white)),
              ],
            ),
            // ── テキスト群
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16), // ← パディングを設定
                color: const Color.fromARGB(255, 255, 247, 172),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      todo.title,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      todo.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    Text(
                      DateFormat('M月d日(E)', 'ja').format(todo.dueDate),
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    Text(
                      '優先度: ${todo.priority}', // ← 追加
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: onEdit,
                          child: Text('edit', style: TextStyle(fontSize: 20)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
