import 'package:flutter/material.dart';
import 'package:money_jar/services/storage_service.dart';
import 'package:money_jar/core/data/datasources/local/hive_datasource.dart';
import 'migration_runner.dart';

/// 迁移检查器组件
/// 在应用启动时检查并执行数据迁移
class MigrationChecker extends StatefulWidget {
  final Widget child;
  final StorageService storageService;
  final HiveLocalDataSource hiveDataSource;
  
  const MigrationChecker({
    Key? key,
    required this.child,
    required this.storageService,
    required this.hiveDataSource,
  }) : super(key: key);

  @override
  State<MigrationChecker> createState() => _MigrationCheckerState();
}

class _MigrationCheckerState extends State<MigrationChecker> {
  bool _isChecking = true;
  bool _isMigrating = false;
  String _statusMessage = '正在检查数据...';
  MigrationResult? _migrationResult;

  @override
  void initState() {
    super.initState();
    _checkAndMigrate();
  }

  Future<void> _checkAndMigrate() async {
    final runner = MigrationRunner(
      storageService: widget.storageService,
      hiveDataSource: widget.hiveDataSource,
    );

    try {
      // 检查是否需要迁移
      final needsMigration = await runner.needsMigration();
      
      if (!needsMigration) {
        setState(() {
          _isChecking = false;
        });
        return;
      }

      // 开始迁移
      setState(() {
        _isMigrating = true;
        _statusMessage = '正在迁移数据...';
      });

      final result = await runner.runFullMigration();
      
      setState(() {
        _migrationResult = result;
        _isMigrating = false;
        _isChecking = false;
      });

      // 如果迁移失败，显示错误
      if (!result.isSuccess) {
        _showMigrationError(result);
      }
    } catch (e) {
      setState(() {
        _isChecking = false;
        _isMigrating = false;
        _statusMessage = '迁移出错: $e';
      });
      _showError(e.toString());
    }
  }

  void _showMigrationError(MigrationResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('数据迁移失败'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('错误信息: ${result.errorMessage}'),
              SizedBox(height: 16),
              Text('详细日志:'),
              ...result.steps.map((step) => Padding(
                padding: EdgeInsets.only(left: 16, top: 4),
                child: Text(step, style: TextStyle(fontSize: 12)),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 继续使用旧版本
            },
            child: Text('继续使用旧版'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _checkAndMigrate(); // 重试
            },
            child: Text('重试'),
          ),
        ],
      ),
    );
  }

  void _showError(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('错误'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking || _isMigrating) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text(
                _statusMessage,
                style: TextStyle(fontSize: 16),
              ),
              if (_isMigrating && _migrationResult != null) ...[
                SizedBox(height: 16),
                Container(
                  width: 300,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _migrationResult!.steps
                        .takeLast(3)
                        .map((step) => Text(
                              step,
                              style: TextStyle(fontSize: 12),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}

/// 迁移对话框
/// 用于手动触发迁移
class MigrationDialog extends StatefulWidget {
  final StorageService storageService;
  final HiveLocalDataSource hiveDataSource;
  
  const MigrationDialog({
    Key? key,
    required this.storageService,
    required this.hiveDataSource,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required StorageService storageService,
    required HiveLocalDataSource hiveDataSource,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MigrationDialog(
        storageService: storageService,
        hiveDataSource: hiveDataSource,
      ),
    );
  }

  @override
  State<MigrationDialog> createState() => _MigrationDialogState();
}

class _MigrationDialogState extends State<MigrationDialog> {
  bool _isMigrating = false;
  MigrationResult? _result;
  final ScrollController _scrollController = ScrollController();

  Future<void> _startMigration() async {
    setState(() {
      _isMigrating = true;
    });

    final runner = MigrationRunner(
      storageService: widget.storageService,
      hiveDataSource: widget.hiveDataSource,
    );

    try {
      final result = await runner.runFullMigration();
      setState(() {
        _result = result;
        _isMigrating = false;
      });
      
      // 滚动到底部
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      setState(() {
        _isMigrating = false;
        _result = MigrationResult()
          ..isSuccess = false
          ..errorMessage = e.toString()
          ..addStep('迁移异常: $e');
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('数据迁移工具'),
      content: Container(
        width: 400,
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isMigrating && _result == null) ...[
              Text('点击下方按钮开始迁移数据到新架构。'),
              SizedBox(height: 16),
              Text('注意事项:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('- 迁移前会自动备份现有数据'),
              Text('- 迁移过程中请勿关闭应用'),
              Text('- 如果迁移失败，数据会自动回滚'),
            ],
            if (_isMigrating || _result != null) ...[
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ListView(
                    controller: _scrollController,
                    children: [
                      if (_result != null) ...[
                        Row(
                          children: [
                            Icon(
                              _result!.isSuccess ? Icons.check_circle : Icons.error,
                              color: _result!.isSuccess ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              _result!.isSuccess ? '迁移成功' : '迁移失败',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _result!.isSuccess ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        if (_result!.errorMessage != null) ...[
                          SizedBox(height: 8),
                          Text(
                            '错误: ${_result!.errorMessage}',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                        SizedBox(height: 16),
                      ],
                      ..._result?.steps.map((step) => Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(step, style: TextStyle(fontSize: 12)),
                          )) ??
                          [],
                      if (_isMigrating)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!_isMigrating && _result == null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
        if (!_isMigrating && _result == null)
          ElevatedButton(
            onPressed: _startMigration,
            child: Text('开始迁移'),
          ),
        if (_result != null)
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('完成'),
          ),
      ],
    );
  }
}