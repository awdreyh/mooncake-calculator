import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_strings.dart';
import '../utils/language_provider.dart';
import '../views/recipe/list.dart';
import '../views/task/list.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigationBar({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    if (index == 1) {
      var foundTaskList = false;
      Navigator.of(context).popUntil((route) {
        if (route.settings.name == 'task/list') {
          foundTaskList = true;
          return true;
        }
        return route.isFirst;
      });

      if (!foundTaskList) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const TaskListPage(),
            settings: const RouteSettings(name: 'task/list'),
          ),
        );
      }
      return;
    }

    if (index == 2) {
      var foundRecipeList = false;
      Navigator.of(context).popUntil((route) {
        if (route.settings.name == 'recipe/list') {
          foundRecipeList = true;
          return true;
        }
        return route.isFirst;
      });

      if (!foundRecipeList) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const RecipeListPage(),
            settings: const RouteSettings(name: 'recipe/list'),
          ),
        );
      }
      return;
    }

      if (index == 3) {
      var foundtTypeList = false;
      Navigator.of(context).popUntil((route) {
        if (route.settings.name == 'type/list') {
          foundtTypeList = true;
          return true;
        }
        return route.isFirst;
      });

      if (!foundtTypeList) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const RecipeListPage(),
            settings: const RouteSettings(name: 'type/list'),
          ),
        );
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Page not implemented yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey[600],
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: AppStrings.get('home', lang),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.task_alt),
          label: AppStrings.get('tasks', lang),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.restaurant),
          label: AppStrings.get('recipes', lang),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: AppStrings.get('profile', lang),
        ),
      ],
    );
  }
}
