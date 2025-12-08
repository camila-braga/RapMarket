import 'package:flutter/material.dart';
import '../database/database.dart';
import 'create_item_page.dart';

class ListItemsPage extends StatefulWidget {
  final int listId;
  final String listTitle;

  const ListItemsPage({super.key, required this.listId, required this.listTitle});

  @override
  State<ListItemsPage> createState() => _ListItemsPageState();
}

class _ListItemsPageState extends State<ListItemsPage> {
  List<Map<String, dynamic>> items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  Future<void> _refreshItems() async {
    final data = await DBHelper.instance.getItems(widget.listId);
    setState(() {
      items = data;
      _loading = false;
    });
  }

  double get totalComprado {
    return items
        .where((item) => item['is_bought'] == 1)
        .fold(0.0, (sum, item) => sum + item['price']);
  }

  void _confirmDeleteItem(int itemId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar exclusão"),
        content: const Text("Tem certeza que deseja excluir este item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              await DBHelper.instance.deleteItem(itemId);
              Navigator.pop(context);
              _refreshItems();
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.listTitle)),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? const Center(child: Text("Nenhum item cadastrado."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (_, index) {
                          final item = items[index];
                          return Card(
                            child: ListTile(
                              title: Text(item['name']),
                              subtitle: Text(
                                  "Preço: R\$ ${item['price'].toStringAsFixed(2)} — Categoria: ${item['category']}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // ✅ Checkbox de comprado
                                  Checkbox(
                                    value: item['is_bought'] == 1,
                                    onChanged: (value) async {
                                      await DBHelper.instance.toggleItemStatus(
                                        item['id'],
                                        item['is_bought'] == 1,
                                      );
                                      _refreshItems();
                                    },
                                  ),
                                  // ✅ Botão de lixeira
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _confirmDeleteItem(item['id']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Total comprado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: colorScheme.primary.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total comprado:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "R\$ ${totalComprado.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),

          // Botão de cadastrar item
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.tertiary,
                  foregroundColor: colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CreateItemPage(listId: widget.listId)),
                  );
                  if (result == true) _refreshItems();
                },
                child: const Text(
                  "Cadastrar item",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
