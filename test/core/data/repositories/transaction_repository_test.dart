import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_jars/core/data/repositories/transaction_repository_impl.dart';
import 'package:money_jars/core/data/datasources/local/hive_datasource.dart';
import 'package:money_jars/core/data/models/transaction_model.dart';
import 'package:money_jars/core/domain/entities/transaction.dart';
import 'package:money_jars/core/domain/repositories/transaction_repository.dart';
import 'package:dartz/dartz.dart';

// 简单的Mock实现
class MockLocalDataSource extends Mock implements LocalDataSource {}

void main() {
  late TransactionRepositoryImpl repository;
  late MockLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockLocalDataSource();
    repository = TransactionRepositoryImpl(
      localDataSource: mockLocalDataSource,
    );
  });

  group('createTransaction', () {
    final testTransaction = Transaction(
      id: '123',
      amount: 100.0,
      description: '测试交易',
      parentCategoryId: 'cat-1',
      parentCategoryName: '购物',
      type: TransactionType.expense,
      userId: 'user-1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('当本地保存成功时返回交易', () async {
      // arrange
      when(mockLocalDataSource.addTransaction(any))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.createTransaction(testTransaction);

      // assert
      expect(result.isRight(), true);
      verify(mockLocalDataSource.addTransaction(any));
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('当本地保存失败时返回失败', () async {
      // arrange
      when(mockLocalDataSource.addTransaction(any))
          .thenThrow(Exception('保存失败'));

      // act
      final result = await repository.createTransaction(testTransaction);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('应该返回失败'),
      );
    });
  });

  group('getTransactions', () {
    final testTransactionModels = [
      TransactionModel(
        id: '1',
        amount: 100.0,
        description: '交易 1',
        parentCategoryId: 'cat-1',
        parentCategoryName: '购物',
        typeIndex: TransactionType.expense.index,
        userId: 'user-1',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TransactionModel(
        id: '2',
        amount: 200.0,
        description: '交易 2',
        parentCategoryId: 'cat-2',
        parentCategoryName: '工资',
        typeIndex: TransactionType.income.index,
        userId: 'user-1',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    test('从本地数据源返回交易列表', () async {
      // arrange
      when(mockLocalDataSource.getAllTransactions())
          .thenAnswer((_) async => testTransactionModels);

      // act
      final result = await repository.getTransactions();

      // assert
      expect(result.isRight(), true);
      verify(mockLocalDataSource.getAllTransactions());
    });

    test('当数据源为空时返回空列表', () async {
      // arrange
      when(mockLocalDataSource.getAllTransactions())
          .thenAnswer((_) async => []);

      // act
      final result = await repository.getTransactions();
      
      // assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('应该返回成功'),
        (transactions) => expect(transactions, isEmpty),
      );
    });
  });

  group('updateTransaction', () {
    final testTransaction = Transaction(
      id: '123',
      amount: 100.0,
      description: '更新的交易',
      parentCategoryId: 'cat-1',
      parentCategoryName: '购物',
      type: TransactionType.expense,
      userId: 'user-1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('当更新成功时返回成功', () async {
      // arrange
      when(mockLocalDataSource.updateTransaction(any))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.updateTransaction(testTransaction);

      // assert
      expect(result.isRight(), true);
      verify(mockLocalDataSource.updateTransaction(any));
    });
  });

  group('deleteTransaction', () {
    const testId = '123';

    test('当删除成功时返回成功', () async {
      // arrange
      when(mockLocalDataSource.deleteTransaction(any))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.deleteTransaction(testId);

      // assert
      expect(result.isRight(), true);
      verify(mockLocalDataSource.deleteTransaction(testId));
    });
  });

  group('getTransactionsByDateRange', () {
    final startDate = DateTime(2024, 1, 1);
    final endDate = DateTime(2024, 1, 31);
    final testTransactionModels = [
      TransactionModel(
        id: '1',
        amount: 100.0,
        description: '交易 1',
        parentCategoryId: 'cat-1',
        parentCategoryName: '购物',
        typeIndex: TransactionType.expense.index,
        userId: 'user-1',
        date: DateTime(2024, 1, 15),
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      ),
    ];

    test('按日期范围筛选交易', () async {
      // arrange
      when(mockLocalDataSource.getTransactionsByDateRange(any, any))
          .thenAnswer((_) async => testTransactionModels);

      // act
      final result = await repository.getTransactionsByDateRange(
        startDate,
        endDate,
      );

      // assert
      expect(result.isRight(), true);
      verify(mockLocalDataSource.getTransactionsByDateRange(
        startDate,
        endDate,
      ));
    });
  });
}