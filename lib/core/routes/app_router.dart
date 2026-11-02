import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/expenses/presentation/pages/add_expense_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import '../../features/auth/presentation/pages/complete_profile_page.dart';
import '../../features/income/presentation/pages/income_page.dart';
import '../../features/income/presentation/pages/add_income_page.dart';
import '../navigation/main_shell.dart';
import '../../features/education/presentation/pages/home_feed_page.dart';
import '../../features/profile/presentation/pages/more_page.dart';
import '../../features/profile/presentation/pages/notifications_page.dart';
import '../../features/debts/presentation/pages/debts_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/assistant/presentation/pages/assistant_page.dart';
import '../../features/budgets/presentation/pages/budgets_page.dart';
import '../../features/savings/presentation/pages/savings_goals_page.dart';

CustomTransitionPage _fade(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: _AuthRefresh(),
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashPage()),
    GoRoute(path: '/login', pageBuilder: (_, __) => _fade(const LoginPage())),
    GoRoute(
      path: '/register',
      pageBuilder: (_, __) => _fade(const RegisterPage()),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (_, __) => _fade(const OnboardingPage()),
    ),
    GoRoute(
      path: '/welcome',
      pageBuilder: (_, __) => _fade(const WelcomePage()),
    ),
    GoRoute(
      path: '/verify-email',
      pageBuilder: (_, __) => _fade(const VerifyEmailPage()),
    ),
    GoRoute(
      path: '/complete-profile',
      pageBuilder: (_, __) => _fade(const CompleteProfilePage()),
    ),

    // Pantallas que se abren ENCIMA del shell (no son pestañas)
    GoRoute(
      path: '/add-income',
      pageBuilder: (_, __) => _fade(const AddIncomePage()),
    ),
    GoRoute(
      path: '/add-expense',
      pageBuilder: (_, __) => _fade(const AddExpensePage()),
    ),
    GoRoute(path: '/income', pageBuilder: (_, __) => _fade(const IncomePage())),
    GoRoute(
      path: '/expenses',
      pageBuilder: (_, __) => _fade(const ExpensesPage()),
    ),
    GoRoute(path: '/debts', pageBuilder: (_, __) => _fade(const DebtsPage())),
    GoRoute(
      path: '/reports',
      pageBuilder: (_, __) => _fade(const ReportsPage()),
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (_, __) => _fade(const NotificationsPage()),
    ),
    GoRoute(
      path: '/budgets',
      pageBuilder: (_, __) => _fade(const BudgetsPage()),
    ),
    GoRoute(
      path: '/savings-goals',
      pageBuilder: (_, __) => _fade(const SavingsGoalsPage()),
    ),

    // Shell con barra inferior persistente
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        // Rama 0: Inicio (educación)
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeFeedPage()),
          ],
        ),
        // Rama 1: Finanzas (el dashboard real)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/finanzas',
              builder: (_, __) => const DashboardPage(),
            ),
          ],
        ),
        // Rama 2: Asistente IA — placeholder
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/asistente',
              builder: (_, __) => const AssistantPage(),
            ),
          ],
        ),
        // Rama 3: Más — placeholder
        StatefulShellBranch(
          routes: [GoRoute(path: '/mas', builder: (_, __) => const MorePage())],
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final loggedIn = user != null;
    final verified = user?.emailVerified ?? false;
    final loc = state.matchedLocation;

    if (loc == '/') return null; // splash gestiona su transición

    final publicRoutes = ['/onboarding', '/welcome', '/login', '/register'];
    final isPublic = publicRoutes.contains(loc);

    if (!loggedIn) {
      return isPublic ? null : '/login';
    }

    if (!verified) {
      return loc == '/verify-email' ? null : '/verify-email';
    }

    if (isPublic || loc == '/verify-email') return '/home';
    return null;
  },
);

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh() {
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
}
