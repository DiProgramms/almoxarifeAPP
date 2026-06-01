import 'package:flutter/material.dart';
import '../services/database_service.dart';

class HistoricoScreen extends StatefulWidget {
    const HistoricoScreen({super.key});

    @override
    State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
    late Future<List<Map<String, dynamic>>> _futureHistorico;
    
    @override
    void initState() {
        super.initState();
        _futureHistorico = DatabaseService.instance.getHistoricoMovimentacoes();
    }

    Future<void> _recarregar() async {
        setState(() {
        _futureHistorico = DatabaseService.instance.getHistoricoMovimentacoes();
        });
    }
    
    
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text('Histórico de Movimentações'),
            actions: [
                IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _recarregar,
                ),
            ],
        ),
            body: FutureBuilder<List<Map<String, dynamic>>>(
                future: _futureHistorico,
                builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting){
                        return const Center(child: CircularProgressIndicator());
                    }

                    if(snapshot.hasError){
                        return Center(child: Text('Erro: ${snapshot.error}'));
                    }

                    final historico = snapshot.data ?? [];

                    if(historico.isEmpty){
                        return const Center(child: Text('Nenhuma movimentação encontrada'));
                    }

                    return ListView.builder(
                        itemCount: historico.length,
                        itemBuilder: (context, index) {
                            final item = historico[index];
                            final qtd = (item['quantidade_alterada'] as num?)?.toInt() ?? 0;


                            return ListTile(
                                title: Text((item['nome_item'] ?? '').toString()),
                                subtitle: Text('Tipo: ${item['tipo_movimentacao']} | Data: ${item['data_movimentacao']}'),
                                trailing: Text('${qtd > 0 ? '+' : ''}$qtd',
                                style: TextStyle(
                                    color: item['quantidade_alterada'] > 0 ? Colors.green : Colors.red,
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