import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';  // ← Faltava!

import '../models/item.dart';

class DatabaseService {
    static Database? _database;
    static const String tableItens = 'itens';

    static final DatabaseService instance = DatabaseService();

    Future<Database> get database async {
        if (_database != null) return _database!;
        _database = await _initDatabase();
        return _database!;
    }

    Future<Database> _initDatabase() async {
        String path = join(await getDatabasesPath(), 'almoxarife.db');
        return await openDatabase(
            path,
            version: 1,
            onCreate: _onCreate,
        );
    }

    Future<void> _onCreate(Database db, int version) async {
        
        await db.execute('''
        CREATE TABLE $tableItens (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            codigo TEXT,
            nome TEXT,
            tipo TEXT,
            quantidade INTEGER,
            unidade TEXT,
            data_entrada TEXT,
            UNIQUE(codigo,tipo)
        )
        ''');

        await db.execute('''
        CREATE TABLE historico(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_id INTEGER,
            quantidade_alterada INTEGER,
            tipo_movimentacao TEXT, -- 'entrada' ou 'saida'
            data_movimentacao TEXT
        )
        ''');
    }

    Future<void> insertItem(Item item) async {
        final db = await database;
        await db.insert(tableItens, item.toMap());
    }

    Future<List<Item>> getItens(String? tipoAlmoxarifado) async {
        final db = await database;
        final List<Map<String, dynamic>> maps = await db.query(
            tableItens,
            where: tipoAlmoxarifado != null ? 'tipo = ?' : null,
            whereArgs: tipoAlmoxarifado != null ? [tipoAlmoxarifado] : null,
        );
        return List.generate(maps.length, (i) => Item.fromMap(maps[i]));
    }

    Future<void> updateItem(Item item) async {
        final db = await database;
        await db.update(
            tableItens,
            item.toMap(),
            where: 'id = ?',
            whereArgs: [item.id],
        );
    }
    
    Future<void> deleteItem(int id) async {
        final db = await database;
        await db.delete(
            tableItens,
            where: 'id = ?',
            whereArgs: [id]
        );
    }

    Future<List<Map<String, dynamic>>> getItensPorAlmoxarifado(String? tipoFiltro) async {
        final db = await database;

        String sql = 'SELECT nome, quantidade AS total, tipo AS tipo FROM $tableItens';
        List<dynamic> args = [];

        if(tipoFiltro != null){
            sql += ' WHERE tipo = ?';
            args.add(tipoFiltro);
        }

        sql += ' ORDER BY quantidade DESC';

        return await db.rawQuery(sql, args);
    }

    Future<void> registrarMovimentacao(int itemId, int qtdAlterada, String tipoMov) async{
        final db = await database;
        await db.insert('historico', {
            'item_id': itemId,
            'quantidade_alterada': qtdAlterada,
            'tipo_movimentacao': tipoMov,
            'data_movimentacao': DateTime.now().toIso8601String(),
        });
    }

    Future<List<Map<String, dynamic>>> getHistoricoMovimentacoes() async {
        final db = await database;

        return await db.rawQuery('''
            SELECT h.*, i.nome AS nome_item
            FROM historico h
            JOIN $tableItens i ON h.item_id = i.id
            ORDER BY h.data_movimentacao DESC
        ''');
    }
}  