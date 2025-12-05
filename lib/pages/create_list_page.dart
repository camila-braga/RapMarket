import 'package:flutter/material.dart';
import '../widgets/rap_market_page.dart';
import '../database/database.dart';

class CreateListPage extends StatefulWidget {
  const CreateListPage({super.key});

  @override
  State<CreateListPage> createState() => _CreateListPageState();
}

class _CreateListPageState extends State<CreateListPage> {
  final TextEditingController _titleController = TextEditingController();

  // Variáveis para exibir se salvou ou se o usuário esqueceu de inserir o título antes de clicar no botão
  bool _showError = false; //borda vermelha
  bool _showSuccess = false; //mensagem de sucesso com ícone de confete

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // Função para salvar no banco
  void _saveList() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, digite um título para a lista.'),
        ),
      );
      setState(() {
        _showError = true; // Ativa a borda vermelha
        _showSuccess = false;
      });

      return;
    }

    setState(() {
      _showError = false;
    });

    // Chamando o banco de dados
    await DBHelper.instance.createList(title);

    if (mounted) {
      setState(() {
        _showSuccess = true; //mensagem de sucesso com ícone de confete
      });

      // Aguarda 2.0 segundos para o usuário ver a mensagem antes de fechar
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          // Volta para a tela anterior após salvar a lista no banco de dados
          Navigator.pop(context, true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return RapMarketPage(
      title: 'RapMarket',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Título da página
              Text(
                "Cadastrar lista",
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

              // Card do Formulário
              Card(
                color: colorScheme.tertiary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Título",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                        // Remove o erro assim que o usuário começar a digitar
                        onChanged: (value) {
                          if (_showError) {
                            setState(() {
                              _showError = false;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: colorScheme.surface,
                          hintText: "Qual o título da lista?",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          // Borda padrão
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: _showError
                                ? BorderSide(
                                    color: colorScheme.error,
                                    width: 2.0,
                                  ) // Vermelho se erro
                                : BorderSide.none, // Invisível se normal
                          ),

                          // Borda quando clica para digitar (foco)
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: _showError
                                ? BorderSide(
                                    color: colorScheme.error,
                                    width: 2.0,
                                  )
                                : BorderSide.none,
                          ),

                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Botão de Cadastrar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveList,
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

              // FEEDBACK DE SUCESSO
              if (_showSuccess) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.celebration,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Lista cadastrada!",
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
