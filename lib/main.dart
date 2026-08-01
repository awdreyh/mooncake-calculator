import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'ui/core/nav_bottom.dart';
import 'ui/utils/app_strings.dart';
import 'ui/utils/language_provider.dart';

import 'ui/utils/helper.dart';
import 'package:flutter/services.dart';
import 'ui/utils/app_theme.dart';
import 'ui/views/task/add.dart';

void main() async {
  //   WidgetsFlutterBinding.ensureInitialized();

  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LanguageProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    return MaterialApp(
      title: 'Moon Cake Calculator',
      // theme: AppTheme.lightTheme,
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
  //int _counter = 0;
  final int _currentNavIndex = 0;

 
  final TextEditingController _sizeController = TextEditingController(
    text: '100',
  );


  @override
  void dispose() {
    _sizeController.dispose();
    super.dispose();
  }

 
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        //title: Text(widget.title),
        toolbarHeight: 32,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: const Color.fromARGB(
            255,
            158,
            10,
            10,
          ), // background of the top bar
          statusBarIconBrightness: Brightness.dark, // icons become white
        ),

        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (String value) {
              languageProvider.setLanguage(value);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'en',
                child: Row(
                  children: [
                    Radio<String>(
                      value: 'en',
                      groupValue: lang,
                      onChanged: (value) {
                        Navigator.pop(context);
                        languageProvider.setLanguage(value!);
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(AppStrings.get('english', lang)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'zh',
                child: Row(
                  children: [
                    Radio<String>(
                      value: 'zh',
                      groupValue: lang,
                      onChanged: (value) {
                        Navigator.pop(context);
                        languageProvider.setLanguage(value!);
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(AppStrings.get('chinese', lang)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
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

              Text(
                AppStrings.get('addNewTask', lang),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const AddTaskPage(),
              const SizedBox(height: 8),            
       
             ],
          ),
        ),
      ),

      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentNavIndex,
      ),
    );
  }


 }
