import 'package:flutter_test/flutter_test.dart';
import 'package:money_jar/core/domain/entities/transaction.dart';

void main() {
  group('Transaction Entity Tests', () {
    test('创建有效的交易实体', () {
      final transaction = Transaction(
        id: '123',
        amount: 100.0,
        description: '测试交易',
        parentCategoryId: 'cat-1',
        parentCategoryName: '购物',
        type: TransactionType.expense,
        userId: 'user-1',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(transaction.id, '123');
      expect(transaction.amount, 100.0);
      expect(transaction.description, '测试交易');
      expect(transaction.type, TransactionType.expense);
    });

    test('验证金额不能为负数', () {
      expect(
        () => Transaction(
          id: '123',
          amount: -100.0,
          description: '测试',
          parentCategoryId: 'cat-1',
          parentCategoryName: '购物',
          type: TransactionType.expense,
          userId: 'user-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        throwsAssertionError,
      );
    });

    test('验证必填字段', () {
      expect(
        () => Transaction(
          id: '123',
          amount: 100.0,
          description: '', // 空描述
          parentCategoryId: 'cat-1',
          parentCategoryName: '购物',
          type: TransactionType.expense,
          userId: 'user-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        throwsAssertionError,
      );
    });

    test('props 比较测试', () {
      final now = DateTime.now();
      final transaction1 = Transaction(
        id: '123',
        amount: 100.0,
        description: '测试',
        parentCategoryId: 'cat-1',
        parentCategoryName: '购物',
        type: TransactionType.expense,
        userId: 'user-1',
        createdAt: now,
        updatedAt: now,
      );

      final transaction2 = Transaction(
        id: '123',
        amount: 100.0,
        description: '测试',
        parentCategoryId: 'cat-1',
        parentCategoryName: '购物',
        type: TransactionType.expense,
        userId: 'user-1',
        createdAt: now,
        updatedAt: now,
      );

      expect(transaction1, equals(transaction2));
    });

    test('测试带标签和附件的交易', () {
      final transaction = Transaction(
        id: '123',
        amount: 100.0,
        description: '测试交易',
        parentCategoryId: 'cat-1',
        parentCategoryName: '购物',
        type: TransactionType.expense,
        userId: 'user-1',
        tags: ['日常', '必需品'],
        attachments: ['receipt1.jpg', 'receipt2.jpg'],
        notes: '超市购物',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(transaction.tags, hasLength(2));
      expect(transaction.tags, contains('日常'));
      expect(transaction.attachments, hasLength(2));
      expect(transaction.notes, '超市购物');
    });

    test('copyWith 测试', () {
      final original = Transaction(
        id: '123',
        amount: 100.0,
        description: '原始描述',
        parentCategoryId: 'cat-1',
        parentCategoryName: '购物',
        type: TransactionType.expense,
        userId: 'user-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = original.copyWith(
        amount: 200.0,
        description: '更新后的描述',
      );

      expect(updated.amount, 200.0);
      expect(updated.description, '更新后的描述');
      expect(updated.id, original.id);
      expect(updated.parentCategoryId, original.parentCategoryId);
    });
  });
}