import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category_model.dart';
import '../../widgets/category_card.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'category_analytics_screen.dart';
import 'edit_category_sheet.dart';

/// CategoriesScreen — lists income & expense categories in two tabs,
/// with add/edit/delete and a link to category analytics.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('வகைகள்'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'செலவு'), Tab(text: 'வருமானம்')],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart_rounded),
            tooltip: 'வகை பகுப்பாய்வு',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoryAnalyticsScreen()),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryGrid(categories: categoryProvider.expenseCategories, type: 'expense'),
          _CategoryGrid(categories: categoryProvider.incomeCategories, type: 'income'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => EditCategorySheet(type: _tabController.index == 0 ? 'expense' : 'income'),
        ),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final String type;
  const _CategoryGrid({required this.categories, required this.type});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text('இன்னும் வகைகள் இல்லை'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final c = categories[index];
        return CategoryCard(
          category: c,
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => EditCategorySheet(type: type, existing: c),
          ),
          onLongPress: () => _confirmDelete(context, c),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, CategoryModel c) async {
    final categoryProvider = context.read<CategoryProvider>();
    final inUse = !categoryProvider.canDelete(c.id);

    if (!inUse) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('"${c.name}" வகையை நீக்கவா?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ரத்து')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('நீக்கு', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await categoryProvider.deleteCategory(c.id);
      }
      return;
    }

    // Category is in use — offer migration.
    final others = (type == 'income' ? categoryProvider.incomeCategories : categoryProvider.expenseCategories)
        .where((o) => o.id != c.id)
        .toList();

    if (others.isEmpty) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('நீக்க முடியாது'),
            content: Text('"${c.name}" வகை பரிவர்த்தனைகளில் பயன்படுத்தப்படுகிறது. முதலில் மற்றொரு வகையை உருவாக்கவும்.'),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('சரி'))],
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;
    final target = await showDialog<CategoryModel>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('"${c.name}" பயன்பாட்டில் உள்ளது'),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('பரிவர்த்தனைகளை இந்த வகைக்கு மாற்றவும்:'),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: others.map((o) => ListTile(
                          leading: Icon(AppConstants.iconFor(o.icon), color: AppHelpers.colorFromHex(o.color)),
                          title: Text(o.name),
                          onTap: () => Navigator.pop(ctx, o),
                        )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ரத்து'))],
      ),
    );

    if (target != null) {
      await categoryProvider.deleteAndMigrate(c.id, target.id);
    }
  }
}
