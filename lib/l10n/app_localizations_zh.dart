import 'app_localizations.dart';

/// 中文本地化实现
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([super.locale = 'zh']);

  @override
  String get appTitle => 'MoneyJars';

  @override
  String get appSubtitle => '智能记账，轻松理财';

  // 导航栏
  @override
  String get navHome => '首页';

  @override
  String get navHelp => '使用指南';

  @override
  String get navStatistics => '统计分析';

  @override
  String get navPersonalization => '个性化设置';

  @override
  String get navSettings => '设置';

  // 罐头相关
  @override
  String get jarIncome => '收入罐头';

  @override
  String get jarExpense => '支出罐头';

  @override
  String get jarComprehensive => '综合统计';

  @override
  String get jarSettings => '设置';

  @override
  String get jarDetail => '详情';

  // 交易相关
  @override
  String get transactionAmount => '金额';

  @override
  String get transactionDescription => '描述';

  @override
  String get transactionCategory => '分类';

  @override
  String get transactionDate => '日期';

  @override
  String get transactionAdd => '添加交易';

  @override
  String get transactionEdit => '编辑交易';

  @override
  String get transactionDelete => '删除交易';

  // 统计相关
  @override
  String get statsTotal => '总计';

  @override
  String get statsCount => '笔数';

  @override
  String get statsAverage => '平均';

  @override
  String get statsChart => '统计';

  @override
  String get statsList => '明细';

  // 操作相关
  @override
  String get actionSave => '保存';

  @override
  String get actionCancel => '取消';

  @override
  String get actionDelete => '删除';

  @override
  String get actionEdit => '编辑';

  @override
  String get actionAdd => '添加';

  @override
  String get actionConfirm => '确认';

  @override
  String get actionRetry => '重试';

  // 状态信息
  @override
  String get statusLoading => '加载中...';

  @override
  String get statusSuccess => '成功';

  @override
  String get statusError => '错误';

  @override
  String get statusEmpty => '暂无数据';

  // 错误信息
  @override
  String get errorInvalidAmount => '请输入有效金额';

  @override
  String get errorInvalidInput => '输入格式不正确';

  @override
  String get errorNetwork => '网络连接失败';

  @override
  String get errorUnknown => '未知错误，请重试';

  // 提示信息
  @override
  String get hintSwipeUp => '向上滑动开始记录收入';

  @override
  String get hintSwipeDown => '向下滑动开始记录支出';

  @override
  String get hintNoData => '暂无数据，开始记录您的第一笔交易吧！';

  @override
  String get hintSearchDescription => '搜索描述或金额...';
}