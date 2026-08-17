import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_strings.dart';
import '../utils/language_provider.dart';
import '../views/recipe/list.dart';
import '../views/task/list.dart';
import '../views/type/list.dart';
import 'app_theme.dart';

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
      var foundTypeList = false;
      Navigator.of(context).popUntil((route) {
        if (route.settings.name == 'type/list') {
          foundTypeList = true;
          return true;
        }
        return route.isFirst;
      });

      if (!foundTypeList) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const TypeListPage(),
            settings: const RouteSettings(name: 'type/list'),
          ),
        );
      }
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Page not implemented yet.')));
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    final theme = Theme.of(context).bottomNavigationBarTheme;

    final items = <({IconData icon, String label})>[
      (icon: Icons.home, label: AppStrings.get('home', lang)),
      (icon: Icons.task_alt, label: AppStrings.get('tasks', lang)),
      (icon: Icons.restaurant, label: AppStrings.get('recipes', lang)),
      (icon: Icons.category, label: AppStrings.get('type', lang)),
    ];

    return Container(
      color: theme.backgroundColor ?? AppColors.espressoLight,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => _onTap(context, i),
                    child: Container(
                      color: i == currentIndex
                          ? AppColors.textSecondary
                          : Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            items[i].icon,
                            size: i == currentIndex ? 24 : 18,
                            color: i == currentIndex
                                ? AppColors.accent
                                : Colors.white,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            items[i].label,
                            style: i == currentIndex
                                ? theme.selectedLabelStyle
                                : theme.unselectedLabelStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
