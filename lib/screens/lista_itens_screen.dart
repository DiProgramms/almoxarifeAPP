import 'package:flutter/material.dart';

import '../models/item.dart';
import '../services/database_service.dart';
import 'cadastro_screen.dart';

class ListaItensScreen extends StatefulWidget {
    final String? tipoAlmoxarifado;
    final Future<void> Function()? onRefresh;

    const ListaItensScreen({super.key, this.tipoAlmoxarifado, this.onRefresh});

    @override
    State<ListaItensScreen> createState() => _ListaItensScreenState();
}

class _ListaItensScreenState extends State<ListaItensScreen>{
    final DatabaseService _db = DatabaseService();
    List<Item> _itens = [];
    List<Item> _itensOriginais = [];
    final TextEditingController _searchController = TextEditingController();

    @override
    void initState(){
        super.initState();
        carregarItens();
    }

    @override
    void didUpdateWidget(covariant ListaItensScreen oldWidget) {
        super.didUpdateWidget(oldWidget);
        if (oldWidget.tipoAlmoxarifado != widget.tipoAlmoxarifado){
            carregarItens();
        }
    }

    Future<void> carregarItens() async {
        final itens = await _db.getItens(widget.tipoAlmoxarifado);
        if (!mounted) return;
        setState((){
            _itens = itens;
            _itensOriginais = List.from(itens);
        });
    }
    
    void _filtrarItens(String query) {
        final q = query.toLowerCase();
        setState(() {
            _itens = _itensOriginais.where((item) {
                return item.codigo.toLowerCase().contains(q) || 
                    item.nome.toLowerCase().contains(q);
             }).toList();
            });
        }

    @override
    Widget build(BuildContext context){
        return Column(
            children: [
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                            labelText: 'Pesquisar por nome ou código',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                    _searchController.clear();
                                    _filtrarItens('');
                                },
                            ),
                            border: OutlineInputBorder(),
                        ),
                        onChanged: _filtrarItens,
                    ),
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: _itens.length,
                        itemBuilder: (context, index) {
                            final item = _itens[index];
                            final primeiraLetra = item.nome.isNotEmpty ? item.nome[0].toUpperCase() : '?';
                            return Card(
                                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: ListTile(
                                    leading: CircleAvatar(
                                        child: Text(primeiraLetra),
                                    ),
                                    title: Text(item.nome),
                                    subtitle: Text('${item.codigo} • ${item.quantidade} ${item.unidade}'),
                                    trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                            IconButton(
                                                icon: Icon(Icons.edit, color: Colors.orange),
                                                onPressed: () => _editarItem(context, item),
                                            ),
                                            IconButton(
                                                icon: Icon(Icons.delete, color: Colors.red),
                                                onPressed: () => _deletarItem(item.id!),
                                            ),
                                        ],
                                    ),
                                ),
                            );
                        },
                    ),
                ),
            ],
        );
    }

    void _editarItem(BuildContext context, Item item) async {
        final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CadastroScreen(item: item),
            ),
        );
        if(resultado == true) {
            await carregarItens();
            await widget.onRefresh?.call();
        }
    }

    Future<void> _deletarItem(int id) async {
        await _db.deleteItem(id);
        await carregarItens();
        await widget.onRefresh?.call();
    }
}
