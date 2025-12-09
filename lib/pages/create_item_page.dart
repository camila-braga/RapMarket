import 'package:flutter/material.dart';
import '../widgets/rap_market_page.dart';
import '../database/database.dart';

class CreateItemPage extends StatefulWidget {
  final int listId;

  const CreateItemPage({super.key, required this.listId});

  @override
  State<CreateItemPage> createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return RapMarketPage(
      title: "RapMarket",
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- INÍCIO DO CABEÇALHO  ---
                const SizedBox(height: 10),
                Text(
                  "Cadastrar item",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 2),

                // Linha de Separação
                Container(
                  width: size.width * 0.65,
                  height: 2,
                  color: colorScheme.secondary,
                ),
                const SizedBox(height: 32),
                // --- FIM DO CABEÇALHO ---

                // Campo Nome
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Nome do item"),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Digite o nome" : null,
                ),

                const SizedBox(height: 16),

                // Campo Preço
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Preço"),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Digite o preço";
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Campo Categoria
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: "Categoria"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Digite a categoria";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
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
                      if (_formKey.currentState!.validate()) {
                        await DBHelper.instance.addItem(
                          widget.listId,
                          nameController.text,
                          double.tryParse(
                                priceController.text.replaceAll(',', '.'),
                              ) ??
                              0.0,
                          categoryController.text,
                        );

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Item criado com sucesso!'),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            duration: const Duration(seconds: 1),
                          ),
                        );

                        Navigator.pop(context, true);
                      }
                    },
                    child: const Text(
                      "Salvar",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
