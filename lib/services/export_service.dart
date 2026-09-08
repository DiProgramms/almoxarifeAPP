import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../services/database_service.dart';

class ExportService {
    /// Exporta CSV contendo:  
    /// - Relatório
    /// - Histórico
    /// - Lista de compras
    static Future<void> exportarCSV({
        required List<Map<String, dynamic>> relatorio,
        required List<Map<String, dynamic>> historico,
        required List<Map<String, dynamic>> listaCompras,
    }) async{
        try{
            final headers = [
                'Seção',
                'Nome',
                'Quantidade',
                'Tipo',
                'Data',
                'Detalhes',
            ];
            
            final rows = <List<dynamic>>[headers];

            for (var item in relatorio){
                rows.add([
                    'Relatório',
                    item['nome'] ?? '',
                    item['total'] ?? 0,
                    item['tipo'] ?? '',
                    '',
                    '',
                ]);
            }

            for (var item in historico){
                rows.add([
                    'Histórico',
                    item['nome_item'] ?? '',
                    item['quantidade_alterada'] ?? 0,
                    item['tipo_movimentacao'] ?? '',
                    item['data_movimentacao'] ?? '',
                    '',
                ]);
            }

            for (var item in listaCompras){
                rows.add([
                    'Lista de Compras',
                    item['nome'] ?? '',
                    item['quantidade'] ?? 0,
                    '',
                    '',
                    '',
                ]);
            }

            final csv = ListToCsvConverter().convert(rows);

            final directory = await getTemporaryDirectory();
            final path = '${directory.path}/exportacao_almoxarife_${DateTime.now().millisecondsSinceEpoch}.csv';

            final file = File(path);
            await file.writeAsString(csv, encoding: utf8);

            await Share.shareXFiles([XFile(path)], subject: 'Exportação Almoxarife', text: 'Exportação Almoxarife');
        }catch (e) {
            debugPrint('Erro ao exportar CSV: $e');
        }
    }

    /// Exporta PDF contendo:
    /// - Relatório
    /// - Histórico
    /// - Lista de compras

    static Future<void> exportarPDF({
        required List<Map<String, dynamic>> relatorio,
        required List<Map<String, dynamic>> historico,
        required List<Map<String, dynamic>> listaCompras,
    }) async{
        try{
            final pdf = pw.Document();
                pdf.addPage(
                    pw.Page(
                        build: (pw.Context context){
                            return pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children:[
                                    pw.Text(
                                        'Relatório de Estoque',
                                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                                    ),
                                    pw.SizedBox(height: 10),
                                    pw.Table.fromTextArray(
                                        headers: ['Nome', 'Quantidade', 'Tipo'],
                                        data: relatorio.map((e) => [e['nome'] ?? '', (e['total'] ?? 0).toString(), e['tipo'] ?? '']).toList(),
                                    ),
                                    pw.SizedBox(height: 20),
                                    pw.Text(
                                        'Histórico de Movimentações',
                                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                                    ),
                                    pw.SizedBox(height: 10),
                                    pw.Table.fromTextArray(
                                        headers: ['Item', 'Qtd', 'Tipo', 'Data'],
                                        data: historico.map((e) => [e['nome_item'] ?? '', (e['quantidade_alterada'] ?? 0).toString(), e['tipo_movimentacao'] ?? '', e['data_movimentacao'] ?? '']).toList(),
                                    ),
                                    pw.SizedBox(height: 20),
                                    pw.Text(
                                        'Lista de Compras',
                                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                                    ),
                                    pw.SizedBox(height: 10),
                                    pw.Table.fromTextArray(
                                        headers: ['Nome', 'Quantidade'],
                                        data: listaCompras.map((e) => [e['nome'] ?? '', (e['quantidade'] ?? 0).toString()]).toList(),
                                    ),
                                ],
                            );
                        },
                    ),
                );
                final directory = await getTemporaryDirectory();
                final path = '${directory.path}/exportacao_almoxarife_${DateTime.now().millisecondsSinceEpoch}.pdf';

                final file = File(path);
                await file.writeAsBytes(await pdf.save());

                await Share.shareXFiles([XFile(path)], subject: 'Exportação Almoxarife', text: 'Exportação Almoxarife');    
            }catch (e) {
            debugPrint('Erro ao exportar PDF: $e');
        }
    }

    static Future<void> exportarImagem(GlobalKey globalKey) async{
        try{
            final boundary = globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
            if (boundary == null){
                debugPrint('Erro ao exportar');
                return;
            }
            
            final image = await boundary.toImage(pixelRatio: 3.0);
            final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
            final pngBytes = byteData?.buffer.asUint8List();
            if (pngBytes == null){
                debugPrint('Erro ao exportar');
                return;
            }

            final directory = await getTemporaryDirectory();
            final path = '${directory.path}/exportacao_almoxarife_${DateTime.now().millisecondsSinceEpoch}.png';
            final file = File(path);
            await file.writeAsBytes(pngBytes);

            await Share.shareXFiles([XFile(path)], subject: 'Exportação Almoxarife', text: 'Imagem do Relatório');
        }catch (e) {
            debugPrint('Erro ao exportar imagem: $e');
        }
    }
}