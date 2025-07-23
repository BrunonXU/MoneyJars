/*
 * 示例数据生成器 (sample_data_generator.dart)
 * 
 * 用于生成测试数据，包括：
 * - 收入交易记录
 * - 支出交易记录  
 * - 涵盖所有主要分类
 * - 最近30天的数据分布
 */

import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/transaction_record_hive.dart';

class SampleDataGenerator {
  static final _uuid = Uuid();
  static final _random = Random();

  // 收入分类和子分类
  static const Map<String, List<String>> _incomeCategories = {
    '工资收入': ['基本工资', '奖金', '绩效奖励', '年终奖'],
    '兼职收入': ['兼职工作', '临时工作', '咨询费用', '自由职业'],
    '投资收益': ['股票分红', '基金收益', '银行利息', '债券收益'],
    '其他收入': ['礼金收入', '中奖奖金', '租金收入', '副业收入'],
  };

  // 支出分类和子分类
  static const Map<String, List<String>> _expenseCategories = {
    '餐饮': ['早餐', '午餐', '晚餐', '零食', '饮品', '聚餐'],
    '交通': ['地铁', '公交', '打车', '加油', '停车费', '过路费'],
    '购物': ['服装', '电子产品', '日用品', '化妆品', '书籍', '礼品'],
    '娱乐': ['电影', '游戏', '旅游', '运动', '音乐', '演出'],
    '生活': ['房租', '水电费', '网费', '电话费', '物业费', '保险'],
    '医疗': ['挂号费', '药费', '体检', '治疗费', '保健品', '医疗器械'],
    '教育': ['学费', '培训费', '书本费', '课程费', '考试费', '学习用品'],
    '其他': ['慈善捐款', '罚款', '税费', '维修费', '意外支出', '杂费'],
  };

  // 生成示例交易数据
  static List<TransactionRecord> generateSampleData() {
    final List<TransactionRecord> records = [];
    final now = DateTime.now();

    // 生成收入数据（15条）
    for (int i = 0; i < 15; i++) {
      final category = _incomeCategories.keys.elementAt(_random.nextInt(_incomeCategories.length));
      final subCategories = _incomeCategories[category]!;
      final subCategory = subCategories[_random.nextInt(subCategories.length)];
      
      final date = _generateRandomDate(now, 30);
      records.add(TransactionRecord()
        ..id = _uuid.v4()
        ..amount = _generateIncomeAmount()
        ..description = _generateIncomeDescription(category, subCategory)
        ..parentCategory = category
        ..subCategory = subCategory
        ..type = TransactionType.income
        ..date = date
        ..isArchived = false
        ..createdAt = date
        ..updatedAt = date);
    }

    // 生成支出数据（20条）
    for (int i = 0; i < 20; i++) {
      final category = _expenseCategories.keys.elementAt(_random.nextInt(_expenseCategories.length));
      final subCategories = _expenseCategories[category]!;
      final subCategory = subCategories[_random.nextInt(subCategories.length)];
      
      final date = _generateRandomDate(now, 30);
      records.add(TransactionRecord()
        ..id = _uuid.v4()
        ..amount = _generateExpenseAmount(category)
        ..description = _generateExpenseDescription(category, subCategory)
        ..parentCategory = category
        ..subCategory = subCategory
        ..type = TransactionType.expense
        ..date = date
        ..isArchived = false
        ..createdAt = date
        ..updatedAt = date);
    }

    // 按日期排序（最新的在前）
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  // 生成收入金额（相对较大）
  static double _generateIncomeAmount() {
    final amounts = [
      3000.0, 3500.0, 4000.0, 4500.0, 5000.0,  // 工资类
      800.0, 1200.0, 1500.0, 2000.0,           // 兼职类
      150.0, 300.0, 600.0, 1000.0, 1800.0,    // 投资类
      500.0, 888.0, 1688.0, 2888.0,           // 其他类
    ];
    return amounts[_random.nextInt(amounts.length)];
  }

  // 生成支出金额（根据分类调整）
  static double _generateExpenseAmount(String category) {
    switch (category) {
      case '餐饮':
        return [15.0, 25.0, 35.0, 58.0, 88.0, 128.0][_random.nextInt(6)];
      case '交通':
        return [3.0, 5.0, 12.0, 28.0, 45.0, 80.0][_random.nextInt(6)];
      case '购物':
        return [50.0, 150.0, 300.0, 500.0, 800.0, 1200.0][_random.nextInt(6)];
      case '娱乐':
        return [30.0, 60.0, 120.0, 200.0, 350.0, 500.0][_random.nextInt(6)];
      case '生活':
        return [80.0, 150.0, 300.0, 600.0, 1200.0, 2000.0][_random.nextInt(6)];
      case '医疗':
        return [20.0, 50.0, 120.0, 280.0, 500.0, 800.0][_random.nextInt(6)];
      case '教育':
        return [100.0, 200.0, 500.0, 1000.0, 2000.0, 3000.0][_random.nextInt(6)];
      default:
        return [20.0, 50.0, 100.0, 200.0, 300.0, 500.0][_random.nextInt(6)];
    }
  }

  // 生成收入描述
  static String _generateIncomeDescription(String category, String subCategory) {
    final descriptions = {
      '工资收入': ['${_getMonthText()}工资发放', '公司${subCategory}到账', '${subCategory}收入'],
      '兼职收入': ['${subCategory}费用', '兼职${subCategory}收入', '${subCategory}报酬'],
      '投资收益': ['${subCategory}到账', '投资${subCategory}', '理财${subCategory}'],
      '其他收入': ['${subCategory}入账', '收到${subCategory}', '额外${subCategory}'],
    };
    
    final categoryDescriptions = descriptions[category] ?? ['${category}收入'];
    return categoryDescriptions[_random.nextInt(categoryDescriptions.length)];
  }

  // 生成支出描述
  static String _generateExpenseDescription(String category, String subCategory) {
    final descriptions = {
      '餐饮': ['${subCategory}消费', '在麦当劳用餐', '星巴克${subCategory}', '食堂${subCategory}'],
      '交通': ['${subCategory}费用', '滴滴${subCategory}', '地铁${subCategory}', '出行${subCategory}'],
      '购物': ['购买${subCategory}', '淘宝${subCategory}', '商场${subCategory}', '网购${subCategory}'],
      '娱乐': ['${subCategory}支出', '周末${subCategory}', '休闲${subCategory}', '娱乐${subCategory}'],
      '生活': ['${subCategory}缴费', '生活${subCategory}', '${subCategory}支出', '日常${subCategory}'],
      '医疗': ['医院${subCategory}', '${subCategory}费用', '健康${subCategory}', '医疗${subCategory}'],
      '教育': ['学习${subCategory}', '${subCategory}支出', '教育${subCategory}', '培训${subCategory}'],
      '其他': ['${subCategory}支出', '杂项${subCategory}', '意外${subCategory}', '其他${subCategory}'],
    };
    
    final categoryDescriptions = descriptions[category] ?? ['${category}支出'];
    return categoryDescriptions[_random.nextInt(categoryDescriptions.length)];
  }

  // 生成随机日期（最近N天内）
  static DateTime _generateRandomDate(DateTime now, int daysBack) {
    final daysAgo = _random.nextInt(daysBack);
    final hoursOffset = _random.nextInt(24);
    final minutesOffset = _random.nextInt(60);
    
    return now.subtract(Duration(
      days: daysAgo,
      hours: hoursOffset,
      minutes: minutesOffset,
    ));
  }

  // 获取月份文本
  static String _getMonthText() {
    final months = ['1月', '2月', '3月', '4月', '5月', '6月',
                   '7月', '8月', '9月', '10月', '11月', '12月'];
    return months[DateTime.now().month - 1];
  }

  // 检查是否需要生成示例数据（用户首次使用）
  static bool shouldGenerateSampleData(List<TransactionRecord> existingRecords) {
    // 如果没有交易记录，生成示例数据
    return existingRecords.isEmpty;
  }
}