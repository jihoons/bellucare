import 'package:bellucare/screen/call_receive.dart';
import 'package:bellucare/screen/home.dart';
import 'package:bellucare/screen/maintabs/medication.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter(bool needPermission) {
  return GoRouter(
    // initialLocation: needPermission ? "/permission" : "/",
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/calling',
        builder: (context, state) => CallReceiveScreen(state: state),
      ),
    ],
  );
}
