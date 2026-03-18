import 'package:calm_urge/widgets/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hiveService = HiveService();
  await hiveService.init();
  runApp(MyApp(hiveService: hiveService));
}

class MyApp extends StatelessWidget {
  final HiveService hiveService;
  const MyApp({super.key, required this.hiveService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: hiveService,
      child: MaterialApp(
        title: 'Harm Free App',
        theme: AppTheme.lightTheme,
        home: const MainScreen(),
      ),
    );
  }
}
