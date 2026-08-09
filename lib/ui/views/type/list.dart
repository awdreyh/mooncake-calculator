import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/database/db_helper.dart';
import '../../../data/model/type.dart';
import '../../../data/repository/type.dart';
import '../../../provider/type.dart';
import '../../core/nav_bottom.dart';
import '../../utils/app_strings.dart';
import '../../utils/language_provider.dart';
import 'add.dart';
import 'details.dart';

class TypeListPage extends StatelessWidget {
  const TypeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TypeProvider>(
      create: (_) => TypeProvider(TypeRepository(MCDatabase.instance)),
      child: const _TypeListView(),
    );
  }
}

class _TypeListView extends StatefulWidget {
  const _TypeListView({super.key});

  @override
  State<_TypeListView> createState() => _TypeListViewState();
}

class _TypeListViewState extends State<_TypeListView> {
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
      final typeProvider = Provider.of<TypeProvider>(context, listen: false);
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
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final lang = languageProvider.languageCode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.get('delete', lang) ?? 'Delete'),
        content: Text(AppStrings.get('confirm_delete', lang)?.replaceFirst('{name}', type.name) ?? 'Delete this type?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.get('cancel', lang) ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppStrings.get('delete', lang) ?? 'Delete',
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
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('types', lang) ?? 'Types'),
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
                  ? Center(child: Text(AppStrings.get('noTypes', lang) ?? 'No types yet.'))
                  : RefreshIndicator(
                      onRefresh: _loadTypes,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _types.length,
                        separatorBuilder: (context, index) => const Divider(height: 0),
                        itemBuilder: (context, index) {
                          final type = _types[index];
                          return ListTile(
                            title: Text(type.name),
                            subtitle: Text(type.category.toMap()),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
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
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AddTypePage()),
          );
          await _loadTypes();
        },
        child: const Icon(Icons.add),
        tooltip: AppStrings.get('addType', lang) ?? 'Add Type',
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
    );
  }
}
