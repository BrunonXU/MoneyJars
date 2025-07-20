import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:money_jar/core/data/repositories/transaction_repository_impl.dart';
import 'package:money_jar/core/data/datasources/local/local_datasource.dart';
import 'package:money_jar/core/data/datasources/remote/remote_datasource.dart';
import 'package:money_jar/core/domain/entities/transaction.dart';
import 'package:money_jar/core/domain/repositories/transaction_repository.dart';
import 'package:money_jar/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

@GenerateMocks([LocalDataSource, RemoteDataSource])
import 'transaction_repository_test.mocks.dart';

void main() {
  late TransactionRepositoryImpl repository;
  late MockLocalDataSource mockLocalDataSource;
  late MockRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockLocalDataSource = MockLocalDataSource();
    mockRemoteDataSource = MockRemoteDataSource();
    repository = TransactionRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
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
      when(mockLocalDataSource.saveTransaction(any))
          .thenAnswer((_) async => testTransaction);

      // act
      final result = await repository.createTransaction(testTransaction);

      // assert
      expect(result, Right(testTransaction));
      verify(mockLocalDataSource.saveTransaction(testTransaction));
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('当本地保存失败时返回失败', () async {
      // arrange
      when(mockLocalDataSource.saveTransaction(any))
          .thenThrow(Exception('保存失败'));

      // act
      final result = await repository.createTransaction(testTransaction);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('应该返回失败'),
      );
    });
  });

  group('getTransactions', () {
    final testTransactions = [
      Transaction(
        id: '1',
        amount: 100.0,
        description: '交易 1',
        parentCategoryId: 'cat-1',
        parentCategoryName: '购物',
        type: TransactionType.expense,
        userId: 'user-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Transaction(
        id: '2',
        amount: 200.0,
        description: '交易 2',
        parentCategoryId: 'cat-2',
        parentCategoryName: '工资',
        type: TransactionType.income,
        userId: 'user-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    test('从缓存返回交易列表', () async {
      // arrange
      when(mockLocalDataSource.getAllTransactions())
          .thenAnswer((_) async => testTransactions);

      // act
      final result = await repository.getTransactions();

      // assert
      expect(result, Right(testTransactions));
      verify(mockLocalDataSource.getAllTransactions());
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('当缓存为空时从本地加载', () async {
      // arrange
      when(mockLocalDataSource.getAllTransactions())
          .thenAnswer((_) async => testTransactions);

      // act
      // 第一次调用 - 从本地加载
      var result = await repository.getTransactions();
      expect(result, Right(testTransactions));
      
      // 第二次调用 - 从缓存加载
      result = await repository.getTransactions();
      expect(result, Right(testTransactions));
      
      // 验证只调用了一次本地数据源
      verify(mockLocalDataSource.getAllTransactions()).called(1);
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

    test('当更新成功时返回更新后的交易', () async {
      // arrange
      when(mockLocalDataSource.updateTransaction(any))
          .thenAnswer((_) async => testTransaction);

      // act
      final result = await repository.updateTransaction(testTransaction);

      // assert
      expect(result, Right(testTransaction));
      verify(mockLocalDataSource.updateTransaction(testTransaction));
    });
  });

  group('deleteTransaction', () {
    const testId = '123';

    test('当删除成功时返回true', () async {
      // arrange
      when(mockLocalDataSource.deleteTransaction(any))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.deleteTransaction(testId);

      // assert
      expect(result, Right(true));
      verify(mockLocalDataSource.deleteTransaction(testId));
    });
  });

  group('getTransactionsByDateRange', () {
    final startDate = DateTime(2024, 1, 1);
    final endDate = DateTime(2024, 1, 31);
    final testTransactions = [
      Transaction(
        id: '1',
        amount: 100.0,
        description: '交易 1',
        parentCategoryId: 'cat-1',
        parentCategoryName: '购物',
        type: TransactionType.expense,
        userId: 'user-1',
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      ),
    ];

    test('按日期范围筛选交易', () async {
      // arrange
      when(mockLocalDataSource.getTransactionsByDateRange(any, any))
          .thenAnswer((_) async => testTransactions);

      // act
      final result = await repository.getTransactionsByDateRange(
        startDate,
        endDate,
      );

      // assert
      expect(result, Right(testTransactions));
      verify(mockLocalDataSource.getTransactionsByDateRange(
        startDate,
        endDate,
      ));
    });
  });
}