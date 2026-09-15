# MyOwnAlmoxarife

App para organizar estoque doméstico ou de pequenos setores de trabalho, com cadastro, histórico e geração de relatórios e lista de compras.

Nasceu daquela dificuldade clássica de organizar tudo numa tabela e fazer relatório manualmente — pra você não levar aquele esporro do chefe (ou do cônjuge) por falta de organização.

## Funcionalidades

**Cadastro** - Cada item recebe um código específico e pode ser separado por tipo de armazenamento. Também é possível definir a unidade de medida do item no momento do cadastro, o que já atualiza automaticamente o relatório e o histórico.

**Edição** - Além do cadastro, caso você erre alguma coisa você pode deletar a inserção, ou apenas alterar o valor ou informação que seja colocado no item, lembrando que, ao alterar a quantidade de um item no cadastro irá alterar tanto o relatório quanto a parte do histórico.

**Organização** - Assim como citado anteriormente, nesse app você pode alterar o tipo de almoxarifado que está mexendo, quer colocar as coisas de casa? Selecione o tipo caseiro. Quer colocar as coisas do escritório? Também tem isso, quer ver tudo de uma vez? Também é possível!

**Relatório** - Essa tela te permitirá ver tudo que há no seu armazém, mostrando tudo que você tem em um gráfico junto com uma espécie de "rank" mostrando do item que mais tem para o que menos tem.

**Histórico** - Você pode rastrear tudo que entrou e saiu, sabendo exatamente quando e quanto foi alterado.

**Lista de Compras** - Aqui você pode adicionar uma lista que pode ser exportada em CSV (Excel), PDF, ou até mesmo como imagem da tela — lembrando que ao exportar você também leva junto as informações do app!

## Tecnologias

**Flutter** — Desenvolvimento do app mobile, interface e lógica de navegação entre as telas de cadastro, relatório, histórico e lista de compras.

**SQFlite** — Banco de dados local, responsável por armazenar os itens cadastrados, histórico de entrada/saída e dados usados na geração dos relatórios.
