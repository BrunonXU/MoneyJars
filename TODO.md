# MoneyJars 项目问题诊断与修复清单

## 🚨 **紧急问题** (立即解决)

### 1. 架构混乱问题
- **状态**: 🔴 严重
- **问题**: 新旧架构并存，代码重复，混乱不堪
- **影响**: 严重影响维护性和稳定性
- **文件**:
  - ❌ `main.dart` vs `main_new.dart` vs `main_simple.dart` (3个入口文件)
  - ❌ `providers/transaction_provider.dart` vs `presentation/providers/transaction_provider_new.dart` (重复Provider)
  - ❌ `screens/home_screen.dart` vs `presentation/pages/home/home_page_new.dart` (重复页面)
  - ❌ 大量带`_new`后缀的文件造成混乱
- **解决方案**: 立即执行架构统一化计划

### 2. 大量未完成功能 (38个TODO)
- **状态**: 🔴 严重
- **问题**: 发现38个TODO标记，核心功能不完整
- **关键未完成功能**:
  ```
  - 数据导出/备份功能 (6个TODO)
  - 主题切换功能 (4个TODO)  
  - 分类管理系统 (8个TODO)
  - 数据迁移工具 (12个TODO)
  - 统计数据传递 (3个TODO)
  - 帮助系统 (5个TODO)
  ```
- **解决方案**: 按优先级逐一完成

### 3. 技术债务累积
- **状态**: 🟡 需要关注
- **问题**:
  - Flutter版本不是最新
  - 依赖包版本混乱  
  - 测试覆盖不足
  - 代码注释缺失

## 🔥 **高优先级任务**

### 4. 企业级安全漏洞
- **状态**: 🔴 严重
- **问题**: 缺少企业级安全功能
- **缺失功能**:
  ```
  - ❌ 数据加密存储
  - ❌ 用户身份验证
  - ❌ 本地生物识别
  - ❌ 数据备份加密
  - ❌ 审计日志功能
  - ❌ 输入数据验证
  - ❌ 防SQL注入保护
  ```
- **解决方案**: 添加完整的安全体系

### 5. 性能问题
- **状态**: 🟡 需要优化
- **问题**:
  - 缺少查询缓存机制
  - 列表滚动性能差
  - 大量不必要的Widget重建
  - 图片资源未压缩
- **解决方案**: 实施性能优化计划

### 6. 国际化支持缺失
- **状态**: 🟡 企业必需
- **问题**: 仅支持中文，限制国际化扩展
- **需要**:
  - 多语言字符串提取
  - 完整的i18n框架
  - 中英文双语支持
  - 动态语言切换

## 🎯 **架构统一化行动计划**

### 第一阶段：文件结构分析 (30分钟)
```
原始架构 → 目标架构 映射关系：

📁 入口文件:
  main.dart (保留) ← 主入口
  main_new.dart (删除) ← 测试入口
  main_simple.dart (删除) ← 简化入口

📁 页面文件:
  screens/home_screen.dart → presentation/pages/home/home_page.dart
  screens/jar_detail_page.dart → presentation/pages/detail/jar_detail_page.dart  
  screens/statistics_page.dart → presentation/pages/statistics/statistics_page.dart
  screens/help_page.dart → presentation/pages/help/help_page.dart
  screens/personalization_page.dart → presentation/pages/personalization/personalization_page.dart

📁 状态管理:
  providers/transaction_provider.dart (保留) → presentation/providers/transaction_provider.dart
  presentation/providers/transaction_provider_new.dart (删除)

📁 组件文件:
  widgets/money_jar_widget.dart → presentation/widgets/jar/money_jar_widget.dart
  widgets/drag_record_input.dart → presentation/widgets/input/drag_record_input.dart
  widgets/enhanced_transaction_input.dart → presentation/widgets/input/transaction_input.dart

📁 数据模型:
  models/transaction_record_hive.dart (保留) → core/data/models/transaction_model.dart
  core/data/models/transaction_model.dart (合并)
```

### 第二阶段：确认删除清单 (需要用户确认)
```
🗑️ 确认删除文件:
- main_new.dart
- main_simple.dart  
- presentation/providers/transaction_provider_new.dart
- presentation/pages/home/home_page_new.dart
- presentation/pages/settings/settings_page_new.dart
- presentation/widgets/input/drag_input/drag_record_input_new.dart
- 所有其他带 _new 后缀的文件

⚠️ 需要合并功能:
- transaction_provider.dart ← transaction_provider_new.dart (合并状态管理逻辑)
- home_page.dart ← home_page_new.dart (合并UI改进)
- drag_record_input.dart ← drag_record_input_new.dart (合并交互改进)
```

### 第三阶段：文件迁移 (1小时)
1. 创建新的目录结构
2. 移动文件到对应位置
3. 更新所有import语句
4. 合并重复功能代码

### 第四阶段：功能完善 (2-3小时)
1. 完成38个TODO项目
2. 实现核心缺失功能
3. 添加安全层
4. 性能优化

## 📋 **详细待办清单**

### 立即执行 (今天)
- [ ] 用户确认文件删除/合并清单
- [ ] 执行架构统一化第一阶段
- [ ] 更新UI迁移方案.md
- [ ] 创建文件迁移计划

### 本周内完成
- [ ] 完成所有TODO项目 (38个)
- [ ] 实现数据导出功能
- [ ] 添加主题切换功能
- [ ] 完善分类管理系统

### 企业级增强 (1-2周)
- [ ] 数据加密和身份验证
- [ ] 完整的错误处理系统
- [ ] 自动化测试体系
- [ ] 性能监控系统
- [ ] 国际化支持
- [ ] 安全审计和加固

## ⚠️ **风险提醒**

1. **代码备份**: 在删除任何文件前，确保功能已完整迁移
2. **渐进式迁移**: 不要一次性大改，避免引入bug  
3. **功能测试**: 每次迁移后立即测试功能完整性
4. **版本控制**: 每个阶段完成后及时提交

## 📊 **完成度目标**

- **架构统一化**: 0% → 100% (本周目标)
- **TODO完成度**: 0% → 80% (本周目标)  
- **企业级功能**: 0% → 60% (两周目标)
- **安全评分**: 30% → 90% (两周目标)

---

**🎯 下一步行动**: 请用户确认文件删除/合并清单，然后立即开始架构统一化！

*最后更新: 2025-01-21 - 问题诊断完成，等待用户确认执行计划*