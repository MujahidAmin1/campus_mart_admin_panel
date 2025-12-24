import 'package:campus_mart_admin/core/providers.dart';
import 'package:campus_mart_admin/features/auth/view/authscreen.dart';
import 'package:campus_mart_admin/features/drawer/drawer_view.dart';
import 'package:campus_mart_admin/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var currentUser = ref.watch(authChangesProvider); // Use this instead
    return MaterialApp(
      home: currentUser.when(
        data: (firebaseUser) =>
            firebaseUser != null ? DrawerView() : AuthScreen(),
        error: (_, __) => AuthScreen(),
        loading: () =>
            Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
    );
  }
}
