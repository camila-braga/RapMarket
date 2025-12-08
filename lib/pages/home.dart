import 'package:flutter/material.dart';
import '../widgets/rap_market_page.dart';
import '../database/database.dart';
import 'create_list_page.dart';
import 'list_items_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> myLists = [];
  bool _isLoading = true;
  int? _selectedListId;

  @override
  void initState() {
    super.initState();
    _refreshLists();
  }

  void _refreshLists() async {
    final data = await DBHelper.instance.getAllLists();
    setState(() {
      myLists = data;
      _isLoading = false;
      _selectedListId = null;
    });
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedListId == id) {
        _selectedListId = null;
      } else {
        _selectedListId = id;
      }
    });
  }

  /// ✅ Confirmação de exclusão de lista
  void _confirmDeleteList(int listId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Excluir lista"),
        content: const Text("Tem certeza que deseja excluir esta lista?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              await DBHelper.instance.deleteList(listId);
              Navigator.pop(context);
              _refreshLists();
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

    return RapMarketPage(
      title: 'RapMarket',
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : myLists.isEmpty
                    ? _buildEmptyState()
                    : _buildListState(colorScheme),
          ),

          // Botão cadastrar lista
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateListPage()),
                  );
                  if (result == true) _refreshLists();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.tertiary,
                  foregroundColor: colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Cadastrar lista",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text(
            "Bem-vindo ao RapMarket",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Suas listas aparecerão aqui.",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildListState(ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      itemCount: myLists.length,
      itemBuilder: (context, index) {
        final listData = myLists[index];
        final int id = listData['id'];
        final bool isSelected = _selectedListId == id;

        return Card(
          elevation: 2,
          color: isSelected ? colorScheme.tertiary : null,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isSelected
                ? BorderSide(color: colorScheme.primary, width: 2)
                : BorderSide.none,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onLongPress: () => _toggleSelection(id),
            onTap: () {
              if (_selectedListId != null) {
                _toggleSelection(id);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ListItemsPage(
                      listId: id,
                      listTitle: listData['title'],
                    ),
                  ),
                );
              }
            },
            leading: CircleAvatar(
              backgroundColor: colorScheme.primary,
              child: Icon(Icons.shopping_cart, color: colorScheme.surface),
            ),
            title: Text(
              listData['title'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.secondary,
              ),
            ),
            subtitle: const Text("Toque para ver itens"),

            // 🔥 Aqui está a mudança! Agora pergunta antes de excluir
            trailing: isSelected
                ? IconButton(
                    iconSize: 32,
                    icon: Icon(Icons.delete_outline, color: colorScheme.error),
                    onPressed: () => _confirmDeleteList(id),
                  )
                : Icon(Icons.arrow_forward_ios, size: 20, color: colorScheme.primary),
          ),
        );
      },
    );
  }
}
