class Item {
    final int? id;
    final String codigo;
    final String nome;
    final String tipo;
    final int quantidade;
    final String unidade;
    final DateTime dataEntrada;

    Item({
        this.id,
        required this.codigo,
        required this.nome,
        required this.tipo,
        required this.quantidade,
        required this.unidade,
        required this.dataEntrada,
    });

    Map<String, dynamic> toMap(){
        return {
            'id': id,
            'codigo': codigo,
            'nome': nome,
            'tipo': tipo,
            'quantidade': quantidade,
            'unidade': unidade,
            'data_entrada': dataEntrada.toIso8601String(),
        };
    }

    factory Item.fromMap(Map<String, dynamic> map){
        return Item(
            id: map['id'],
            codigo: map['codigo'],
            nome: map['nome'],
            tipo: map['tipo'],
            quantidade: map['quantidade'],
            unidade: map['unidade'],
            dataEntrada: DateTime.parse(map['data_entrada']),
        );
    }
}
