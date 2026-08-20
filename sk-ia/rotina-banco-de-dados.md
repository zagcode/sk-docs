---
updatedAt: 2025-11-10T23:37:26.000Z
---

Fetch the complete documentation index at: https://developer.sankhya.com.br/llms.txt. Use this file to discover all available pages before exploring further. Append .md to any documentation page URL to get its markdown version.

# Rotina Banco de dados

> 📘 Importante
>
> Os exemplos deste tutorial são para Oracle, contudo também é aplicável no SQLServer

A base desse tipo de ação é uma Stored Procedure que será contextualizada e executada pelo sistema. Como existem vários recursos de programação e diferenças significativas entre os SGDB (Oracle e SqlServer) suportados pelo Sankhya-Om, a melhor maneira de criar a stored procedure é fazê-lo diretamente no banco. Assim, a interface de configuração das ações desse tipo coleta as informações necessárias para criar o corpo da procedure. Dessa forma, siga as orientações a seguir:

* Abra o Construtor de telas e nele localize a tabela de exemplo "Tarefa";
* Na aba Ações, crie uma ação do tipo "Rotina no Banco de Dados" e informe a "Descrição";
* No campo "Nome da rotina", informe o nome da procedure propriamente dito.

![1919](https://files.readme.io/757294e-banco_1.jpg "banco_1.jpg")

No campo "Depois de executar, recarregar", selecione uma dentre as seguintes opções:

* Toda a grade: Recarrega todos os registros da grade principal da tela, independente dos itens selecionados.
* Os registros selecionados: Recarrega somente os registros selecionados para a ação.
* O registro pai (Quando existir): No caso em que a ação é registrada para uma tela Detalhe, recarrega o registro da tela Mestre. Caso seja selecionado para uma tela não Detalhe, toda a grade será recarregada.
* O registro principal (Quando existir): A diferença é sutil, mas entenda que uma tela Mestre, pode ser Detalhe de outra. Por exemplo, quando estamos executando uma ação para a tela "Participantes", o registro pai seria a "Etapa" e o registro principal seria a "Tarefa", pois Participante é Detalhe de Etapa que por sua vez, é Detalhe de Tarefa.

Em seguida, salve a ação e clique no botão  "Criar uma template da rotina" para gerar um template da procedure.

**Nota:** Quando a procedure está compilada no Banco, o campo "Nome da rotina" ficará desabilitado.

O template criado revela como deve ser o “esqueleto” da proc, ou seja, quais são os parâmetros e entrada e saída que ela deve ter.  Confira abaixo:

```sql
CREATE OR REPLACE PROCEDURE "STP_CHECK_LIST" (
       P_CODUSU NUMBER,
       P_IDSESSAO VARCHAR2,
       P_QTDLINHAS NUMBER, 
       P_MENSAGEM OUT VARCHAR2
) AS
BEGIN
END;
/
```

Referente aos parâmetros, teremos:

* P\_CODUSU: Código do usuário logado – pode ser útil em alguns casos;
* P\_IDSESSAO: Esse identificador serve para separar o ambiente da execução
* P\_QTDLINHAS: Determina quantas linhas estavam selecionadas no grid, no momento da execução.
* P\_MENSAGEM: (parâmetro de saída): Se houver atribuição de um valor para esse parâmetro, ao final da execução essa mensagem será mostrada ao usuário.

Em seguida, recompile a procedure da seguinte forma:

```sql
CREATE OR REPLACE PROCEDURE "STP_CHECK_LIST" (
       P_CODUSU NUMBER,
       P_IDSESSAO VARCHAR2,
       P_QTDLINHAS NUMBER,
       P_MENSAGEM OUT VARCHAR2
) AS
BEGIN
       INSERT INTO AD_TADTAR(CODTAREFA, DESCRTAR) VALUES(1, 'Logística');
       INSERT INTO AD_TADETA(CODTAREFA, CODETAPA, DESCRICAO) VALUES(1, 1, 'Ligar para transportadora e agendar carregamento');
       INSERT INTO AD_TADPTA(CODTAREFA, CODETAPA, CODPARTICIPANTE, NOME) VALUES(1, 1, 1, 'Antônio');
END;
/
```

Ao executar a ação, podemos comprovar a inclusão dos registros.

Até aqui, já é possível fazer uma infinidade de ações, afinal, todo arsenal de programação do banco de dados pode usado para incluir/alterar/remover registros de qualquer tabela, efetuar desde os mais simples aos mais elaborados cálculos. Além disso, antes de executar a procedure, o Sankhya-Om prepara o ambiente de execução, passando alguns parâmetros. Esses parâmetros podem ser obtidos da seguinte forma:

Ao retornar à aba Ações, adicione um parâmetro do tipo texto chamado **NOMEPARTICIPANTE** e recompile a procedure assim:

```sql
CREATE OR REPLACE PROCEDURE "STP_CHECK_LIST" (
       P_CODUSU NUMBER,
       P_IDSESSAO VARCHAR2,
       P_QTDLINHAS NUMBER,
       P_MENSAGEM OUT VARCHAR2
) AS
       V_PROXIMO_ID_PARTICIPANTE NUMBER;
BEGIN

       -- Para descobrir o próximo codparticipante...
       SELECT
             MAX(CODPARTICIPANTE) + 1
       INTO
             V_PROXIMO_ID_PARTICIPANTE
       FROM
             AD_TADPTA
       WHERE
             CODTAREFA = 1 AND CODETAPA  = 1;

       -- No primeiro participante, o valor da variável estará nulo.  
       IF V_PROXIMO_ID_PARTICIPANTE IS NULL THEN
             V_PROXIMO_ID_PARTICIPANTE := 1;
       END IF;

       INSERT
             INTO AD_TADPTA (
                  CODTAREFA,
                  CODETAPA,
                  CODPARTICIPANTE,
                  NOME
             ) VALUES (
                  1,
                  1,
                  V_PROXIMO_ID_PARTICIPANTE,
                  ACT_TXT_PARAM(P_IDSESSAO, 'NOMEPARTICIPANTE')
             );
END;
/
```

Posteriormente, a procedure irá obter o valor informado através da função ACT\_TXT\_PARAM. Isso é possível porque o Sankhya-Om injeta esses parâmetros no banco, antes de executar a procedure, por isso existe o parâmetro P\_IDSESSAO mencionado acima, sendo que ele é necessário para isolar o ambiente dessa execução.

Além da função ACT\_TXT\_PARAM mencionada acima, existem outras três funções, uma para cada tipo de dado, observe:

* ACT\_TXT\_PARAM: Retorna um valor VARCHAR, usada para parâmetro do tipo texto.
* ACT\_INT\_PARAM: Retorna um valor NUMBER, usada para parâmetro do tipo numero **inteiro.**
* ACT\_DEC\_PARAM: Retorna um valor NUMBER, usada para parâmetro do tipo numero **decimal.**
* ACT\_DTA\_PARAM: Retorna um valor DATE, usada para parâmetro do tipo data.

Todas essas funções têm a mesma estrutura. Recebem o ID da sessão como primeiro argumento e o Nome do parâmetro como segundo.

Também estão disponíveis a PK de todos os registros selecionados na grade no momento da execução. Para obter essas informações, existem quatro funções semelhantes, observe:

* ACT\_TXT\_FIELD: Retorna um valor VARCHAR, usada para campos do tipo texto.
* ACT\_INT\_FIELD: Retorna um valor NUMBER, usada para campos do tipo numero inteiro.
* ACT\_DEC\_FIELD: Retorna um valor NUMBER, usada para campos do tipo numero decimal.
* ACT\_DTA\_FIELD: Retorna um valor DATE, usada para campos do tipo data.

A diferença no uso dessas funções, é que além do ID da sessão e o Nome do campo, é necessário também informar um Índice que determina a sequencia das linhas selecionadas. Assim, considere o exemplo:

```sql
CREATE OR REPLACE PROCEDURE "STP_CHECK_LIST" (
       P_CODUSU NUMBER,
       P_IDSESSAO VARCHAR2,
       P_QTDLINHAS NUMBER,
       P_MENSAGEM OUT VARCHAR2
) AS
       V_PROXIMO_ID_PARTICIPANTE NUMBER;
       V_CODTAREFA NUMBER;
       V_NOMEPARTICIPANTE VARCHAR2(4000);
BEGIN       
       -- Pegamos o valor digitado pelo usuário e guardamos nesta variável.
       V_NOMEPARTICIPANTE := ACT_TXT_PARAM(P_IDSESSAO, 'NOMEPARTICIPANTE');

       -- Como visto, P_QTDLINHAS determina quantas linhas estão selecionadas  
       FOR I IN 1..P_QTDLINHAS
       LOOP
           -- Aqui, "I" representa a qual linha estamos nos referindo.
           V_CODTAREFA := ACT_INT_FIELD(P_IDSESSAO, I, 'CODTAREFA');

           SELECT
                 MAX(CODPARTICIPANTE) + 1
           INTO
                 V_PROXIMO_ID_PARTICIPANTE
           FROM
                 AD_TADPTA
           WHERE
                 CODTAREFA = V_CODTAREFA  AND CODETAPA  = 1;

           -- No primeiro participante, o valor da variável estará nulo.  
           IF V_PROXIMO_ID_PARTICIPANTE IS NULL THEN
                 V_PROXIMO_ID_PARTICIPANTE := 1;
           END IF;

           -- Com todos os valores necessários, fazemos a inclusão  
           INSERT
                 INTO AD_TADPTA (
                      CODTAREFA,
                      CODETAPA,
                      CODPARTICIPANTE,
                      NOME
                 ) VALUES (
                      V_CODTAREFA,
                      1,
                      V_PROXIMO_ID_PARTICIPANTE,
                      ACT_TXT_PARAM(P_IDSESSAO, 'NOMEPARTICIPANTE')
                 );
       END LOOP;
END;
/
```

Com duas Tarefas selecionadas, execute novamente a ação.\
De acordo com a procedure, o nome do participante informado, será incluído na etapa 1 das duas tarefas.

De acordo com a proc o nome do participante informado pelo usuário será incluído na etapa 1 das duas tarefas.

**Dicas\&#xA;**\
**Mecanismo de confirmação:** Em algumas situações, pode ser necessário solicitar a confirmação do usuário durante a execução da ação. Por exemplo, digamos que uma etapa normalmente tenha no máximo **dois** participantes, e se estiver sendo solicitada a inclusão de um **terceiro** participante, o usuário deverá ser consultado antes de proceder a inclusão, recompilando a procedure, confira abaixo:

Recompile a procedure assim:

```sql
CREATE OR REPLACE PROCEDURE "STP_CHECK_LIST" (
       P_CODUSU NUMBER,
       P_IDSESSAO VARCHAR2,
       P_QTDLINHAS NUMBER,
       P_MENSAGEM OUT VARCHAR2
) AS
       V_PROXIMO_ID_PARTICIPANTE NUMBER;
       V_CODTAREFA NUMBER;
       V_NOMEPARTICIPANTE VARCHAR2(4000);
       V_TOTAL_PARTICIPANTES NUMBER;
       V_DESCRTAREFA VARCHAR(4000);
       V_DESCRETAPA VARCHAR(4000);
       V_TITULO VARCHAR(4000);
       V_MENSAGEM VARCHAR(4000);
       V_INCLUIR BOOLEAN;
BEGIN       
       -- Pegamos o valor digitado pelo usuário e guardamos nesta variável.
       V_NOMEPARTICIPANTE := ACT_TXT_PARAM(P_IDSESSAO, 'NOMEPARTICIPANTE');

       -- Como visto, P_QTDLINHAS determina quantas linhas estão selecionadas  
       FOR I IN 1..P_QTDLINHAS
       LOOP
           -- Aqui, "I" representa a qual linha estamos nos referindo.
           V_CODTAREFA := ACT_INT_FIELD(P_IDSESSAO, I, 'CODTAREFA');

          SELECT
                 TAR.DESCRTAR,
                 ETA.DESCRICAO,
                 MAX(CODPARTICIPANTE) + 1,
                 COUNT(1)
           INTO
                 V_DESCRTAREFA,
                 V_DESCRETAPA,
                 V_PROXIMO_ID_PARTICIPANTE,
                 V_TOTAL_PARTICIPANTES
           FROM
                 AD_TADTAR TAR
                 INNER JOIN AD_TADETA ETA ON ETA.CODTAREFA = TAR.CODTAREFA
                 INNER JOIN AD_TADPTA PTA ON PTA.CODTAREFA = ETA.CODTAREFA AND PTA.CODETAPA = ETA.CODETAPA
           WHERE
                 TAR.CODTAREFA = V_CODTAREFA  AND ETA.CODETAPA = 1
           GROUP BY
                 TAR.DESCRTAR, ETA.DESCRICAO;

           -- No primeiro participante, o valor da variável estará nulo.  
           IF V_PROXIMO_ID_PARTICIPANTE IS NULL THEN
                 V_PROXIMO_ID_PARTICIPANTE := 1;
           END IF;

           --Se o total de participantes ainda não chegou ao limite, a inclusão está liberada
           IF V_TOTAL_PARTICIPANTES < 2 THEN
               V_INCLUIR := TRUE;
           ELSE -- Senão, faz uma pergunta ao usuário.
               V_TITULO := 'Máximo de participantes atingido';
               V_MENSAGEM := 'A etapa "' || V_DESCRETAPA || '" (Tarefa "' || V_DESCRTAREFA || '") já possui ' || V_TOTAL_PARTICIPANTES || ' participantes.\n\nDeseja continuar?';
               V_INCLUIR := ACT_ESCOLHER_SIMNAO(V_TITULO, V_MENSAGEM, P_IDSESSAO, I) = 'S';
           END IF;

           IF V_INCLUIR THEN
               -- Com todos os valores necessários, fazemos a inclusão  
               INSERT
                     INTO AD_TADPTA (
                          CODTAREFA,
                          CODETAPA,
                          CODPARTICIPANTE,
                          NOME
                     ) VALUES (
                          V_CODTAREFA,
                          1,
                          V_PROXIMO_ID_PARTICIPANTE,
                          ACT_TXT_PARAM(P_IDSESSAO, 'NOMEPARTICIPANTE')
                     );
           END IF;
       END LOOP;
END;
/
```

Com duas Tarefas selecionadas execute novamente a ação, informe o nome do participante e clique em "OK".

Será exibida uma mensagem de confirmação em que o sistema irá informá-lo que há mais de dois participantes.

Isso é feito através da função **ACT\_ESCOLHER\_SIMNAO** e durante a execução da rotina. Quando essa função é chamada, o sistema interrompe a ação, exibe o pop-up de confirmação na tela e espera a sua decisão.\
Se o botão **"Cancelar"** for pressionado, a ação é cancelada.\
Se o botão **"Sim"** for o escolhido, a ação é retomada e o retorno da função será "S".\
Caso você selecione **"Não"**, o retorno da função será **"N"**.

Essa função recebe 4 argumentos, sendo eles:

* P\_TITULO: O título da janela de confirmação;
* P\_TEXTO: A mensagem de confirmação que será exibida;
* P\_CHAVE: Como dito anteriormente, serve para isolar o ambiente de execução da ação e é recebido como argumento na proc;
* P\_SEQUENCIA: Trata-se de um número inteiro, que serve para identificar a pergunta. Imagine que exista mais de uma chamada à **“ACT\_ESCOLHER\_SIMNAO”**, cada uma delas deverá ter um valor diferente para esse parâmetro. Assim, pode-se identificar corretamente as resposta do usuário.

> 🚧 Importante
>
> Se existirem duas perguntas ACT\_ESCOLHER\_SIMNAO com mesma P\_SEQUENCIA, a resposta da primeira pergunta será repassada para a segunda, e ela ficará sem efeito. A chamada está dentro do loop de registros, usamos a variável I como sequência, a fim da pergunta se repetir a cada registro.

Além da confirmação **ACT\_ESCOLHER\_SIMNAO**, existe outra função chamada ACT\_CONFIRMAR, que recebe os mesmos argumentos e fará basicamente a mesma coisa. A diferença entre elas, é que não existe uma resposta, em que você pode escolher entre "OK", que nesse caso retoma a execução, ou "Cancelar", que faz a ação ser cancelada, portanto ACT\_CONFIRMAR não terá retorno.

Referente ao **"PK do registro mestre"**, quando uma ação é executada em uma tela detalhe, os campos PK da tela pai estarão disponíveis como se fossem parâmetros, podendo ser obtidos através de uma das funções **ACT\_TXT\_PARAM**, **ACT\_INT\_PARAM**, **ACT\_DEC\_PARAM** ou **ACT\_DTA\_PARAM** mencionadas acima. É possível utilizar o próprio nome do campo precedido de "MASTER\_", assim, ações da aba "Participantes" podem usar, por exemplo, ACT\_INT\_PARAM(P\_IDSESSAO, ‘MASTER\_CODTAREFA’) e ACT\_INT\_PARAM(P\_IDSESSAO, ‘MASTER\_CODETAPA’).

**PK do registro mestre:** Completando nossa caixa ferramentas para Stored Procedures, quando uma ação é executada em uma tela detalhe, os campos PK da tela pai estarão disponíveis como se fossem parâmetros, podendo ser obtidos através de uma das funções ACT*TXT\_PARAM, ACT\_INT\_PARAM, ACT\_DEC\_PARAM ou ACT\_DTA\_PARAM mencionadas acima. O truque aqui, é usar o próprio nome do campo, precedido de \*\*“MASTER*” **, assim, ações da aba “Participantes” podem usar por exemplo,**&#x41;CT\_INT\_PARAM(P\_IDSESSAO, ‘MASTER\_CODTAREFA’) **e** ACT\_INT\_PARAM(P\_IDSESSAO, ‘MASTER\_CODETAPA’).\*\*

> 📘 Importante
>
> A procedure pode retornar uma mensagem a ser exibida por meio do parâmetro de saída "P\_MENSAGEM". Quando existir um valor para esse parâmetro, o Sankhya-Om o exibirá como uma informação:

```sql
CREATE OR REPLACE PROCEDURE "STP_CHECK_LIST" (
       P_CODUSU NUMBER,
       P_IDSESSAO VARCHAR2,
       P_QTDLINHAS NUMBER, 
       P_MENSAGEM OUT VARCHAR2
) AS
BEGIN
       P_MENSAGEM := 'A ação foi executada com sucesso!';
END;
/
```

Dessa forma, a ação será executada.

## Como tirar dúvidas?

Para tirar dúvidas e compartilhar informações, use a sala [Botões de Ação](https://comunidade.sankhya.com.br/c/personalizacoes/botoes-de-acao/17) da comunidade Sankhya Developer.