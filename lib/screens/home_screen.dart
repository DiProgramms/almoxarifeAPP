import 'package:flutter/material.dart';

import 'cadastro_screen.dart';
import 'lista_itens_screen.dart';
import 'relatorios_screen.dart';

import '../services/database_service.dart';
import '../services/export_service.dart';

class HomeScreen extends StatefulWidget {
    final bool isDarkMode;
    final Future<void> Function() onToggleTheme;

    const HomeScreen ({super.key, required this.isDarkMode, required this.onToggleTheme});

    
    @override
    State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    
    int _selectedIndex = 0;
    String? _selectedAlmoxarifado;
    int _refreshToken = 0;

    final List<Map<String, dynamic>> _listaCompras = [];
    final GlobalKey _exportKey = GlobalKey();

    Future <void> _recarregarTudo() async {
        if (!mounted) return;
        setState(() {
            _refreshToken++;
        });
    }

    Future<void> _abrirListaCompras() async {
        final nomeController = TextEditingController();
        final quantidadeController = TextEditingController();

        await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context){
                return Padding(
                    padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                    ),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            const Text('Adicionar Item à Lista',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                                controller: nomeController,
                                decoration: const InputDecoration(
                                    labelText: 'Nome do Item',
                                    border: OutlineInputBorder(),
                                ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                                controller: quantidadeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'Quantidade',
                                    border: OutlineInputBorder(),
                                ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                                onPressed: () {
                                    final nome = nomeController.text.trim();
                                    final quantidade = int.tryParse(quantidadeController.text.trim()) ?? 0;

                                    if (nome.isNotEmpty && quantidade > 0) {
                                        setState(() {
                                            _listaCompras.add({'nome': nome, 'quantidade': quantidade});
                                        });
                                    }
                                    Navigator.pop(context);
                                },
                                child: const Text('Adicionar'),
                            ),
                        ],
                    ),
                );
            },
        );
    }
    Future<void> _exportarDados() async {
        final opcao = await showModalBottomSheet<String>(
            context: context,
            builder: (context){
                return SageArea(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            const ListTile(
                                title: Text(
                                    'Escolha o formato da exportação',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                            ),
                            ListTile(
                                leading: const Icon(Icons.table_chart),
                                title: const Text('Exportar CSV'),
                                subtitle: const Text('Abrir no Excel ou planilha'),
                                onTap: () => Navigator.pop(context, 'csv'),
                            ),
                            ListTile(
                                leading: const Icon(Icons.picture_as_pdf),
                                title: const Text('Exportar PDF'),
                                subtitle: const Text('Relatório, Histórico e Lista'),
                                onTap: () => Navigator.pop(context, 'pdf'),
                            ),
                            ListTile(
                                leading: const Icon(Icons.image),
                                title: const Text('Exportar Imagem'),
                                subtitle: const Text('Compartilhar como Imagem'),
                                onTap: () => Navigator.pop(context, 'imagem'),
                            ),
                        ],
                    ),
                );
            },
        );
        if (opcao == null) return;

        try{
            final relatorio = await DatabaseService.instance.getItensPorAlmoxarifado(_selectedAlmoxarifado);

            final historico = await DatabaseService.instance.getHistoricoMovimentacoes();

            if (opcao == 'csv'){
                await ExportService.exportarCSV(
                    relatorio: relatorio,
                    historico: historico,
                    listaCompras: _listaCompras,
                );
            } else if (opcao == 'pdf') {
                await ExportService.exportarPDF(
                    relatorio: relatorio,
                    historico: historico,
                    listaCompras: _listaCompras,
                );
            } else if (opcao == 'imagem') {
                await ExportService.exportarImagem(_exportKey);
            }

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Exportação preparada com sucesso'),
                ),
            );
        } catch (e){
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Erro ao exportar: $e'),
                ),
            );
        }
    }

    @override
    Widget build(BuildContext context) {
            return Scaffold(
                appBar: AppBar(
                title: const Text('Almoxarife Pro'),
                actions: [
                    IconButton(
                        icon: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                        onPressed: widget.onToggleTheme,
                    ),
                    PopupMenuButton<String?>(
                        onSelected: (value) {
                            setState(() {
                                _selectedAlmoxarifado = value;
                                _refreshToken++;
                            });
                        },
                        itemBuilder: (BuildContext context) => const <PopupMenuItem<String?>>[
                            PopupMenuItem<String?>(value: null, child: Text('Todos')),
                            PopupMenuItem<String?>(value: 'caseiro', child: Text('Caseiro')),
                            PopupMenuItem<String?>(value: 'escritorio', child: Text('Escritório')),
                            PopupMenuItem<String?>(value: 'industrial', child: Text('Industrial')),
                            PopupMenuItem<String?>(value: 'alimenticio', child: Text('Alimentício')),
                            PopupMenuItem<String?>(value: 'agropecuario', child: Text('Agropecuário')),
                        ],
                    ),
                    IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: _abrirListaCompras,
                    ),
                    IconButton(
                        icon: const Icon(Icons.file_download),
                        onPressed: _exportarDados,
                    ),
                ],
            ),
            body: RepaintBoundary(
                key: _exportKey,
                child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                        ListaItensScreen(key: ValueKey('lista-$_refreshToken-$_selectedAlmoxarifado'), tipoAlmoxarifado: _selectedAlmoxarifado, onRefresh: _recarregarTudo),
                        RelatorioScreen(key: ValueKey('relatorio-$_refreshToken-$_selectedAlmoxarifado'), tipoAlmoxarifado: _selectedAlmoxarifado, onRefresh: _recarregarTudo),
                    ],
                ),
            ),
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
                items: const [ 
                    BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Estoque'),
                    BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Relatórios'),
                ],
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () async{
                    final value = await Navigator.push(context, MaterialPageRoute(builder: (context) => CadastroScreen()),
                    );
                    if (value == true){
                        await _recarregarTudo();
                    }
                },
                child: const Icon(Icons.add),
                backgroundColor: Colors.green,
                ),
            );
        }

    void _abrirCadastro(BuildContext context) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text('Em Desenvolvimento'),
                content: const Text('Cadastro de itens chegando!'),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
            ),
        );
    }
}