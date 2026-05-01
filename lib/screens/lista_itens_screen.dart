import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/database_service.dart';

import 'cadastro_screen.dart';

class ListaItensScreen extends StatefulWidget {
    final String? tipoAlmoxarifado;
    const ListaItensScreen({super.key, this.tipoAlmoxarifado});

    @override
    State<ListaItensScreen> createState() => _ListaItensScreenState();
}

class _ListaItensScreenState extends State<ListaItensScreen>{
    final DatabaseService _db = DatabaseService();
    List<Item> _itens = [];
    final TextEditingController _searchController = TextEditingController();

    @override
    void initState(){
        super.initState();
        _carregarItens();
    }

    Future<void> _carregarItens() async {
        final itens = await _db.getItens(widget.tipoAlmoxarifado);
        setState((){
            _itens = itens;
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
                            prefixIcon: Icon(Icons.search),
                            suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                    _searchController.clear();
                                    _carregarItens();
                                },
                            ),
                            border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => _filtrarItens(value),
                    ),
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: _itens.length,
                        itemBuilder: (context, index) {
                            final item = _itens[index];
                            return Card(
                                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: ListTile(
                                    leading: CircleAvatar(
                                        child: Text(item.nome[0].toUpperCase()),
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

    void _filtrarItens(String query) {
        setState(() {
            _itens = _itens.where((item) =>
                item.codigo.toLowerCase().contains(query.toLowerCase()) ||
                item.nome.toLowerCase().contains(query.toLowerCase())
            ).toList();
        });
    }

    void _editarItem(BuildContext context, Item item) async {
        final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CadastroScreen(item: item),
            ),
        );

        if(resultado == true) {
            _carregarItens();
        }
    }

    Future<void> _deletarItem(int id) async {
        await _db.deleteItem(id);
        _carregarItens();
    }
}
