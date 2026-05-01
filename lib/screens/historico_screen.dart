import 'package:flutter/material.dart';
import '../service/database_helper.dart';

class HistoricoScreen extends StatefulWidget {
    const HistoricoScreen({super.key});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text('Histórico de Movimentações')),
            body: FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseService.instance.getHistoricoMovimentacoes(),
                builder: (context, snapshot) {
                    if(!snapshot.hasData) return const Center(child:
                    CircularProgressIndicator());
                    final historico = snapshot.data!;

                    return ListView.builder(
                        itemCount: historico.length,
                        itemBuilder: (context, index) {
                            final item = historico[index];
                            return ListTile(
                                title: Text(item['nome_item']),
                                subtitle: Text('Tipo: ${item['tipo_movimentacao']} | Data: ${item['data_movimentacao']}'),
                                trailing: Text('${item['quantidade_alterada'] > = ? '+' : ''}${item['quantidade_alterada']}',
                                style: TextStyle(
                                    color: item['quantidade_movimentacao'] > 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold
                                    ),
                                ),
                            );
                        },
                    );
                },
            ),
        );
    }
}