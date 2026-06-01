import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../services/database_service.dart';
import 'historico_screen.dart';


class RelatorioScreen extends StatefulWidget {
    final String? tipoAlmoxarifado;
    final Future<void> Function()? onRefresh;

    const RelatorioScreen({super.key, this.tipoAlmoxarifado, this.onRefresh});

    @override
    State<RelatorioScreen> createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
    List<Map<String, dynamic>> _dadosRelatorio = [];
    final Random _random = Random();
    final Map<String, Color> _cores = {};

    @override
    void initState(){
        super.initState();
        carregarDados();
    }
    
    @override
    void didUpdateWidget(covariant RelatorioScreen oldWidget){
        super.didUpdateWidget(oldWidget);
        if (oldWidget.tipoAlmoxarifado != widget.tipoAlmoxarifado){
            carregarDados();
        }
    }

    Future<void> carregarDados() async {
        final dados = await DatabaseService.instance.getItensPorAlmoxarifado(widget.tipoAlmoxarifado);

        if (!mounted) return;
            setState(() {
                _dadosRelatorio = dados;
        });
    }

    @override
    Widget build(BuildContext context){
        return Scaffold(
            appBar: AppBar(
                title: const Text('Relatórios de Estoque'),
                actions:[
                IconButton(
                    icon: const Icon(Icons.history),
                    onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoricoScreen()),
                            );
                        },
                    ),
                ],            
            ),
            body: _dadosRelatorio.isEmpty
                ? const Center(child: Text("Sem dados para exibir"))
                : Column(
                    children: [
                        SizedBox(
                            height: 300,
                            child: PieChart(
                                PieChartData(
                                    sections: _dadosRelatorio.map((item){
                                        final nome = (item['nome'] ?? '').toString();
                                        final total = (item['total'] as num).toDouble() ?? 0;
                                        final tipo = (item['tipo'] ?? '').toString();

                                        return PieChartSectionData(
                                            value: total,
                                            title: nome,
                                            radius: 100,
                                            color: _corDoItem(nome),
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
                                    final nome = (item['nome'] ?? '').toString();
                                    final tipo = (item['tipo'] ?? '').toString();
                                    final total = (item['total'] as num?)?.toInt() ?? 0;

                                    return ListTile(
                                        leading: Icon(Icons.circle, color: _corDoItem(nome)),
                                        title: Text(nome),
                                        trailing: Text('$total un'),
                                    );
                                },
                            ),
                        ),
                    ],
                ),
        );
    }

    Color _corDoItem(String nome) {
        return _cores.putIfAbsent(nome, () {
            return Color.fromARGB(
            255,
            100 + _random.nextInt(156),
            100 + _random.nextInt(156),
            100 + _random.nextInt(156),
            );
        });
    }
}