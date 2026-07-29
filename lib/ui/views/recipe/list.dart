import 'package:flutter/material.dart';
import '../../../db/type.dart';
import '../../core/nav_bottom.dart';
import '../../utils/app_strings.dart';
import '../../utils/language_provider.dart';
import 'package:provider/provider.dart';
import '../../../db/recipe.dart';
import '../../../db/db_helper.dart';
import 'add.dart';
import 'details.dart';


class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  late Future<List<Recipe>> _recipesFuture;
  final MCService _mcService = MCService();

  @override
  void initState() {
    super.initState();
    _recipesFuture = _mcService.loadRecipes();
  }

  void _refreshRecipes() {
    setState(() {
      _recipesFuture = _mcService.loadRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    return Scaffold(
      appBar: AppBar(
        title:  Text(AppStrings.get('recipe_list_title', lang)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Recipe>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading recipes: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return  Center(child: Text(AppStrings.get('no_recipes_available', lang)));
          }       
         
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
 
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const AddRecipePage()),
          );
          if (result == true) {
            _refreshRecipes();
          }
        },
        tooltip: 'Add Recipe',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
    ); 
  }
}