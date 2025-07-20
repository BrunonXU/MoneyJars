import 'package:flutter_test/flutter_test.dart';
import 'package:money_jar/core/domain/entities/category.dart';
import 'package:money_jar/core/domain/entities/transaction.dart';

void main() {
  group('Category Entity Tests', () {
    test('创建有效的分类实体', () {
      final category = Category(
        id: 'cat-1',
        name: '购物',
        type: TransactionType.expense,
        icon: 'shopping_cart',
        color: 0xFF4CAF50,
        userId: 'user-1',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(category.id, 'cat-1');
      expect(category.name, '购物');
      expect(category.type, TransactionType.expense);
      expect(category.icon, 'shopping_cart');
      expect(category.color, 0xFF4CAF50);
    });

    test('验证必填字段', () {
      expect(
        () => Category(
          id: 'cat-1',
          name: '', // 空名称
          type: TransactionType.expense,
          icon: 'shopping_cart',
          color: 0xFF4CAF50,
          userId: 'user-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        throwsAssertionError,
      );
    });

    test('测试子分类', () {
      final parentCategory = Category(
        id: 'parent-1',
        name: '购物',
        type: TransactionType.expense,
        icon: 'shopping_cart',
        color: 0xFF4CAF50,
        userId: 'user-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final subCategory = Category(
        id: 'sub-1',
        name: '日用品',
        type: TransactionType.expense,
        icon: 'home',
        color: 0xFF2196F3,
        userId: 'user-1',
        parentId: parentCategory.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(subCategory.parentId, parentCategory.id);
      expect(subCategory.parentId, 'parent-1');
    });

    test('测试默认值', () {
      final category = Category(
        id: 'cat-1',
        name: '购物',
        type: TransactionType.expense,
        icon: 'shopping_cart',
        color: 0xFF4CAF50,
        userId: 'user-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(category.isActive, true);
      expect(category.sortIndex, 0);
      expect(category.parentId, null);
    });

    test('props 比较测试', () {
      final now = DateTime.now();
      final category1 = Category(
        id: 'cat-1',
        name: '购物',
        type: TransactionType.expense,
        icon: 'shopping_cart',
        color: 0xFF4CAF50,
        userId: 'user-1',
        createdAt: now,
        updatedAt: now,
      );

      final category2 = Category(
        id: 'cat-1',
        name: '购物',
        type: TransactionType.expense,
        icon: 'shopping_cart',
        color: 0xFF4CAF50,
        userId: 'user-1',
        createdAt: now,
        updatedAt: now,
      );

      expect(category1, equals(category2));
    });

    test('copyWith 测试', () {
      final original = Category(
        id: 'cat-1',
        name: '购物',
        type: TransactionType.expense,
        icon: 'shopping_cart',
        color: 0xFF4CAF50,
        userId: 'user-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = original.copyWith(
        name: '日常购物',
        color: 0xFFFF5722,
      );

      expect(updated.name, '日常购物');
      expect(updated.color, 0xFFFF5722);
      expect(updated.id, original.id);
      expect(updated.icon, original.icon);
    });

    test('测试不同类型的分类', () {
      final incomeCategory = Category(
        id: 'income-1',
        name: '工资',
        type: TransactionType.income,
        icon: 'attach_money',
        color: 0xFF4CAF50,
        userId: 'user-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final expenseCategory = Category(
        id: 'expense-1',
        name: '餐饮',
        type: TransactionType.expense,
        icon: 'restaurant',
        color: 0xFFFF5722,
        userId: 'user-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(incomeCategory.type, TransactionType.income);
      expect(expenseCategory.type, TransactionType.expense);
      expect(incomeCategory.type, isNot(equals(expenseCategory.type)));
    });
  });
}