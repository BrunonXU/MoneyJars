import 'app_localizations.dart';

/// English localization implementation
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([super.locale = 'en']);

  @override
  String get appTitle => 'MoneyJars';

  @override
  String get appSubtitle => 'Smart Budgeting, Easy Finance';

  // Navigation
  @override
  String get navHome => 'Home';

  @override
  String get navHelp => 'Help';

  @override
  String get navStatistics => 'Statistics';

  @override
  String get navPersonalization => 'Personalization';

  @override
  String get navSettings => 'Settings';

  // Jars
  @override
  String get jarIncome => 'Income Jar';

  @override
  String get jarExpense => 'Expense Jar';

  @override
  String get jarComprehensive => 'Comprehensive Stats';

  @override
  String get jarSettings => 'Settings';

  @override
  String get jarDetail => 'Details';

  // Transactions
  @override
  String get transactionAmount => 'Amount';

  @override
  String get transactionDescription => 'Description';

  @override
  String get transactionCategory => 'Category';

  @override
  String get transactionDate => 'Date';

  @override
  String get transactionAdd => 'Add Transaction';

  @override
  String get transactionEdit => 'Edit Transaction';

  @override
  String get transactionDelete => 'Delete Transaction';

  // Statistics
  @override
  String get statsTotal => 'Total';

  @override
  String get statsCount => 'Count';

  @override
  String get statsAverage => 'Average';

  @override
  String get statsChart => 'Charts';

  @override
  String get statsList => 'List';

  // Actions
  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionRetry => 'Retry';

  // Status
  @override
  String get statusLoading => 'Loading...';

  @override
  String get statusSuccess => 'Success';

  @override
  String get statusError => 'Error';

  @override
  String get statusEmpty => 'No Data';

  // Error Messages
  @override
  String get errorInvalidAmount => 'Please enter a valid amount';

  @override
  String get errorInvalidInput => 'Invalid input format';

  @override
  String get errorNetwork => 'Network connection failed';

  @override
  String get errorUnknown => 'Unknown error, please retry';

  // Hints
  @override
  String get hintSwipeUp => 'Swipe up to record income';

  @override
  String get hintSwipeDown => 'Swipe down to record expense';

  @override
  String get hintNoData => 'No data available. Start recording your first transaction!';

  @override
  String get hintSearchDescription => 'Search description or amount...';
}