import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'ui/core/app_theme.dart';
import 'ui/core/app_page.dart';
import 'ui/utils/language_provider.dart';
import 'provider/type.dart';
import 'provider/task.dart';
import 'provider/recipe.dart';
import 'provider/direction.dart';

import 'data/repository/type.dart';
import 'data/repository/recipe.dart';
import 'data/repository/task.dart';
import 'data/repository/direction.dart';
import 'data/database/db_helper.dart';

import 'ui/utils/helper.dart';
import 'package:flutter/services.dart';
import 'ui/views/task/add.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(
          create: (_) => TypeProvider(TypeRepository(MCDatabase.instance)),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(TaskRepository(MCDatabase.instance)),
        ),
        ChangeNotifierProvider(
          create: (_) => RecipeProvider(RecipeRepository(MCDatabase.instance)),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              DirectionProvider(DirectionRepository(MCDatabase.instance)),
        ),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: true,
    );
    return MaterialApp(
      title: 'Moon Cake Calculator',
      theme: AppTheme.light,
      locale: languageProvider.locale,
      home: const MyHomePage(title: 'Moon Cake Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      // 1. Add decoration to the wrapping Container
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/bg.png',
          ), // Use NetworkImage('') for URLs
          fit: BoxFit.cover, // Ensures image fills the screen
        ),
      ),
      child: AppPage(    
        title: '',
        currentNavIndex: 0,
        extendBodyBehindAppBar: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 56),
                Text(
                  Helper.greeting(context),
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Theme.of(context).textTheme.headlineLarge?.color,
                  ),
                ),
                const SizedBox(height: 20),
                const AddTaskPage(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        
      ),
    );
  }
}
