import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/transaction_record_hive.dart';
import 'drag_input.dart';
import '../../config/constants.dart';
import '../../utils/modern_ui_styles.dart';

class EnhancedTransactionInput extends StatefulWidget {
  final TransactionType type;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const EnhancedTransactionInput({
    Key? key,
    required this.type,
    required this.onComplete,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<EnhancedTransactionInput> createState() => _EnhancedTransactionInputState();
}

class _EnhancedTransactionInputState extends State<EnhancedTransactionInput>
    with TickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  late AnimationController _animationController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _showDragInput = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: AppConstants.animationMedium,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: AppConstants.animationSlow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: AppConstants.curveDefault),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppConstants.curveSmooth,
    ));
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: AppConstants.curveElastic),
    );

    _animationController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showDragInput) {
      return Material(
        child: SizedBox.expand(
          child: DragRecordInput(
            type: widget.type,
            amount: double.tryParse(_amountController.text) ?? 0.0,
            description: _descriptionController.text,
            onComplete: widget.onComplete,
            onCancel: () {
              setState(() {
                _showDragInput = false;
              });
            },
          ),
        ),
      );
    }
    
    return Stack(
      children: [
        // 背景遮罩
        _buildBackgroundOverlay(),
        
        // 输入表单
        _buildInputForm(),
      ],
    );
  }

  Widget _buildBackgroundOverlay() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onCancel,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: _getBackgroundColor().withOpacity(0.9 * _fadeAnimation.value),
          ),
        );
      },
    );
  }

  Widget _buildInputForm() {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_slideAnimation, _scaleAnimation]),
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge * 0.85), // 缩小15%
                padding: const EdgeInsets.all(AppConstants.spacingXLarge * 0.85), // 缩小15%
                decoration: ModernUIStyles.elevatedCardDecoration.copyWith(
                  borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题
                    _buildTitle(),
                    
                    const SizedBox(height: AppConstants.spacingLarge),
                    
                    // 输入表单
                    _buildForm(),
                    
                    const SizedBox(height: AppConstants.spacingXLarge),
                    
                    // 操作按钮
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          decoration: BoxDecoration(
            color: _getTypeColor().withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: _getTypeColor().withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _getTypeIcon(),
            color: _getTypeColor(),
            size: AppConstants.iconMedium,
          ),
        ),
        const SizedBox(width: AppConstants.spacingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.type == TransactionType.income 
                    ? '记录收入' 
                    : '记录支出',
                style: AppConstants.titleStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.spacingXSmall),
              Text(
                '填写金额和描述信息',
                style: AppConstants.captionStyle.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.white70,
          ),
          onPressed: widget.onCancel,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 金额输入
          _buildAmountField(),
          
          const SizedBox(height: AppConstants.spacingLarge),
          
          // 描述输入
          _buildDescriptionField(),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.labelAmount,
          style: AppConstants.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        TextFormField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: ModernUIStyles.inputDecoration(
            '0.00',
            icon: Icons.attach_money,
          ).copyWith(
            prefixText: '¥ ',
            prefixStyle: AppConstants.titleStyle.copyWith(
              color: _getTypeColor(),
            ),
            hintText: '0.00',
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: _getTypeColor(),
                width: 2,
              ),
            ),
          ),
          style: AppConstants.titleStyle.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppConstants.errorInvalidAmount;
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return AppConstants.errorInvalidAmount;
            }
            return null;
          },
          autofocus: true,
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.labelDescription,
          style: AppConstants.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: ModernUIStyles.inputDecoration(
            '输入描述信息（可选）',
            icon: Icons.description,
          ).copyWith(
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: _getTypeColor(),
                width: 2,
              ),
            ),
          ),
          style: AppConstants.bodyStyle.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : widget.onCancel,
            style: ModernUIStyles.secondaryButtonStyle.copyWith(
              side: MaterialStateProperty.all(
                BorderSide(color: ModernUIStyles.accentColor.withOpacity(0.5)),
              ),
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(vertical: AppConstants.spacingLarge),
              ),
            ),
            child: Text(
              AppConstants.buttonCancel,
              style: AppConstants.bodyStyle.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingMedium),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _proceedToNext,
            style: ModernUIStyles.primaryButtonStyle.copyWith(
              backgroundColor: MaterialStateProperty.all(_getTypeColor()),
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(vertical: AppConstants.spacingLarge),
              ),
              elevation: MaterialStateProperty.all(2),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // 白色加载指示器
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppConstants.buttonNext,
                        style: AppConstants.bodyStyle.copyWith(
                          color: Colors.white, // 白色字体
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                      Icon(
                        Icons.arrow_forward,
                        size: AppConstants.iconSmall,
                        color: Colors.white, // 白色图标
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  void _proceedToNext() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 添加触觉反馈
    HapticFeedback.lightImpact();

    // 模拟加载延迟
    Future.delayed(AppConstants.animationFast, () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showDragInput = true;
        });
      }
    });
  }

  Color _getTypeColor() {
    return widget.type == TransactionType.income
        ? AppConstants.incomeColor
        : AppConstants.expenseColor;
  }

  /// 获取记录页面背景颜色（与罐头背景匹配）
  Color _getBackgroundColor() {
    return widget.type == TransactionType.income
        ? AppConstants.deepRedBackground   // 收入使用深红色背景 0xFF66120D
        : AppConstants.deepGreenBackground; // 支出使用深绿色背景 0xFF104812
  }

  IconData _getTypeIcon() {
    return widget.type == TransactionType.income
        ? Icons.trending_up
        : Icons.trending_down;
  }
} 