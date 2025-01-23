import 'package:bellucare/screen/call_receive.dart';
import 'package:bellucare/screen/home.dart';
import 'package:bellucare/screen/login.dart';
import 'package:bellucare/screen/medication.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter(bool needLogin) {
  return GoRouter(
    initialLocation: needLogin ? "/login" : "/",
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
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
}
