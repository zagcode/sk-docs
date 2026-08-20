---
updatedAt: 2025-11-10T23:37:35.000Z
---

Fetch the complete documentation index at: https://developer.sankhya.com.br/llms.txt. Use this file to discover all available pages before exploring further. Append .md to any documentation page URL to get its markdown version.

# Funções utilitárias em relatórios iReport

Os relatórios formatados pelo iReport, e posteriormente executados na plataforma Sankhya, precisam de funções utilitárias que devem operar no ambiente de design e na própria aplicação.

Uma das funções mais utilizadas é a **PDES**, que está presente em pelo menos três classes,  porém sem formato adequado para uso no iReport, que dependem, em sua maioria, de recursos não disponíveis no ambiente de design.

Para resolver esse problema e criar um padrão de funções disponíveis para o iReport, criou-se a classe: **br.com.sankhya.jasperfuncs.Funcoes** onde se disponibiliza os métodos utilitários.

## Função PDES

O primeiro método implementado é o PDES, que apresenta a seguinte assinatura:

```java
public static String pdes(Connection c , String sCol, String sTable, String sWhere)
```

Essa função recebe a conexão como primeiro argumento, isso se faz  necessário para torná-la independente do chamador. Abaixo um exemplo de uso com uma expressão de campo do iReport:

```java
br.com.sankhya.jasperfuncs.Funcoes.pdes($P{REPORT_CONNECTION},
	”NOMEPARC”,”TGFPAR”,”CODPARC=” + $F{CODPARC})
```

Nota-se que o parâmetro **REPORT\_CONNECTION**  é criado automaticamente pelo iReport, e que possui referência para a conexão JDBC em uso pelo JasperReport.

Essa classe faz parte do projeto [SankhyaUtil](https://developer.sankhya.com.br/docs/sankhyautil), e portanto é necessário atualizar o iReport para download.

## Função STP

Essa função permite chamar **StoredProcedures** ou **Functions** do banco de dados dentro de relatórios formatados no iReport, de acordo com a sintaxe:

```java
br.com.sankhya.jasperfuncs.Funcoes.stp( <CONEXAO_BD>, <NOME_PROCEDURE>, 
	<PARAMETROS_DE_ENTRADA> , <TIPO_DE_RETORNO> })
```

* Detalhe dos argumentos:

  * **\<CONEXAO\_BD>**: conexão com o banco de dados usada pelo iReport. O valor será sempre\
    *$P\{REPORT\_CONNECTION}*

  * **\<NOME\_PROCEDURE>** : nome da procedure, exatamente como declarada no banco de dados.

  * **\<PARAMETROS\_DE\_ENTRADA>**: parâmetros que são passados à procedure. Na prática é uma lista de pares com tipo e valor, como observado no exemplo abaixo:

```java
new Object[]{ <TIPO_P1>, <VALOR_P1> , <TIPO_P2>, <VALOR_P2>, … , <TIPO_Pn> , <VALOR_Pn>}
```

> 📘 Informação importante
>
> No campo **\<TIPO\_Px>** pode ser “N” para numéricos, “S” para texto e “T” para datas.

* **\<TIPO\_DE\_RETORNO>**: Esse parâmetro é opcional, e só deve ser usado se a procedure retornar algum valor que o relatório utilize.

Caso haja retorno, o tipo da procedure/function, deve possuir um valor que seja equivalente ao tipo de retorno declarado para a procedure, como por exemplo:

* *java.sql.Types.DOUBLE*  (para tipos float no banco de dados)
* *java.sql.Types.INTEGER*   (para tipos int no banco de dados)
* *java.sql.Types.NUMERIC*   (para tipos number no banco de dados)

A lista completa de tipos pode ser vista em [Oracle Java - API Specification](http://download.oracle.com/javase/6/docs/api/index.html)

## Exemplos de uso

* Chamada para uma procedure com um parâmetro de entrada do tipo numérico:

```java
br.com.sankhya.jasperfuncs.Funcoes.stp( $P{REPORT_CONNECTION} ,
  ”STP_ATUALIZA_CARTA_COBRANCA”, new Object[]{ “N”, $F{NUFIN}  })
```

* Chamada para uma procedure com dois parâmetros de entrada, o primeiro numérico e o segundo texto:

```java
br.com.sankhya.jasperfuncs.Funcoes.stp( $P{REPORT_CONNECTION}, 
  “STP_ATUALIZA_CARTA_COBRANCA”, new Object[]{ “N”, $F{NUFIN} , “S”, “TESTE”} )
```

* Chamada para uma procedure com três parâmetros de entrada, o primeiro numérico, o segundo texto e o terceiro data:

```java
br.com.sankhya.jasperfuncs.Funcoes.stp( $P{REPORT_CONNECTION},
  “STP_ATUALIZA_CARTA_COBRANCA”, new Object[]{ “N”, $F{NUFIN} , “S”, 
    “TESTE”, “T”,”01/01/2011″} )
```

## Como tirar dúvidas?

Para tirar dúvidas e compartilhar informações, use a sala [Relatórios formatados](https://comunidade.sankhya.com.br/c/personalizacoes/relatorios-formatados/22) da comunidade Sankhya Developer.