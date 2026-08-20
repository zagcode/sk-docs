# Ações customizadas vinculáveis a entidade/tela/componente de BI

Quando um componente de BI do tipo **Tabela** tem uma **Entidade**
associada (`entityName` no grid — ver `05-dash-gadget-padroes-reais.md`
seção 9), um botão de ações aparece no dashboard com as ações cadastradas
para aquela entidade no Dicionário de Dados (`Configurações > Avançado >
Dicionário de Dados > (entidade) > aba Ações`). Existem 4 modalidades.

Fontes: `sk-docs/sk-ia/rotina-banco-de-dados.md`, `.github/sk-java.md`
(= `rotina-java.md`), `.github/sk-javascript.md` (= `scripts.md`) — docs
oficiais salvas localmente; e `sk-dash/acerto estoque/acerto_estoque_actions.js`
como exemplo real do workspace.

## 1. Rotina no Banco de Dados (Stored Procedure)

Ação = uma Stored Procedure contextualizada e executada pelo sistema.
Melhor prática: escrever a procedure direto no banco (Oracle ou SQL
Server — sintaxes diferentes) e usar o botão "Criar template da rotina" no
cadastro da ação para gerar o esqueleto.

Template gerado:
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
- `P_CODUSU` — usuário logado.
- `P_IDSESSAO` — isola o ambiente da execução (necessário para as funções
  `ACT_*` abaixo).
- `P_QTDLINHAS` — quantas linhas estavam selecionadas no grid.
- `P_MENSAGEM` (saída) — se atribuído, exibido ao usuário ao final.

Campo **"Depois de executar, recarregar"**: `Toda a grade` / `Os registros
selecionados` / `O registro pai (quando existir)` / `O registro principal
(quando existir)` — distinção relevante quando a ação está numa tela
Detalhe de Detalhe.

### Funções disponíveis dentro da procedure

Ler parâmetros da ação (definidos no cadastro):
```sql
ACT_TXT_PARAM(P_IDSESSAO, 'NOME')   -- VARCHAR
ACT_INT_PARAM(P_IDSESSAO, 'NOME')   -- NUMBER inteiro
ACT_DEC_PARAM(P_IDSESSAO, 'NOME')   -- NUMBER decimal
ACT_DTA_PARAM(P_IDSESSAO, 'NOME')   -- DATE
```
Ler campos das linhas selecionadas no grid (`I` = índice 1..P_QTDLINHAS):
```sql
ACT_TXT_FIELD(P_IDSESSAO, I, 'CAMPO')
ACT_INT_FIELD(P_IDSESSAO, I, 'CAMPO')
ACT_DEC_FIELD(P_IDSESSAO, I, 'CAMPO')
ACT_DTA_FIELD(P_IDSESSAO, I, 'CAMPO')
```
PK do registro mestre (ação em tela Detalhe) — nome do campo prefixado
`MASTER_`:
```sql
ACT_INT_PARAM(P_IDSESSAO, 'MASTER_CODTAREFA')
```
Confirmação interativa durante a execução:
```sql
ACT_ESCOLHER_SIMNAO(P_TITULO, P_TEXTO, P_IDSESSAO, P_SEQUENCIA) -- retorna 'S'/'N'; 'Cancelar' aborta a ação
ACT_CONFIRMAR(P_TITULO, P_TEXTO, P_IDSESSAO, P_SEQUENCIA)       -- só 'OK'/'Cancelar', sem retorno
```
> **Cuidado:** duas chamadas `ACT_ESCOLHER_SIMNAO` com o mesmo
> `P_SEQUENCIA` fazem a segunda reaproveitar a resposta da primeira (fica
> sem efeito). Se a chamada estiver dentro de um `LOOP` de registros, usar
> o índice `I` como `P_SEQUENCIA` para a pergunta se repetir por linha.

Exemplo completo (inclusão condicionada por confirmação):
```sql
CREATE OR REPLACE PROCEDURE "STP_CHECK_LIST" (
       P_CODUSU NUMBER, P_IDSESSAO VARCHAR2, P_QTDLINHAS NUMBER, P_MENSAGEM OUT VARCHAR2
) AS
       V_PROXIMO_ID_PARTICIPANTE NUMBER;
       V_CODTAREFA NUMBER;
       V_TOTAL_PARTICIPANTES NUMBER;
       V_INCLUIR BOOLEAN;
BEGIN
       FOR I IN 1..P_QTDLINHAS LOOP
           V_CODTAREFA := ACT_INT_FIELD(P_IDSESSAO, I, 'CODTAREFA');
           SELECT COUNT(1) INTO V_TOTAL_PARTICIPANTES FROM AD_TADPTA WHERE CODTAREFA = V_CODTAREFA;
           IF V_TOTAL_PARTICIPANTES < 2 THEN
               V_INCLUIR := TRUE;
           ELSE
               V_INCLUIR := ACT_ESCOLHER_SIMNAO('Limite atingido', 'Já possui ' || V_TOTAL_PARTICIPANTES || ' participantes. Continuar?', P_IDSESSAO, I) = 'S';
           END IF;
           IF V_INCLUIR THEN
               INSERT INTO AD_TADPTA (CODTAREFA, CODPARTICIPANTE, NOME)
               VALUES (V_CODTAREFA, 1, ACT_TXT_PARAM(P_IDSESSAO, 'NOMEPARTICIPANTE'));
           END IF;
       END LOOP;
       P_MENSAGEM := 'Ação executada com sucesso!';
END;
/
```

## 2. Script (JavaScript server-side)

Alternativa às Stored Procedures — mesmas funcionalidades básicas, mais
recursos de linguagem. **Executa no servidor, não no browser** — sem
`alert()`/`window` do navegador, mas com acesso a banco de dados.

### Funções principais
```js
novaLinha([tabela])         // cria registro novo; se omitido, na tabela da própria ação. Registro só existe no banco após .save()
getParam(nome)               // valor de um parâmetro da ação
confirmar(titulo, texto, idx)          // diálogo OK/Cancelar
confirmarSimNao(titulo, texto, idx)    // diálogo Sim/Não -> true/false
email(titulo, mensagem, destinatarios) // agenda envio de email (destinatários separados por vírgula)
mostraErro(mensagem)         // interrompe a ação com erro
getUsuarioLogado()           // código do usuário logado
getQuery()                   // retorna um QueryExecutor
newJava(classname)           // instancia um objeto Java (ex.: SimpleDateFormat)
javaClass(classname)         // retorna a Classe Java (métodos/atributos estáticos)
```

### Variáveis de ambiente
- `linhas` (Array de `Registro`) — linhas selecionadas na grade.
- `linhaPai` (Registro) — linha da tela master, quando ação vinculada a
  tela detalhe.
- `mensagem` (String) — se atribuída, exibida ao final da execução.

### Objetos
```js
// Registro
registro.remove()
registro.save()
registro.setCampo(nome, valor)
registro.getCampo(nome)

// QueryExecutor (via getQuery())
var query = getQuery();
query.setParam("CODVEICULO", getParam("CODVEICULO"));
query.nativeSelect("SELECT * FROM TGFVEI WHERE CODVEICULO = {CODVEICULO}"); // parâmetros entre {}
query.update("UPDATE ...");           // UPDATE/INSERT
query.next();                          // avança cursor, false quando acabar
query.getDouble(coluna) / getInt(coluna) / getString(coluna) / getDate(coluna)
query.getObj();                        // objeto já com cast pelos tipos do banco
query.close();                         // fechar assim que não precisar mais (performance)
```

Exemplo completo — gerar título financeiro a partir de lançamentos:
```js
var query = getQuery();
query.setParam("CODVEICULO", getParam("CODVEICULO"));
query.nativeSelect("SELECT * FROM AD_TADCKM WHERE CODVEICULO = {CODVEICULO}");

var vlrDesdob = 0;
while (query.next()) {
    var reembolso = query.getDouble("REEMBOLSO");
    if (reembolso > 0) {
        vlrDesdob += reembolso;
    } else {
        mostraErro("O reembolso do lançamento " + query.getInt("SEQUENCIA") + " não foi calculado ainda.");
    }
}
if (vlrDesdob == 0) {
    confirmar("Valor do título zerado", "O veículo não possui lançamentos para reembolso. Continuar?", 1);
}
query.close();

var financeiro = novaLinha("TGFFIN");
financeiro.setCampo("VLRDESDOB", vlrDesdob);
financeiro.setCampo("RECDESP", -1);
financeiro.setCampo("CODEMP", 11);
financeiro.setCampo("CODPARC", 0);
financeiro.setCampo("CODTIPTIT", 2);
financeiro.setCampo("DTVENC", "04/10/2012");
financeiro.setCampo("HISTORICO", "REEMBOLSO DE KM PARA O VEÍCULO " + getParam("CODVEICULO"));
financeiro.save();

mensagem = "Foi gerado o título " + financeiro.getCampo("NUFIN") + " no valor de " + financeiro.getCampo("VLRDESDOB");
```

### Padrão real do workspace: `acerto_estoque_actions.js`

`sk-dash/acerto estoque/acerto_estoque_actions.js` é o exemplo de produção
deste tipo de ação, associado à entidade `EstoqueEndereco` (tabela
`TGWEST`) referenciada pelo dashboard `acerto_estoque.xml`
(`entityName="EstoqueEndereco"` — ver `05-dash-gadget-padroes-reais.md`
seção 10). O arquivo concentra **4 ações distintas** num único `.js`,
cada bloco delimitado por comentário `// ====` + nome da ação, para colar
individualmente no campo "Script" de cada Ação cadastrada:

1. **Incluir Estoque WMS** — lê parâmetros (CODPROD/CODEMP/CODEND/CODVOL/
   ESTOQUE...), `novaLinha("TGWEST")`, preenche campos, `.save()`.
2. **Aumentar Estoque WMS** — itera `linhas[]`, valida seleção não vazia
   (`mostraErro` se `linhas.length === 0`), soma `QTDE` a
   `ESTOQUE`/`ESTOQUEVOLPAD` de cada linha.
3. **Diminuir Estoque WMS** — mesmo padrão, mas valida saldo suficiente
   antes de subtrair (`if (parseFloat(qtde) > estoqueAtual) mostraErro(...)`),
   evitando estoque negativo.
4. Variações auxiliares de atualização condicional campo-a-campo.

Padrão a replicar num dashboard novo com ações de escrita: **um `.js` por
dashboard operacional**, cabeçalho comentado (tabela alvo, gadget de
origem, tela-alvo da ação, API disponível), blocos autocontidos com
variáveis de sufixo único por ação para evitar colisão ao copiar trechos
isolados.

## 3. Rotina Java

Ação = uma classe Java implementando `AcaoRotinaJava` (método
`doAction(ContextoAcao contexto)`), empacotada em `.jar` e cadastrada em
`Configurações > Avançado > Módulo Java`. Um módulo pode ter vários JARs
(bibliotecas de terceiros inclusas); um JAR pode ter várias classes-ação.

- Pacote de convenção reversa de domínio (ex. `br.com.sankhya.ctba`,
  `br.com.dps.novaReferencia` — ver convenção do projeto em
  `.github/copilot-instructions.md` § Estrutura Java).
- `ContextoAcao` expõe o mesmo arsenal do Script JS, com API Java:
  `contexto.getQuery()`, `contexto.getParam(nome)`,
  `contexto.novaLinha(tabela)`, `contexto.mostraErro(msg)`,
  `contexto.confirmar(...)`, `contexto.setMensagemRetorno(...)`.

```java
public void doAction(ContextoAcao contexto) throws Exception {
    QueryExecutor query = contexto.getQuery();
    query.setParam("CODVEICULO", contexto.getParam("CODVEICULO"));
    query.nativeSelect("SELECT * FROM AD_TADCKM WHERE CODVEICULO = {CODVEICULO}");

    double vlrDesdob = 0;
    while (query.next()) {
        double reembolso = query.getDouble("REEMBOLSO");
        if (reembolso > 0) vlrDesdob += reembolso;
        else contexto.mostraErro("Reembolso não calculado para " + query.getInt("SEQUENCIA"));
    }
    query.close();

    Registro financeiro = contexto.novaLinha("TGFFIN");
    financeiro.setCampo("VLRDESDOB", vlrDesdob);
    financeiro.save();

    contexto.setMensagemRetorno("Título " + financeiro.getCampo("NUFIN") + " gerado.");
}
```

Cadastro: exportar a classe como JAR → `Módulo Java` → aba Arquivo Módulo
(Jar) → anexar → na aba Ações da entidade, Tipo = "Rotina Java", selecionar
módulo + classe.

Ver também `.github/copilot-instructions.md` § "Estrutura Java — sk-custom"
para os padrões internos do projeto DPS (`AcaoRotinaJava`, `NativeSql`,
`excecaoPendente`, `EventoProgramavelJava`) — esses são para customizações
de tela/entidade em geral, complementares às ações aqui documentadas.

## 4. Lançador

Modalidade citada no catálogo oficial (`04-dash-gadget-componentes-
avancados.md` § "Ações nos Componentes de BI") como uma das 4 opções de
Tipo de ação, ao lado de Rotina no Banco de Dados / Script / Rotina Java.
Nenhuma doc local detalha o "Lançador" além de citá-lo — presumivelmente
equivalente/relacionado ao `on-click-launcher` do Gadget (abre tela nativa
do sistema, ver `05-dash-gadget-padroes-reais.md` seção 11), mas como tipo
de Ação de entidade em vez de evento de componente de BI. **Confirmar no
portal do desenvolvedor antes de usar** — ver `08-referencias-externas.md`.
