import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction_record.dart';
import '../widgets/drag_record_input.dart';
import '../constants/app_constants.dart';

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
            color: Colors.black.withOpacity(0.6 * _fadeAnimation.value),
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
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
                padding: const EdgeInsets.all(AppConstants.spacingXLarge),
                decoration: BoxDecoration(
                  color: AppConstants.cardColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                  boxShadow: AppConstants.shadowLarge,
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
            color: _getTypeColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
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
                  color: _getTypeColor(),
                ),
              ),
              const SizedBox(height: AppConstants.spacingXSmall),
              Text(
                '填写金额和描述信息',
                style: AppConstants.captionStyle,
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.close,
            color: AppConstants.textSecondaryColor,
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
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        TextFormField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: '0.00',
            prefixText: '¥ ',
            prefixStyle: AppConstants.titleStyle.copyWith(
              color: _getTypeColor(),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: AppConstants.dividerColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: AppConstants.dividerColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: _getTypeColor(),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppConstants.backgroundColor,
            contentPadding: const EdgeInsets.all(AppConstants.spacingLarge),
          ),
          style: AppConstants.titleStyle.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
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
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '输入描述信息（可选）',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: AppConstants.dividerColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: AppConstants.dividerColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: _getTypeColor(),
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppConstants.backgroundColor,
            contentPadding: const EdgeInsets.all(AppConstants.spacingLarge),
          ),
          style: AppConstants.bodyStyle,
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
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppConstants.textSecondaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingLarge,
              ),
            ),
            child: Text(
              AppConstants.buttonCancel,
              style: AppConstants.bodyStyle.copyWith(
                color: AppConstants.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingMedium),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _proceedToNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getTypeColor(),
              foregroundColor: AppConstants.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingLarge,
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppConstants.cardColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppConstants.buttonNext,
                        style: AppConstants.bodyStyle.copyWith(
                          color: AppConstants.cardColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                      Icon(
                        Icons.arrow_forward,
                        size: AppConstants.iconSmall,
                        color: AppConstants.cardColor,
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

  IconData _getTypeIcon() {
    return widget.type == TransactionType.income
        ? Icons.trending_up
        : Icons.trending_down;
  }
} 