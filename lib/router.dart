import 'package:bellucare/screen/call_receive.dart';
import 'package:bellucare/screen/home.dart';
import 'package:bellucare/screen/init_screen.dart';
import 'package:bellucare/screen/login/login.dart';
import 'package:bellucare/screen/login/new_user.dart';
import 'package:bellucare/screen/login/user_check.dart';
import 'package:bellucare/screen/medication.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: "/init",
  routes: [
    GoRoute(
      path: "/init",
      builder: (context, state) => const InitScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => NewUserScreen(
        state: state,
      ),
    ),
    GoRoute(
      path: '/userCheck',
      builder: (context, state) => UserCheckScreen(
        state: state,
      ),
    ),
    GoRoute(
      path: '/calling',
      builder: (context, state) => CallReceiveScreen(state: state),
    ),
    GoRoute(
      path: '/medication',
      builder: (context, state) => MedicationScreen(state: state),
    ),
  ],
);
