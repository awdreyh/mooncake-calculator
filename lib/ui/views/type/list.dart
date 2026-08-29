import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/model/type.dart';
import '../../../provider/type.dart';
import '../../core/nav_bottom.dart';
import '../../utils/app_strings.dart';
import '../../utils/seeds_strings.dart';
import '../../utils/language_provider.dart';
import '../../core/app_theme.dart';
import 'add.dart';
import 'details.dart';

class TypeListPage extends StatefulWidget {
  const TypeListPage({super.key});

  @override
  State<TypeListPage> createState() => _TypeListPageState();
}

class _TypeListPageState extends State<TypeListPage> {
  LanguageProvider get languageProvider =>
      Provider.of<LanguageProvider>(context, listen: false);
  TextTheme get text => Theme.of(context).textTheme;

  String get lang => languageProvider.languageCode;
  bool _isLoading = true;
  String? _errorMessage;
  List<Type> _types = [];

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final typeProvider = context.read<TypeProvider>();
      final types = await typeProvider.loadAllTypes();
      if (!mounted) return;
      setState(() {
        _types = types;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTypeCard(BuildContext context, Type type) {
    return Card(
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => TypeDetailsPage(type: type)),
          );
          await _loadTypes();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            SeedsStrings.get(type.name, lang).isNotEmpty
                ? SeedsStrings.get(type.name, lang)
                : type.name,
            style: text.bodyLarge,
          ),
        ),
      ),
    );
  }

  Widget _buildAddCard(BuildContext context, Category category) {
    return Card(
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => AddTypePage(initialCategory: category),
            ),
          );
          await _loadTypes();
        },
        child: Container(
          color: AppColors.accentRed,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Icon(Icons.add, color: AppColors.cream),
        ),
      ),
    );
  }

  Widget _buildTypeSection(String title, List<Type> types, Category category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final type in types) _buildTypeCard(context, type),
              _buildAddCard(context, category),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final doughTypes = _types
        .where((type) => type.category == Category.dough)
        .toList();
    final fillingTypes = _types
        .where((type) => type.category == Category.filling)
        .toList();

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
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make Scaffold background transparent
        appBar: AppBar(
          title: Text(AppStrings.get('type_list_title', lang)),
          backgroundColor: Colors.transparent, // Make Scaffold background transparent
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : _types.isEmpty
            ? Center(child: Text(AppStrings.get('noTypes', lang)))
            : RefreshIndicator(
                onRefresh: _loadTypes,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    // Dough Types Section
                    _buildTypeSection(
                      AppStrings.get('dough_type', lang),

                      doughTypes,
                      Category.dough,
                    ),
                    Divider(
                      color: AppColors.borderLight,
                      thickness: 1,
                      height: 32,
                    ),
                    // Filling Types Section
                    _buildTypeSection(
                      AppStrings.get('filling_type', lang),

                      fillingTypes,
                      Category.filling,
                    ),
                  ],
                ),
              ),

        bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
      ),
    );
  }
}
