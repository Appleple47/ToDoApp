import 'package:uuid/uuid.dart';  // 一意なIDを生成するライブラリ

class Todo {
  final String id;          // 各タスクの固有識別番号
  final String title;       // タスクのタイトル
  final String detail;      // タスクの詳細
  final DateTime dueDate;   // 期日
  final bool isCompleted;   // 完了したかどうか
  final int priority;
  Todo({
    String? id,                       // IDが指定されない場合は自動生成
    required this.title,              // タイトルは必須
    required this.detail,             // 詳細も必須
    required this.dueDate,            // 期日も必須
    this.isCompleted = false,         // デフォルトは「未完了」
    this.priority = 1000,
  }) : id = id ?? const Uuid().v4();  // IDの自動生成

  // 既存のTodoを一部変更したコピーを作成するメソッド
  Todo copyWith({
    String? title,
    String? detail,
    DateTime? dueDate,
    bool? isCompleted,
    int? priority,
  }) {
    return Todo(
      id: id,                                       // IDは変更しない
      title: title ?? this.title,                   // 新しいタイトル or 元のタイトル
      detail: detail ?? this.detail,                // 新しい詳細 or 元の詳細
      dueDate: dueDate ?? this.dueDate,             // 新しい期日 or 元の期日は変更しない
      isCompleted: isCompleted ?? this.isCompleted, // 新しい状態 or 元の状態
      priority: priority ?? this.priority,
    );
  }

  indexWhere(bool Function(dynamic t) param0) {}

  void add(Todo todo) {}
}