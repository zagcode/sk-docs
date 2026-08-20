---
updatedAt: 2025-11-10T23:37:33.000Z
---

Fetch the complete documentation index at: https://developer.sankhya.com.br/llms.txt. Use this file to discover all available pages before exploring further. Append .md to any documentation page URL to get its markdown version.

# Boas práticas iReport

Conheça algumas formas para deixar o seu modelo mais inteligível, facilitando seu entendimento e manutenção. Algumas dicas, estão correlacionadas ao SQL, mas é possível aplicá-las em outras áreas

## Utilize editores de texto externos para criar as consultas

Ao escrever uma consulta para um modelo de relatório, prefira utilizar um editor de texto externo do que utilizar a ferramenta **Report Query** do iReport. Isso porque, a mesma não é a melhor para identação e leiturabilidade do código.

É preferível utilizar um editor como o **Sublime Text 3, Notepad ++** ou até mesmo o **DBExplorer** da plataforma Sankhya. Recomendamos o último, pois nele já é possível testar os resultados da consulta com os dados reais. Uma ótima forma de visualizar os campos que serão necessários para o relatório.

E, então, somente após a escrita no editor de texto de sua preferência, Copei para o iReport.

## Utilize caixa alta para as palavras-chave

Uma das boas práticas mais básicas do SQL é usar caixa alta para as palavras-chave SQL e funções SQL, como NVL, ISNULL, MAX, MIN, etc.

Também é uma boa prática utilizar a caixa baixa para os nomes de tabela e colunas. No entanto, especificamente para o banco Sankhya, é uma boa prática utilizar caixa alta também para os campos e tabelas pois as mesmas são m usadas dessa forma no sistema. Por isso, por questão de padronização, opte por caixa alta para os campos e tabelas do banco da Sankhya.

```sql
Evite ❌❌❌

select par.nomeparc
from tgfpar par
where codparc <> 0 
_____________________________

Boa prática ✅✅✅

SELECT par.nomeparc
FROM tgfpar par
WHERE codparc <> 0

OU 

SELECT NOMEPARC
FROM TGFPAR
WHERE CODPARC <> 0
```

## Utilize apelidos para melhorar o entendimento

O apelido ou alcunha (ou alias), é uma forma muito utilizada para dar um significado maior a um campo buscado no banco de dados. É uma forma conveniente de renomear tabelas ou colunas nas quais não têm sentido explícito ou é preciso mudar o seu significado para melhor se adequar ao contexto.

É uma técnica muito eficiente para não se perder e deixar o nome do campo igual ao rótulo no cabeçalho da coluna no relatório, facilitando o seu mapeamento.

```sql
Evite ❌❌❌

SELECT cab.nunota,
	cab.numnota,
	par.nomeparc,
	cab.vlrnota
FROM tgfcab cab
JOIN tgfpar par ON cab.codparc = par.codparc
WHERE par.cliente = 'S'
_____________________________

Boa prática ✅✅✅

SELECT cab.nunota AS "Nro. Unico",
	cab.numnota AS "Nro. Nota",
	par.nomeparc AS "Cliente",
	cab.vlrnota AS "Vlr. da Nota"
FROM tgfcab cab
JOIN tgfpar par ON cab.codparc = par.codparc
WHERE par.cliente = 'S'
```

## Utilize alcunha quando utilizar mais de uma tabela

Sempre que houver mais de uma tabela como fonte de busca na consulta SQL, utilize apelidos para simplificar as seleções dos campos. Além disso, não esqueça de inserir a tabela fonte na frente do campo, mesmo que este não seja ambíguo. Dessa forma, fica mais fácil de ler e de realizar manutenção.

```sql
Evite ❌❌❌

SELECT nufin,
	vlrdesdob,
	codparc,
	nomeparc,
	razaosocial,
FROM tgffin
JOIN tgfpar ON tgffin.codparc = tgfpar.codparc
JOIN tgfemp ON tgffin.codemp = tgfemp.codemp
WHERE dhbaixa is not null
	AND provisao = 'N'
	AND recdesp = 1
_____________________________

Boa prática ✅✅✅
  
SELECT fin.nufin,
	fin.vlrdesdob,
	par.codparc,
	par.nomeparc,
	emp.razaosocial,
FROM tgffin fin
JOIN tgfpar par ON fin.codparc = par.codparc
JOIN tgfemp emp ON fin.codemp = emp.codemp
WHERE fin.dhbaixa is not null
	AND fin.provisao = 'N'
	AND fin.recdesp = 1
```

## Formatação: utilize cuidadosamente identação e espaços em branco

Apesar de ser um princípio básico, é uma forma bem rápida de deixar o seu código mais limpo e legível. Assim como você faria com Python, Java, JavaScript ou HTML, você deve identar o seu código SQL.

Idente após uma palavra-chave,  quando utilizar uma subconsulta ou tabela derivada.

```sql
Evite ❌❌❌

SELECT CAB.CODPARC AS "CÓDIGO", PAR.RAZAOSOCIAL AS "RAZÃO SOCIAL",
BAI.NOMEBAI AS "BAIRRO" FROM TGFCAB CAB JOIN TGFPAR PAR ON CAB.CODPARC = PAR.CODPARC JOIN TSICID CID ON CID.CODCID=PAR.CODCID JOIN TSIBAI BAI ON PAR.CODBAI=BAI.CODBAIWHERE CID.CODCID=973 AND CAB.STATUSNOTA='L' AND CAB.TIPMOV='V' AND CAB.VLRNOTA=(
SELECT MAX(C.VLRNOTA) FROM TGFCAB C JOIN TGFPAR P ON C.CODPARC=P.CODPARC 
JOIN TSICID CI ON P.CODCID=CI.CODCID WHERE C.STATUSNOTA='L'
AND CI.CODCID=973 AND C.TIPMOV='V')

_____________________________

Boa prática ✅✅✅

SELECT CAB.CODPARC AS "CÓDIGO",
	PAR.RAZAOSOCIAL AS "RAZÃO SOCIAL",
	BAI.NOMEBAI AS "BAIRRO"
FROM TGFCAB CAB 
JOIN TGFPAR PAR ON CAB.CODPARC = PAR.CODPARC
JOIN TSICID CID ON CID.CODCID = PAR.CODCID 
JOIN TSIBAI BAI ON PAR.CODBAI = BAI.CODBAI
WHERE CID.CODCID = 973 
	AND CAB.STATUSNOTA = 'L' 
	AND CAB.TIPMOV = 'V' 
	AND CAB.VLRNOTA = 
		(
			SELECT MAX(C.VLRNOTA) 
			FROM TGFCAB C 
			JOIN TGFPAR P ON C.CODPARC = P.CODPARC 
			JOIN TSICID CI ON P.CODCID = CI.CODCID 
			WHERE C.STATUSNOTA = 'L'
				AND CI.CODCID = 973 AND C.TIPMOV = 'V'
		)
```

É notável a diferença de facilidade de leitura entre o primeiro e o segundo exemplo, mesmo sendo o mesmo código.

Note, também, como usamos o espaço em branco entre as condições nas cláusulas JOIN e WHERE.

```sql
Evite ❌❌❌

WHERE cid.codcid=973
_____________________________

Boa prática ✅✅✅

WHERE cid.codcid = 973
```

## Organize os campos na cláusula SELECT

É importante também, organizar bem os campos na cláusula SELECT.\
Imagine uma situação com inúmeros campos de inúmeras tabelas, e você percebe que um campo de uma tabela não será mais necessário ou que este gerou um erro e você deve retirá-lo ou consertá-lo.\
Se os campos não estiverem organizados, você pode gastar um tempinho para achá-lo, porém, se estiverem organizados por tabela, será mais fácil de avistá-lo e aplicar a correção necessária.

```sql
Evite ❌❌❌

SELECT FIN.NUFIN AS "Lançamento",
    FIN.CODNAT,
    EMP.RAZAOSOCIAL AS "Empresa",
    FIN.NUMNOTA AS "Nº da Nota",
    FIN.VLRDESC AS "Finan.",
    FIN.DTVENC,
    COALESCE(FIN.VLRVENDOR, 0) AS VLRVENDOR,    
    FIN.DTNEG,
    FIN.VLRDESDOB AS "VALOR",
		COALESCE(FIN.CARTAODESC, 0) AS CARTAODESC,
    FIN.VLRIRF AS "IRF",
    FIN.VLRINSS AS "INSS",
    FIN.VLRISS AS "ISS",
    PAR.CODPARC,
    FIN.CODEMP,
		COALESCE
		(
			(
        SELECT ROUND(SUM(I.VALOR * I.TIPIMP),2)
        FROM TGFIMF I
        WHERE I.NUFIN = FIN.NUFIN
      ), 0) AS "Imposto Financeiro"
    PAR.NOMEPARC AS "Parceiro",
    COALESCE(FIN.DESPCART, 0) AS DESPCART      
FROM TGFFIN FIN
    JOIN TGFPAR PAR ON FIN.CODPARC = PAR.CODPARC
    JOIN TSIEMP EMP ON FIN.CODEMP = EMP.CODEMP
    JOIN TGFTIT TIT ON FIN.CODTIPTIT = TIT.CODTIPTIT
WHERE FIN.PROVISAO = 'N'
    AND FIN.DTNEG BETWEEN $P{P_DTNEGINI} AND $P{P_DTNEGFIN}
    AND FIN.RECDESP = 1
    AND FIN.DHBAIXA IS NULL
    AND (FIN.CODEMP = $P{P_CODEMP} OR $P{P_CODEMP} IS NULL)
    AND (FIN.DTVENC BETWEEN $P{P_DTVENCINI} AND $P{P_DTVENCFIN})
    AND (FIN.CODTIPTIT = $P{P_TIPOTITULO} OR $P{P_TIPOTITULO} IS NULL)
    AND (PAR.CODPARCMATRIZ = $P{P_CODPARCMATRIZ} OR $P{P_CODPARCMATRIZ} IS NULL)
ORDER BY FIN.DTVENC, 
		FIN.CODPARC, 
		FIN.NUFIN, 
		FIN.NUMNOTA


_____________________________

Boa prática ✅✅✅

SELECT FIN.NUFIN AS "Lançamento",
    FIN.CODNAT,
    FIN.CODEMP,
    FIN.NUMNOTA AS "Nº da Nota",
    FIN.VLRDESC AS "Finan.",
    FIN.DTVENC,
    FIN.DTNEG,
    FIN.VLRDESDOB AS "VALOR",		
    FIN.VLRIRF AS "IRF",
    FIN.VLRINSS AS "INSS",
    FIN.VLRISS AS "ISS",
    EMP.RAZAOSOCIAL AS "Empresa",
    PAR.CODPARC,
    PAR.NOMEPARC AS "Parceiro"
    COALESCE(FIN.DESPCART, 0) AS DESPCART,
    COALESCE(FIN.VLRVENDOR, 0) AS VLRVENDOR,
    COALESCE(FIN.CARTAODESC, 0) AS CARTAODESC,
    COALESCE
		(
			(
        SELECT ROUND(SUM(I.VALOR * I.TIPIMP),2)
        FROM TGFIMF I
        WHERE I.NUFIN = FIN.NUFIN
      ), 0) AS "Imposto Financeiro"
FROM TGFFIN FIN
    JOIN TGFPAR PAR ON FIN.CODPARC = PAR.CODPARC
    JOIN TSIEMP EMP ON FIN.CODEMP = EMP.CODEMP
    JOIN TGFTIT TIT ON FIN.CODTIPTIT = TIT.CODTIPTIT
WHERE FIN.PROVISAO = 'N'
    AND FIN.DTNEG BETWEEN $P{P_DTNEGINI} AND $P{P_DTNEGFIN}
    AND FIN.RECDESP = 1
    AND FIN.DHBAIXA IS NULL
    AND (FIN.CODEMP = $P{P_CODEMP} OR $P{P_CODEMP} IS NULL)
    AND (FIN.DTVENC BETWEEN $P{P_DTVENCINI} AND $P{P_DTVENCFIN})
    AND (FIN.CODTIPTIT = $P{P_TIPOTITULO} OR $P{P_TIPOTITULO} IS NULL)
    AND (PAR.CODPARCMATRIZ = $P{P_CODPARCMATRIZ} OR $P{P_CODPARCMATRIZ} IS NULL)
ORDER BY FIN.DTVENC, 
		FIN.CODPARC, 
		FIN.NUFIN, 
		FIN.NUMNOTA
```

Note como também deixamos para o final da cláusula SELECT as funções e a consulta aninhada (subconsulta). Dessa forma fica muito mais fácil de identificar um campo para removê-lo ou corrigi-lo.

## Utilize sintaxe JOIN para ligações

Ao invés de utilizar cláusulas WHERE para fazer as ligações, utilize a sintaxe JOIN ANSI-92.

Apesar de você poder utilizar tanto a cláusula WHERE quanto a cláusula JOIN para ligar tabelas, a melhor prática é utilizar a cláusula JOIN, mesmo que não haja diferença em termos de desempenho, no entanto a cláusula JOIN separa a lógica de ligação da lógica de filtros e melhora a leiturabilidade.

```sql
Evite ❌❌❌

SELECT fin.nufin,
	fin.vlrdesdob,
	par.codparc,
	par.nomeparc,
	emp.razaosocial,
FROM tgffin fin

WHERE fin.codparc = par.codparc
	AND fin.codemp = emp.codemp
	AND fin.dhbaixa is not null
	AND fin.provisao = 'N'
	AND fin.recdesp = 1
_____________________________

Boa prática ✅✅✅

SELECT fin.nufin,
	fin.vlrdesdob,
	par.codparc,
	par.nomeparc,
	emp.razaosocial,
FROM tgffin fin
JOIN tgfpar par ON fin.codparc = par.codparc
JOIN tgfemp emp ON fin.codemp = emp.codemp

WHERE fin.dhbaixa is not null
	AND fin.provisao = 'N'
	AND fin.recdesp = 1
```

## Utilize funções ANSI ao invés de funções próprias de banco

É muito comum cada SGBD (Sistema Gerenciador de Banco de Dados) implementar da sua maneira uma determinada função, até porque, boa parte desses SGBDs já tem um tempo no mercado. Porém existem muitas funções que são ANSI, ou seja, funções que são padrões, e são implementadas em todos (ou na maioria) os bancos de dados.

A plataforma Sankhya disponibiliza aos seus clientes duas opções de banco de dados atualmente: Microsoft SQL Server e Oracle. Isso é bom por um lado, mas ruim do outro, pois é comum achar modelos de relatórios que só funcionam para um determinado banco.

Por conta disso, tente utilizar ao máximo funções ANSI para que o seu relatório seja compatível nos dois SGBDs sem problemas.

Um exemplo disso, são as funções ISNULL e NVL, que vão buscar um dado campo caso seu valor não for nulo, ou retornar um valor especificado caso seja. Ao invés de usar essas funções proprietárias, prefira utilizar a função ANSI **COALESCE.**

Além de, na prática, não afetar a performance da consulta, também deixa o seu código mais manutenível e funcional.

```sql
Evite ❌❌❌

SELECT fin.nufin,
	fin.vlrdesdob,
	ISNULL(fin.despcart, 0),
	CONVERT(varchar(10), fin,dhbaixa)
FROM tgffin fin
WHERE fin.dhbaixa is not null
	AND fin.provisao = 'N'
	AND fin.recdesp = 1
_____________________________

Boa prática ✅✅✅

SELECT fin.nufin,
	fin.vlrdesdob,
	COALESCE(fin.despcart, 0),
	CAST(fin.dhbaixa AS varchar(10))
FROM tgffin fin
WHERE fin.dhbaixa is not null
	AND fin.provisao = 'N'
	AND fin.recdesp = 1
```

## Evitar concatenações em SQL

Pelo mesmo objetivo do ponto anterior: deixar o relatório compatível com os dois SGBDs.

Os bancos Oracle e SQL Server possuem operadores de concatenação que se diferem um do outro. Para Oracle, o operador é: ||; e para o SQL Server o operadore é: +. Ao invés de realizar as concatenações direto no banco, faça-as no iReport.

É possível utilizando a sintaxe Java na expressão de campo.

```sql
Evite ❌❌❌

SELECT EMP.NOMEFANTASIA AS "Razão Social",
    EDE.NOMEEND + ', ' + EMP.NUMEND + ' - ' + CID.NOMECID + ', ' UFS.UF AS "Endereço",
    EMP.CEP,
		EMP.INSCESTAD AS "Insc. Estadual",
    TIM_FORMATATELEFONE(EMP.TELEFONE) AS "Fone",
    Formatar_CPF_CNPJ(EMP.CGC) AS "CNPJ"    
FROM TSIEMP EMP
    JOIN TSICID CID ON EMP.CODCID = CID.CODCID
    JOIN TSIUFS UFS ON CID.UF = UFS.CODUF
    JOIN TSIEND EDE ON EMP.CODEND = EDE.CODEND
WHERE EMP.CODEMP = $P{P_CODEMP}
_____________________________

Boa prática ✅✅✅

SELECT EMP.NOMEFANTASIA AS "Razão Social",
    EDE.NOMEEND AS "Rua",
    EMP.NUMEND AS "Numero",
    EMP.CEP,
		EMP.INSCESTAD AS "Insc. Estadual",
    CID.NOMECID AS "Cidade",
    UFS.UF,
    TIM_FORMATATELEFONE(EMP.TELEFONE) AS "Fone",
    Formatar_CPF_CNPJ(EMP.CGC) AS "CNPJ"    
FROM TSIEMP EMP
    JOIN TSICID CID ON EMP.CODCID = CID.CODCID
    JOIN TSIUFS UFS ON CID.UF = UFS.CODUF
    JOIN TSIEND EDE ON EMP.CODEND = EDE.CODEND
WHERE EMP.CODEMP = $P{P_CODEMP}
```

E então trate os campos no relatório dessa forma:

![791](https://files.readme.io/834e4a5-boas_praticas_1.png "boas praticas 1.png")

## Prefira usar lógica de programação no iReport

Sempre que possível, trate sua lógica no iReport. Como dito anteriormente, iReport entende a sintaxe Java. Utilize-a para tratar as lógicas do relatório. Um exemplo muito comum no momento de realizar o saldo das movimentações financeiras utilizar o CASE WHEN e por o resultado em dois campos diferentes referenciando apenas um. É preferível buscar o campo apenas uma vez e fazer uma verificação na expressão de campo do iReport para apresentar ou não o campo.

```sql
Evite ❌❌❌

SELECT fin.nufin
		, fin.dtvenc
		, CASE 
				WHEN fin.recdesp = 1 
						THEN fin.vlrbaixa
			END AS "Credito"
		, CASE
				WHEN fin.recdesp = -1
						THEN fin.vlrbaixa * -1
			END AS "Debito"
FROM tgffin fin
WHERE fin.dhbaixa IS NULL
_____________________________

Boa prática ✅✅✅

SELECT fin.nufin AS "Nro. Unico"
		, fin.dtvenc AS "Dt. Vencimento"
		, fin.vlrbaixa * fin.recdesp AS "Valor"
FROM tgffin fin
WHERE fin.dhbaixa IS NULL
```

Nesse caso, basta criar dois campos de textos e configurar a condição de exibição para cada um deles da seguinte forma:

![690](https://files.readme.io/52290a1-img2.png "img2.png")

![690](https://files.readme.io/1b085a1-img3.png "img3.png")

Após fazer o mesmo para o outro campo, invertendo apenas o sinal, você terá um campo que aparecerá quando o valor do financeiro for positivo e outro quando for negativo.

Há outros tipos de lógicas que dá para fazer no iReport, até para esse mesmo problema para um mesmo campo. O importante é observar quando é necessário.

## Não utilize linhas para formar tabelas

Uma das piores coisas é se deparar com um relatório no qual contém o elemento linha para formar uma tabela. NÃO FAÇA ISSO! Utilize as bordas dos próprios campos no lugar para formar a tabela. Para isso, existe uma opção do elemento campo de texto que desenha suas bordas.

Evite ❌❌❌

![690](https://files.readme.io/61716b8-01.png "01.png")

Boa prática ✅✅✅

![690](https://files.readme.io/bfe9194-02.png "02.png")

![690](https://files.readme.io/fc8f6fa-03.png "03.png")

**Resultado:**

![690](https://files.readme.io/70041df-04.png "04.png")

Note que para os campos com alinhamento muito próximos as linhas, é possível adicionar paddings.

Além disso é possível selecionar apenas um lado para se criar uma linha:

![674](https://files.readme.io/e529a85-05.png "05.png")

**Resultado:**

![690](https://files.readme.io/63897cd-06.png "06.png")

## Confira também as boas práticas da central de ajuda

* [Melhores práticas para Funções/expressões em relatórios iReport e Fórmulas.](https://ajuda.sankhya.com.br/hc/pt-br/articles/360044579974-Melhores-pr%C3%A1ticas-para-Fun%C3%A7%C3%B5es-express%C3%B5es-em-relat%C3%B3rios-iReport-e-F%C3%B3rmulas-)

* [Melhores práticas para configuração de conexão JDBC no iReport.](https://ajuda.sankhya.com.br/hc/pt-br/articles/360045094273-Melhores-pr%C3%A1ticas-para-configura%C3%A7%C3%A3o-de-conex%C3%A3o-JDBC-no-iReport-)

* [Melhores práticas para personalização do DANFE na Impressão de NF-e \[Ireport\].](https://ajuda.sankhya.com.br/hc/pt-br/articles/360044579874-Melhores-pr%C3%A1ticas-para-personaliza%C3%A7%C3%A3o-do-DANFE-na-Impress%C3%A3o-de-NF-e-Ireport-)

## Como tirar dúvidas?

Para tirar suas dúvidas e compartilhar informações, use a sala [Relatórios Formatados](https://comunidade.sankhya.com.br/c/personalizacoes/relatorios-formatados/22) da comunidade Sankhya Developer.

**Contribuição** Felipe Salles Lopes