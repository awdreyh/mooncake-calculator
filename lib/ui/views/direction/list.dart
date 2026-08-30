import 'package:flutter/material.dart';
import 'dart:io';
import '../../../data/model/direction.dart';
import '../../../provider/direction.dart';
import '../../utils/app_strings.dart';
import '../../utils/language_provider.dart';
import 'package:provider/provider.dart';
import '../recipe/details.dart';
import '../../../provider/recipe.dart';
import 'edit.dart';

class RecipeDirectionsPage extends StatefulWidget {
  final String recipeId;
  const RecipeDirectionsPage({super.key, required this.recipeId});

  @override
  State<RecipeDirectionsPage> createState() => _RecipeDirectionsPageState();
}

class _RecipeDirectionsPageState extends State<RecipeDirectionsPage> {
  List<Direction> _directions = [];
  LanguageProvider get languageProvider => context.read<LanguageProvider>();
  String get lang => languageProvider.languageCode;
  DirectionProvider get directionProvider => context.read<DirectionProvider>();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecipeDirectionsData();
  }

  Future<void> _loadRecipeDirectionsData() async {
    try {
      final directions = await directionProvider.getDirections(
        widget.recipeId,
        lang,
      );
      setState(() {
        _directions = directions;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load directions: $e";
      });
    }
  }

  Future<void> _deleteDirections() async {
    try {
      await directionProvider.deleteDirectionsByRecipeId(widget.recipeId);
      setState(() {
        _directions.clear();
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to delete directions: $e";
      });
    }
  }

  Widget _buildDirectionsList() {
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    if (_directions.isEmpty) {
      return Center(child: Text(AppStrings.get('no_directions_available', lang)));
    }
    return ListView.builder(
      itemCount: _directions.length,
      itemBuilder: (context, index) {
        final step = _directions[index];
        final hasImage =
            step.stepImagePath != null && step.stepImagePath!.isNotEmpty;
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${AppStrings.get('Step', lang)} ${step.stepIndex}: ${step.stepTitle}",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(step.stepDescription),
                if (hasImage) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(step.stepImagePath!),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      height: 200,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('view_directions', lang)),
        actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () async {
            final updated = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    EditDirectionPage(recipeId: widget.recipeId),
              ),
            );
            if (updated == true) {
              await _loadRecipeDirectionsData();
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(AppStrings.get('confirm_delete_directions', lang),style: const TextStyle(fontSize: 16,)),
                // content: Text(AppStrings.get('confirm', lang),style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(AppStrings.get('cancel', lang)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      AppStrings.get('delete', lang),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await _deleteDirections();
              final recipe= await context.read<RecipeProvider>().loadRecipe(widget.recipeId);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailsPage(recipe: recipe!),
                ),
              );
            }
          },
        ),
      ]),
      
      body: _buildDirectionsList(),
    );
  }
}
