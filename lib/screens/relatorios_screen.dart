import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_service.dart';

class RelatorioScreen extends StatefulWidget {
    final String? tipoAlmoxarifado;
    const RelatorioScreen({super.key, this.tipoAlmoxarifado});

    @override
    State<RelatorioScreen> createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
    List<Map<String, dynamic>> _dadosRelatorio = [];

    @override
    void initState(){
        super.initState();
        _carregarDados();
    }

    Future<void> _carregarDados() async {
        final dados = await DatabaseService.instance.getItensPorAlmoxarifado(widget.tipoAlmoxarifado);
        setState((){
            _dadosRelatorio = dados;
        });
    }

    @override
    Widget build(BuildContext context){
        return Scaffold(
            appBar: AppBar(title: const Text('Relatórios de Estoque')),
            body: _dadosRelatorio.isEmpty
                ? const Center(child: Text("Sem dados para exibir"))
                : Column(
                    children: [
                        SizedBox(
                            height: 300,
                            child: PieChart(
                                PieChartData(
                                    sections: _dadosRelatorio.map((item){
                                        return PieChartSectionData(
                                            value: (item['total'] ?? 0).toDouble(),
                                            title: (item['nome']),
                                            radius: 100,
                                            color: _corAleatoria(item['tipo']),
                                        );
                                    }).toList(),
                                ),
                            ),
                        ),
                        Expanded(
                            child: ListView.builder(
                                itemCount: _dadosRelatorio.length,
                                itemBuilder: (context,index){
                                    final item = _dadosRelatorio[index];
                                    final tipo = item['tipo'] ?? 'Indefinido';
                                    return ListTile(
                                        leading: Icon(Icons.circle, color: _corAleatoria(item['tipo'])),
                                        title: Text(item['nome']),
                                        trailing: Text('${item['total']} un'),
                                    );
                                },
                            ),
                        ),
                    ],
                ),
        );
    }

    Color _corAleatoria(String tipo) {
        if (tipo == 'industrial') return Colors.blue;
        if (tipo == 'alimenticio') return Colors.red;
        return Colors.green;
    }
}