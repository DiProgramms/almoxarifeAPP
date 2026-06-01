import 'package:flutter/material.dart';

import 'cadastro_screen.dart';
import 'lista_itens_screen.dart';
import 'relatorios_screen.dart';

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

    Future <void> _recarregarTudo() async {
        if (!mounted) return;
        setState(() {
            _refreshToken++;
        });
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
                    PopupMenuButton<String>(
                        onSelected: (value) {
                            setState(() {
                                _selectedAlmoxarifado = value;
                                _refreshToken++;
                            });
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                            PopupMenuItem(value: null, child: Text('Todos')),
                            PopupMenuItem(value: 'industrial', child: Text('Industrial')),
                            PopupMenuItem(value: 'alimenticio', child: Text('Alimentício')),
                            PopupMenuItem(value: 'agropecuario', child: Text('Agropecuário')),
                        ],
                    ),
                    IconButton(
                        icon: const Icon(Icons.file_download),
                        onPressed: _exportarDados,
                    ),
                ],
            ),
            body: IndexedStack(
                index: _selectedIndex,
                children: [
                    ListaItensScreen(key: ValueKey('lista-$_refreshToken-$_selectedAlmoxarifado'), tipoAlmoxarifado: _selectedAlmoxarifado, onRefresh: _recarregarTudo),
                    RelatorioScreen(key: ValueKey('relatorio-$_refreshToken-$_selectedAlmoxarifado'), tipoAlmoxarifado: _selectedAlmoxarifado, onRefresh: _recarregarTudo),
                ],
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

    void _exportarDados() async {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exportação em desenvolvimento'))
        );
    }
}