import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moon_cake_app2/db/db_helper.dart';
import 'package:moon_cake_app2/db/repository/recipe.dart';
import 'package:moon_cake_app2/ui/utils/language_provider.dart';
import 'package:moon_cake_app2/ui/views/recipe/add.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('saving a recipe persists it to the database', (tester) async {
    final dbPath = await getDatabasesPath();
    await deleteDatabase(join(dbPath, 'mc.db'));
    final repository = RecipeRepository(MCDatabase.instance);
    await MCDatabase.instance.database;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LanguageProvider>(
            create: (_) => LanguageProvider(),
          ),
        ],
        child: MaterialApp(home: AddRecipePage()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Test Recipe');
    await tester.enterText(find.byType(TextFormField).at(1), 'Flour');
    await tester.enterText(find.byType(TextFormField).at(2), '100');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final recipes = await repository.loadAll();
    expect(recipes.any((recipe) => recipe.name == 'Test Recipe'), isTrue);
  });
}
