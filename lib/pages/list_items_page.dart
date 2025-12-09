import 'package:flutter/material.dart';
import '../database/database.dart';
import 'create_item_page.dart';
import '../widgets/rap_market_page.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ListItemsPage extends StatefulWidget {
  final int listId;
  final String listTitle;

  const ListItemsPage({
    super.key,
    required this.listId,
    required this.listTitle,
  });

  @override
  State<ListItemsPage> createState() => _ListItemsPageState();
}

class _ListItemsPageState extends State<ListItemsPage> {
  List<Map<String, dynamic>> items = [];
  bool _loading = true;
  late String _currentTitle;

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.listTitle;
    _refreshItems();
  }

  Future<void> _refreshItems() async {
    final data = await DBHelper.instance.getItems(widget.listId);
    List<Map<String, dynamic>> sortedItems = List.from(data);

    sortedItems.sort((a, b) {
      String categoryA = (a['category'] ?? '').toString().toLowerCase();
      String categoryB = (b['category'] ?? '').toString().toLowerCase();

      return categoryA.compareTo(categoryB);
    });

    setState(() {
      items = sortedItems;
      _loading = false;
    });
  }

  void _editListTitle() {
    final TextEditingController titleController = TextEditingController(
      text: _currentTitle,
    );
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: colorScheme.tertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Novo título",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Caixa de texto
                TextField(
                  controller: titleController,
                  cursorColor: colorScheme.secondary,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: colorScheme.surface,
                    hintText: "Escreva o título novo",
                    hintStyle: TextStyle(color: Colors.grey.shade500),

                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2.5,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.isNotEmpty) {
                          // 1. Atualiza no Banco
                          await DBHelper.instance.updateList(
                            widget.listId,
                            titleController.text,
                          );

                          // 2. Atualiza na tela atual
                          setState(() {
                            _currentTitle = titleController.text;
                          });

                          // 3. Fecha o modal
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(0),
                        backgroundColor: colorScheme.surface,
                        foregroundColor: colorScheme.primary,
                      ),
                      child: const Icon(Icons.add, size: 30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editItem(Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['name']);
    // Se preço for 0, mostra vazio na edição, senão mostra o valor
    final priceController = TextEditingController(
      text: item['price'] == 0 ? "" : item['price'].toString(),
    );
    final categoryController = TextEditingController(text: item['category']);
    final quantityController = TextEditingController(
      text: item['quantity'].toString(),
    );

    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: colorScheme.tertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            // Scroll caso o teclado cubra
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Editar Item",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1. Campo Nome
                  _buildEditTextField(nameController, "Novo nome", colorScheme),
                  const SizedBox(height: 12),

                  // Linha com Preço e Qtd
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildEditTextField(
                          priceController,
                          "Preço",
                          colorScheme,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: _buildEditTextField(
                          quantityController,
                          "Qtd",
                          colorScheme,
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 3. Campo Categoria
                  _buildEditTextField(
                    categoryController,
                    "Nova categoria",
                    colorScheme,
                  ),

                  const SizedBox(height: 20),

                  // Botão Salvar
                  Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.isNotEmpty &&
                              categoryController.text.isNotEmpty &&
                              quantityController.text.isNotEmpty) {
                            double finalPrice = 0.0;
                            if (priceController.text.isNotEmpty) {
                              finalPrice =
                                  double.tryParse(
                                    priceController.text.replaceAll(',', '.'),
                                  ) ??
                                  0.0;
                            }

                            int finalQty =
                                int.tryParse(quantityController.text) ?? 1;

                            await DBHelper.instance.updateItem(
                              item['id'],
                              nameController.text,
                              finalPrice,
                              categoryController.text,
                              finalQty,
                            );

                            Navigator.pop(context);
                            _refreshItems();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(0),
                          backgroundColor: colorScheme.surface,
                          foregroundColor: colorScheme.primary,
                        ),
                        child: const Icon(Icons.check, size: 30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditTextField(
    TextEditingController controller,
    String label,
    ColorScheme colorScheme, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      cursorColor: colorScheme.secondary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: colorScheme.surface,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary, width: 2.5),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
        ),
      ),
    );
  }

  double get totalComprado {
    return items.where((item) => item['is_bought'] == 1).fold(0.0, (sum, item) {
      double price = item['price'] ?? 0.0;
      int qty = item['quantity'] ?? 1;
      return sum + (price * qty);
    });
  }

  void _confirmDeleteItem(int itemId) {
    final colorScheme = Theme.of(context).colorScheme;
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
            child: Text("Excluir", style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return RapMarketPage(
      title: 'RapMarket',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //título da lista:
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _currentTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Ícone de Editar
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      onPressed: _editListTitle,
                      tooltip: "Editar título",
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Linha de Separação
                Container(
                  width: size.width * 0.65,
                  height: 2,
                  color: colorScheme.secondary,
                ),
              ],
            ),
          ),

          //lista de itens:
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                ? const Center(child: Text("Nenhum item cadastrado."))
                : SlidableAutoCloseBehavior(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final item = items[index];

                        // --- LÓGICA DE EXIBIÇÃO NO CARD ---
                        double price = item['price'] ?? 0.0;
                        int quantity = item['quantity'] ?? 1;
                        String category = item['category'] ?? '';

                        String priceDisplay = price == 0
                            ? "-"
                            : "R\$ ${price.toStringAsFixed(2)}";

                        String subtitleText =
                            "$priceDisplay \n$quantity unidades \n$category";
                        // ----------------------------------

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Slidable(
                            key: Key(item['id'].toString()),
                            groupTag: '0',

                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              extentRatio: 0.25,
                              children: [
                                SlidableAction(
                                  onPressed: (context) =>
                                      _confirmDeleteItem(item['id']),
                                  backgroundColor: colorScheme.error,
                                  foregroundColor: colorScheme.surface,
                                  icon: Icons.delete,
                                  label: 'Excluir',
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                              ],
                            ),

                            child: Card(
                              elevation: 2,
                              // 2. Zeramos a margem do card para o Slidable colar nele
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(item['name']),
                                subtitle: Text(subtitleText),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: item['is_bought'] == 1,
                                      onChanged: (value) async {
                                        await DBHelper.instance
                                            .toggleItemStatus(
                                              item['id'],
                                              item['is_bought'] == 1,
                                            );
                                        _refreshItems();
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: colorScheme.primary,
                                      ),
                                      onPressed: () => _editItem(item),
                                      tooltip: "Editar item",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),

          const SizedBox(height: 10),

          // Total comprado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: colorScheme.primary.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total comprado:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "R\$ ${totalComprado.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // Botão cadastrar item
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
                      builder: (_) => CreateItemPage(listId: widget.listId),
                    ),
                  );
                  if (result == true) _refreshItems();
                },
                child: const Text(
                  "Cadastrar item",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
