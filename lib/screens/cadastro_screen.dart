import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/database_service.dart';

class CadastroScreen extends StatefulWidget {
    final Item? item;
    const CadastroScreen({Key? key, this.item});

    @override
    State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
    final _formKey = GlobalKey<FormState>();
    final _codigoController = TextEditingController();
    final _nomeController = TextEditingController();
    final _quantidadeController = TextEditingController();
    final _unidadeController = TextEditingController();
    String _tipo = 'industrial';

    @override
    void initState() {
        super.initState();
        if(widget.item != null){
            _codigoController.text = widget.item!.codigo;
            _nomeController.text = widget.item!.nome;
            _quantidadeController.text = widget.item!.quantidade.toString();
            _unidadeController.text = widget.item!.unidade;
            _tipo = widget.item!.tipo;
        }
    }

    @override
    Widget build(BuildContext context){
        return Scaffold(
            appBar: AppBar(title: Text(widget.item == null ? 'Novo Item' : 'Editar Item')),
            body: Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
                    key: _formKey,
                    child: Column(
                        children: [
                            TextFormField(
                                controller: _codigoController,
                                decoration: InputDecoration(labelText: 'Código', prefixIcon: Icon(Icons.code)),
                                validator: (value) => value!.isEmpty ? 'Informe o código' : null,
                            ),
                            TextFormField(
                                controller: _nomeController,
                                decoration: InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.inventory)),
                                validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
                            ),
                            TextFormField(
                                controller: _quantidadeController,
                                decoration: InputDecoration(labelText: 'Quantidade', prefixIcon: Icon(Icons.numbers)),
                                validator: (value) => value!.isEmpty ? 'Informe a quantidade' : null,
                            ),
                            TextFormField(
                                controller: _unidadeController,
                                decoration: InputDecoration(labelText: 'Unidade', prefixIcon: Icon(Icons.scale)),
                            ),
                            DropdownButtonFormField<String>(
                                value: _tipo,
                                decoration: InputDecoration(labelText: 'Tipo', prefixIcon: Icon(Icons.category)),

                                items: [
                                DropdownMenuItem(value: 'industrial', child: Text('Industrial')),
                                DropdownMenuItem(value: 'alimenticio', child: Text('Alimentício')),
                                DropdownMenuItem(value: 'agropecuario', child: Text('Agropecuário')),
                                ],
                            onChanged: (value) => setState(() => _tipo = value!),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                                onPressed: () => _salvarItem(),
                                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                                child: Text(widget.item == null ? 'Salvar' : 'Atualizar'),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }

    Future<void> _salvarItem() async{
        if(_formKey.currentState!.validate()){
            final novaQuantidade = int.tryParse(_quantidadeController.text) ?? 0;
            final item = Item(
                id: widget.item?.id,
                codigo: _codigoController.text,
                nome: _nomeController.text,
                tipo: _tipo,
                quantidade: int.tryParse(_quantidadeController.text) ?? 0,
                unidade: _unidadeController.text,
                dataEntrada: DateTime.now(),
            );

            if(widget.item == null){
                await DatabaseService.instance.insertItem(item);
            }else{
                int diferenca = novaQuantidade - widget.item!.quantidade;

                await DatabaseService.instance.updateItem(item);
                await DatabaseService.instance.registrarMovimentacao(item.id!, diferenca, 'ajuste');
            }

            if(mounted) Navigator.pop(context, true);
        }
    }
}