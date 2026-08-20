# Estrutura básica de um Gadget Sankhya (sk-dash)

> Espelho do rulebook `.github/copilot-instructions.md`. Para recursos além
> deste básico, ver `04-dash-gadget-componentes-avancados.md` (catálogo
> oficial) e `05-dash-gadget-padroes-reais.md` (padrões minerados de
> dashboards reais do workspace).

Componentes/gadgets Sankhya ficam gravados na tabela **`TSIGDG`**, campo
**`CONFIG`**, como o XML completo abaixo. Há dois modos de edição
equivalentes no Sankhya: **Design** (assistente visual) e **XML** (edição
direta) — o Design apenas gera este XML por trás.

## Hierarquia completa

```xml
<gadget>
  <prompt-parameters>
    <!-- Parâmetros exibidos ao usuário antes de executar -->
    <parameter id="Periodo" metadata="datePeriod" required="true" keep-last="true"/>
    <parameter id="Empresa" metadata="entity:Empresa@CODEMP" required="true"/>
  </prompt-parameters>

  <level id="01Q" description="Principal">
    <container orientacao="V" tamanhoRelativo="100">
      <grid id="grd_XXX" useNewGrid="S">
        <title><![CDATA[Título do grid]]></title>
        <expression type="sql" data-source="MGEDS">
          <![CDATA[ SELECT ... ]]>
        </expression>
        <metadata>
          <field name="COLUNA" label="Label" type="I|S|F|D"
                 visible="true" useFooter="false|SUM" mask="R$ #.##0,00"/>
        </metadata>
        <!-- Navegação para outro nível ao clicar na linha -->
        <on-click navigate-to="ID_NIVEL_DESTINO">
          <param id="ARG_DO_NIVEL">$CAMPO_DO_GRID</param>
        </on-click>
        <!-- OU refresh de outro grid na mesma tela -->
        <refresh-details ui-list="grd_OUTRO">
          <param id="ARG_DO_GRID">$CAMPO</param>
        </refresh-details>
      </grid>
    </container>
  </level>

  <level id="0BP" description="Detalhe">
    <args>
      <arg id="A_PARAM" type="integer|text" label="..."/>
    </args>
    <container>...</container>
  </level>
</gadget>
```

`<container>` só tem os atributos `orientacao`/`tamanhoRelativo`; `<level>`
só tem `id`/`description` — confirmado por checagem exaustiva, nenhum outro
atributo existe além destes.

## Tipos de `<field>`
| type | Uso |
|---|---|
| `I` | Inteiro |
| `S` | String/Texto |
| `F` | Float / Decimal |
| `D` | Data |
| `C` | Numérico "pivotável"/moeda — visto em `<pivot-table>`, sempre com `mask="R$ ..."` |

## Máscaras comuns
| mask | Resultado |
|---|---|
| `R$ #.##0,00` | Valor monetário |
| `#.##0,00` | Decimal sem símbolo (rentabilidade %) |
| `#.##0;-n` | Estilo Excel, seção positiva;negativa |

`data-source` é sempre `"MGEDS"` para o banco principal Sankhya (também
aceita fontes de dados **externas** não-Sankhya — ver seção "Fontes de dados
externas" em `04-dash-gadget-componentes-avancados.md`).

## Parâmetros singleList e multiList

### Atributos do `<parameter>`
| Atributo | Valores | Descrição |
|---|---|---|
| `metadata` | `singleList:Text` / `multiList:Text` / `datePeriod` / `entity:Tabela@Campo` / `integer` | Tipo do parâmetro |
| `listType` | `text` / `sql` | Itens fixos no XML (`text`) ou vindos de query (`sql`) |
| `required` | `true` / `false` | Obrigatório preencher antes de executar |
| `keep-last` | `true` / `false` | Memoriza o último valor selecionado |
| `order` | inteiro | Ordem de exibição na tela de parâmetros |
| `default`, `range-ini`, `range-end`, `limit-char` | — | Para `metadata="integer"`: valor padrão e faixa válida, ex. parâmetro Ano |
| `description`, `keep-date`, `label` | — | Atributos adicionais vistos em dashboards reais |

### `listType="text"` — itens fixos no XML
```xml
<parameter id="P_PROVISAO" metadata="singleList:Text" listType="text" required="true" keep-last="true">
  <item value="N" label="Não"/>
  <item value="S" label="Sim"/>
</parameter>
```

### `listType="sql"` — itens vindos de query (colunas obrigatórias: VALUE e LABEL)
```xml
<parameter id="P_TOP" metadata="multiList:Text" listType="sql" required="true" keep-last="true">
  <expression type="SQL">
    <![CDATA[
SELECT CODTIPOPER AS VALUE, DESCROPER AS LABEL FROM TGFTOP ORDER BY VALUE
    ]]>
  </expression>
</parameter>
```
A query **deve** retornar exatamente as colunas `VALUE` e `LABEL`. Pode usar `DISTINCT`, `JOIN`, funções escalares, `UNION ALL` com linha fixa no topo.

### Expansão do parâmetro no SQL
| Situação | Expansão gerada |
|---|---|
| Nenhum valor selecionado | parâmetro vira `NULL` (string) |
| Um valor selecionado | `('valor')` |
| Múltiplos valores selecionados | `('v1','v2','v3')` |

> **NUNCA** use `= :PARAM` para multiList — use sempre `IN :PARAM` (sem parênteses extras no XML, o Sankhya já insere).

### Filtro correto (bloco `[PARAM]`)
```sql
[PARAM:P_SEMANAL]
  AND TABELA.CAMPO IN :P_SEMANAL
[/PARAM:P_SEMANAL]
```
Bloco omitido quando nenhum valor selecionado; `IN` funciona com 1 ou N valores. Para singleList, usar `=` ou verificar nulidade dentro do mesmo padrão `[PARAM]...[/PARAM]`.

> Por que não usar `(:FAIXA IS NULL OR ... IN (:FAIXA))`: o Sankhya expande `(:FAIXA)` para `(('v1','v2'))` com múltiplos valores, gerando "expressão de tipo não booleano" no `IS NULL` e parênteses duplos inválidos no `IN`. Sempre usar `[PARAM]...[/PARAM]`.

## Convenções de navegação e grid

- `on-click` navega para outro **nível**; `refresh-details` atualiza outro(s) **grid(s)/componente(s) no mesmo nível**.
- Para atualizar múltiplos componentes com um único clique: `ui-list="grd_A,grd_B"` (aceita misturar grids, gráficos, `simple-value` — ver `05-dash-gadget-padroes-reais.md`).
- Args de nível recebem valores via `<param>` no `on-click`/`refresh-details` do componente anterior.
- `required="true"` no parâmetro torna obrigatório preencher antes de executar o gadget.
