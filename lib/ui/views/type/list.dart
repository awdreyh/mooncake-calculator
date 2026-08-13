import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/model/type.dart';
import '../../../provider/type.dart';
import '../../core/nav_bottom.dart';
import '../../utils/app_strings.dart';
import '../../utils/language_provider.dart';
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

  Future<void> _deleteType(Type type) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.get('delete', lang)),
        content: Text(
          AppStrings.get(
            'confirm_delete',
            lang,
          ).replaceFirst('{name}', type.name),
        ),
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

    if (confirmed != true) return;

    final typeProvider = Provider.of<TypeProvider>(context, listen: false);
    await typeProvider.deleteType(type.id);
    await _loadTypes();
  }

  @override
  Widget build(BuildContext context) {
    final doughTypes = _types
        .where((type) => type.category == Category.dough)
        .toList();
    final fillingTypes = _types
        .where((type) => type.category == Category.filling)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('type_list_title', lang)),
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
                  if (doughTypes.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        AppStrings.get('dough_type', lang),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: doughTypes.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 0),
                      itemBuilder: (context, index) {
                        final type = doughTypes[index];
                        return ListTile(
                          title: Text(type.name),
                          subtitle: Text(type.category.toMap()),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deleteType(type),
                          ),
                          onTap: () async {
                            await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (_) => TypeDetailsPage(type: type),
                              ),
                            );
                            await _loadTypes();
                          },
                        );
                      },
                    ),
                  ],
                  // Filling Types Section
                  if (fillingTypes.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        AppStrings.get('filling_type', lang),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: fillingTypes.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 0),
                      itemBuilder: (context, index) {
                        final type = fillingTypes[index];
                        return ListTile(
                          title: Text(type.name),
                          subtitle: Text(type.category.toMap()),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deleteType(type),
                          ),
                          onTap: () async {
                            await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (_) => TypeDetailsPage(type: type),
                              ),
                            );
                            await _loadTypes();
                          },
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(
            context,
          ).push<bool>(MaterialPageRoute(builder: (_) => const AddTypePage()));
          await _loadTypes();
        },
        child: const Icon(Icons.add),
        tooltip: AppStrings.get('addType', lang),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
    );
  }
}
