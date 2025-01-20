import 'package:bellucare/screen/home.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter(bool needPermission) {
  return GoRouter(
    // initialLocation: needPermission ? "/permission" : "/",
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
