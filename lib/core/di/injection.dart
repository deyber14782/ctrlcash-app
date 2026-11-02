import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../network/api_client.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/get_profile.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/expenses/data/datasources/expenses_remote_datasource.dart';
import '../../features/expenses/data/repositories/expenses_repository_impl.dart';
import '../../features/expenses/domain/repositories/expenses_repository.dart';
import '../../features/expenses/domain/usecases/get_expenses.dart';
import '../../features/expenses/domain/usecases/create_expense.dart';
import '../../features/expenses/domain/usecases/delete_expense.dart';
import '../../features/auth/domain/usecases/complete_financial_profile.dart';
import '../../features/income/data/datasources/income_remote_datasource.dart';
import '../../features/income/data/repositories/income_repository_impl.dart';
import '../../features/income/domain/repositories/income_repository.dart';
import '../../features/income/domain/usecases/get_income.dart';
import '../../features/income/domain/usecases/create_income.dart';
import '../../features/income/domain/usecases/delete_income.dart';
import '../../features/education/data/datasources/education_remote_datasource.dart';
import '../../features/education/data/repositories/education_repository_impl.dart';
import '../../features/education/domain/repositories/education_repository.dart';
import '../../features/education/domain/usecases/get_feed.dart';
import '../../features/education/domain/usecases/create_text_content.dart';
import '../../features/education/domain/usecases/create_image_content.dart';
import '../../features/debts/data/datasources/debts_remote_datasource.dart';
import '../../features/debts/data/repositories/debts_repository_impl.dart';
import '../../features/debts/domain/repositories/debts_repository.dart';
import '../../features/debts/domain/usecases/get_debts.dart';
import '../../features/debts/domain/usecases/create_debt.dart';
import '../../features/debts/domain/usecases/get_amortization.dart';
import '../../features/debts/domain/usecases/delete_debt.dart';
import '../../features/reports/data/datasources/reports_remote_datasource.dart';
import '../../features/reports/data/repositories/reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/reports/domain/usecases/get_reports.dart';
import '../../features/reports/domain/usecases/get_analysis.dart';
import '../../features/assistant/data/datasources/assistant_remote_datasource.dart';
import '../../features/assistant/data/repositories/assistant_repository_impl.dart';
import '../../features/assistant/domain/repositories/assistant_repository.dart';
import '../../features/assistant/domain/usecases/get_history.dart';
import '../../features/assistant/domain/usecases/send_message.dart';
import '../../features/auth/domain/usecases/update_profile.dart';
import '../../features/auth/domain/usecases/send_password_reset.dart';
import '../../features/auth/domain/usecases/change_password.dart';
import '../../features/expenses/domain/usecases/update_expense.dart';
import '../../features/income/domain/usecases/update_income.dart';
import '../../features/debts/domain/usecases/update_debt.dart';
import '../security/biometric_service.dart';
import '../notifications/notification_service.dart';
import '../../features/budgets/data/datasources/budgets_remote_datasource.dart';
import '../../features/budgets/data/repositories/budgets_repository_impl.dart';
import '../../features/budgets/domain/repositories/budgets_repository.dart';
import '../../features/budgets/domain/usecases/get_budgets.dart';
import '../../features/budgets/domain/usecases/create_budget.dart';
import '../../features/budgets/domain/usecases/delete_budget.dart';
import '../../features/savings/data/datasources/savings_remote_datasource.dart';
import '../../features/savings/data/repositories/savings_repository_impl.dart';
import '../../features/savings/domain/repositories/savings_repository.dart';
import '../../features/savings/domain/usecases/get_goals.dart';
import '../../features/savings/domain/usecases/create_goal.dart';
import '../../features/savings/domain/usecases/contribute_to_goal.dart';
import '../../features/savings/domain/usecases/delete_goal.dart';

final sl = GetIt.instance; // sl = service locator

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // ----- Feature: auth -----
  // Data
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl(), sl()),
  );
  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  // Use cases
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => CompleteFinancialProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => SendPasswordReset(sl()));
  sl.registerLazySingleton(() => ChangePassword(sl()));
  sl.registerLazySingleton<BiometricService>(() => BiometricService());

  // ----- Feature: expenses -----
  sl.registerLazySingleton<ExpensesRemoteDataSource>(
    () => ExpensesRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<ExpensesRepository>(
    () => ExpensesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetExpenses(sl()));
  sl.registerLazySingleton(() => CreateExpense(sl()));
  sl.registerLazySingleton(() => DeleteExpense(sl()));
  sl.registerLazySingleton(() => UpdateExpense(sl()));

  // ----- Feature: income -----
  sl.registerLazySingleton<IncomeRemoteDataSource>(
    () => IncomeRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<IncomeRepository>(() => IncomeRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetIncome(sl()));
  sl.registerLazySingleton(() => CreateIncome(sl()));
  sl.registerLazySingleton(() => DeleteIncome(sl()));
  sl.registerLazySingleton(() => UpdateIncome(sl()));

  // ----- Feature: education -----
  sl.registerLazySingleton<EducationRemoteDataSource>(
    () => EducationRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<EducationRepository>(
    () => EducationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetFeed(sl()));
  sl.registerLazySingleton(() => CreateTextContent(sl()));
  sl.registerLazySingleton(() => CreateImageContent(sl()));

  // ----- Feature: debts -----
  sl.registerLazySingleton<DebtsRemoteDataSource>(
    () => DebtsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<DebtsRepository>(() => DebtsRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetDebts(sl()));
  sl.registerLazySingleton(() => CreateDebt(sl()));
  sl.registerLazySingleton(() => GetAmortization(sl()));
  sl.registerLazySingleton(() => DeleteDebt(sl()));
  sl.registerLazySingleton(() => UpdateDebt(sl()));

  // ----- Feature: reports -----
  sl.registerLazySingleton<ReportsRemoteDataSource>(
    () => ReportsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetReports(sl()));
  sl.registerLazySingleton(() => GetAnalysis(sl()));

  // ----- Feature: assistant -----

  sl.registerLazySingleton<AssistantRemoteDataSource>(
    () => AssistantRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<AssistantRepository>(
    () => AssistantRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetHistory(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));

  // ----- Feature: notifications -----
  sl.registerLazySingleton<NotificationService>(() => NotificationService());

  // ----- Feature: budgets -----
  sl.registerLazySingleton<BudgetsRemoteDataSource>(
    () => BudgetsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<BudgetsRepository>(
    () => BudgetsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetBudgets(sl()));
  sl.registerLazySingleton(() => CreateBudget(sl()));
  sl.registerLazySingleton(() => DeleteBudget(sl()));

  // ----- Feature: savings -----
  sl.registerLazySingleton<SavingsRemoteDataSource>(
    () => SavingsRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<SavingsRepository>(
    () => SavingsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetGoals(sl()));
  sl.registerLazySingleton(() => CreateGoal(sl()));
  sl.registerLazySingleton(() => ContributeToGoal(sl()));
  sl.registerLazySingleton(() => DeleteGoal(sl()));
}
