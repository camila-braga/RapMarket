import 'package:flutter/material.dart';
import '../widgets/rap_market_page.dart';
import '../database/database.dart';
import 'create_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> myLists = [];
  bool _isLoading = true;

  int? _selectedListId; //apenas 1 item pode ser selecionado por vez

  @override
  void initState() {
    super.initState();
    _refreshLists(); // Carrega as listas ao iniciar o app
  }

  // Busca os dados no SQLite
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
        _selectedListId = null; // Desmarca se clicar no mesmo
      } else {
        _selectedListId = id; // Marca o novo, desmarcando o anterior
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RapMarketPage(
      title: 'RapMarket',
      body: Column(
        children: [
          // Área principal
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  ) // ícone animado de Loading
                : myLists.isEmpty
                ? _buildEmptyState()
                : _buildListState(colorScheme),
          ),

          // Botão de cadastrar lista
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 32.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  // Navega para a página de criação
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateListPage(),
                    ),
                  );

                  // Se a lista foi craida, atualizamos a página
                  if (result == true) {
                    _refreshLists();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.tertiary,
                  foregroundColor: colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
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

  // Widget para quando NÃO há listas
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(height: 20),
          Text(
            "Bem-vindo ao RapMarket",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Suas listas aparecerão aqui.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  // Widget para quando HÁ listas
  Widget _buildListState(ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 20.0),
      itemCount: myLists.length,
      itemBuilder: (context, index) {
        // Pega a lista do banco de dados
        final listData = myLists[index];
        final int id = listData['id'];

        // Verifica se este item específico está selecionado
        final bool isSelected = _selectedListId == id;

        // Cards das listas
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),

            // Lógica de clique longo para iniciar seleção
            onLongPress: () {
              _toggleSelection(id);
            },

            onTap: () {
              // Se tiver algum selecionado, o clique muda a seleção para este
              if (_selectedListId != null) {
                _toggleSelection(id);
              } else {
                debugPrint(
                  "ID da Lista clicada: $id",
                ); //fazer o sistema de log depois
              }
            },

            leading: CircleAvatar(
              backgroundColor: colorScheme.primary,
              child: Icon(Icons.shopping_cart, color: colorScheme.surface),
            ),
            // Exibe o título vindo do banco
            title: Text(
              listData['title'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.secondary,
              ),
            ),
            subtitle: const Text("Toque para ver itens"),
            trailing: isSelected
                ? IconButton(
                    iconSize: 32,
                    icon: Icon(Icons.delete_outline, color: colorScheme.error),
                    onPressed: () {
                      debugPrint("Deletar lista $id");
                    },
                  )
                : Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: colorScheme.primary,
                  ),
          ),
        );
      },
    );
  }
}
