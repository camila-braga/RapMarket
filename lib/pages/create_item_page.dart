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
  final TextEditingController quantityController = TextEditingController(
    text: "1",
  );
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

                // Campos Preço e Quantidade lado a lado
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Preço (Opcional)",
                          hintText: "0,00",
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Campo Quantidade
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(labelText: "Qtd"),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Qtd?";
                          return null;
                        },
                      ),
                    ),
                  ],
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
                        // Lógica do Preço: Se vazio, vira 0.0
                        double finalPrice = 0.0;
                        if (priceController.text.isNotEmpty) {
                          finalPrice =
                              double.tryParse(
                                priceController.text.replaceAll(',', '.'),
                              ) ??
                              0.0;
                        }

                        // Lógica da Quantidade
                        int finalQty =
                            int.tryParse(quantityController.text) ?? 1;

                        await DBHelper.instance.addItem(
                          widget.listId,
                          nameController.text,
                          finalPrice,
                          categoryController.text,
                          finalQty,
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
