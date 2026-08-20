# Padrões reais minerados dos dashboards do workspace

> Extraído de leitura direta dos maiores/mais complexos Gadgets já
> construídos em `sk-dash/`: `analise de vendas/analise.vendas.xml` (7408
> linhas, 25 níveis — o mais complexo do workspace), `bi gerencial
> desempenho comercial/dash bi desempenho comercial.xml` (5056 linhas, 9
> níveis), `bi acompanhamento financeiro/acomp financeiro.xml` (1685
> linhas), `comissao gerencial/*` e `comissao geral/*`, `bi_reativacao/*`,
> `acerto estoque/*`, `monitor_paulo/monitor.xml`,
> `separadores_conferentes/sep_conf.xml`, `saldo sem mov/saldo.xml`, `dps
> menu financeiro/menu financeiro.xml`, e o pacote-modelo oficial
> `modelo/` (JSPs + XML + CSS de um componente HTML5, ver seção 14). Estes
> são técnicas **confirmadas em produção** neste workspace — a fonte mais
> confiável para replicar num dashboard novo, mais confiável até que o
> catálogo oficial porque já passou pelo SQL Server real do projeto.

## 1. Componentes visuais além de `<grid>`

### 1.1 `<simple-value>` — cartão KPI / botão / imagem / HTML livre
O componente mais versátil e mais usado nos dashboards grandes. Duas partes:
- `<value-expression>` (obrigatório) — template HTML/CSS livre com
  placeholders `$CAMPO` (de uma `<expression>` opcional) e `:PARAMETRO`.
- `<expression type="sql">` + `<metadata>` (opcional) — alimenta os `$CAMPO`.

KPI "botão" com valor dinâmico:
```xml
<simple-value id="svl_pwjzej">
  <expression type="sql" data-source="MGEDS">
    <![CDATA[SELECT SUM(TGFCAB.VLRNOTA) AS VALOR_TOTAL_NOTA FROM TGFCAB ... ]]>
  </expression>
  <metadata>
    <field name="VALOR_TOTAL_NOTA" label="VALOR_TOTAL_NOTA" type="I" visible="true" useFooter="false" mask="R$ #.##0,00"/>
  </metadata>
  <value-expression>
    <![CDATA[<button style="background-color: DarkBlue; ... border-radius: 15px; box-shadow: 0 6px 12px rgba(0,0,0,.3);">
      <span style='font-size: 15px; font-weight: bold;'>
        <span style='color: #FFFFFF;'>$VALOR_TOTAL_NOTA</span>
      </span>
    </button>]]>
  </value-expression>
</simple-value>
```
Um `simple-value` dispara navegação/refresh como um grid (`on-click
navigate-to`, `on-click-launcher`) — funciona como botão clicável, inclusive
como menu principal cuja visibilidade é controlada por SQL dinâmico
(`display: inline-block|none` conforme permissão do usuário logado):
```xml
<value-expression><![CDATA[$V_BUTTON_INI display: $DISPLAY_VALUE $V_BUTTON_MED <b>Painel 1 - Análise Família e Produto</b> $V_BUTTON_FIN]]></value-expression>
<on-click navigate-to="lvl_k8bbp9"><param id="A_MARCA"/></on-click>
```
Logo/imagem estática sem SQL (comum no topo de cada nível):
```xml
<simple-value id="svl_k8bboq">
  <value-expression><![CDATA[<img src='http://www.dpsonline.com.br/.../logo270x70_v2.png'>]]></value-expression>
</simple-value>
```

### 1.2 `<chart>` — gráficos (`type="column|bar|line|gauge"`, entre outros do catálogo oficial)

Estrutura: `<expression>` + `<metadata>` (igual grid) + `<horizontal-axis>` /
`<vertical-axis>` + `<series>` + `<legend>`.

Colunas simples, com drill visual por série (clicar numa barra atualiza um
grid ao lado):
```xml
<chart id="cht_pwjy26" type="column" nroColuna="31">
  ...
  <horizontal-axis>
    <category field="" rotation="-90" dropLabel="false">
      <initView value="first"/>
    </category>
  </horizontal-axis>
  <series>
    <serie type="column">
      <xField>$DTNEG</xField>
      <yField>$VALOR_LIQ_ITEM</yField>
      <color>0xff</color>
      <refresh-details ui-list="grd_pwjy8r">
        <param id="A_DTNEG">$DTNEG</param>
      </refresh-details>
    </serie>
  </series>
</chart>
```
`<color>` usa notação hex estilo AS3 (`0xRRGGBB`, sem zeros à esquerda).

Linhas multi-série com legenda e tooltip customizado via `<display>`:
```xml
<vertical-axis>
  <linear resultRotation="-90" vResizing="true"><mask/></linear>
</vertical-axis>
<series>
  <serie type="line" circle-intersection="true" show-tip="false">
    <xField>$NOMECID</xField><yField>$VALOR_LIQ_ITEM</yField>
    <display><![CDATA[Valor Venda]]></display>
  </serie>
  ...
</series>
<legend position="bottom" direction="h"/>
```
Tooltip com placeholders e HTML:
```xml
<display><![CDATA[Informações<hr>Dias: $DIAS<br>Quantidade: $QUANTIDADE]]></display>
```

Colunas empilhadas com rótulo somado (`showStackLabels`):
```xml
<vertical-axis>
  <linear resultRotation="-76" vResizing="true"><mask/><showStackLabels /></linear>
</vertical-axis>
<series>
  <serie type="column"><xField>$MES_ANO</xField><yField>$RENTABILIDADE</yField><color>0x3300</color></serie>
  <serie type="column"><xField>$MES_ANO</xField><yField>$CUSTO</yField><color>0x0</color></serie>
  <serie type="column"><xField>$MES_ANO</xField><yField>$VALOR_LIQ_ITEM</yField><color>0x66ff</color></serie>
</series>
```

**Gauge (velocímetro)** para "giro de estoque em dias" — nota que o gauge
tem seus próprios `<args>` (recebe parâmetros de nível como um grid) e usa
um campo **calculado** como `<value-field>`:
```xml
<chart id="cht_mxet9e" type="gauge">
  <args>
    <arg id="A_MARCA" type="text"/>
    <arg id="A_CODMARCA" type="integer"/>
  </args>
  <expression type="sql" data-source="MGEDS">...</expression>
  <metadata>
    <field name="QUANTIDADE" .../>
    <field name="ESTOQUE" .../>
    <field name="GIRODIAS" label="Giro Dias" type="F" visible="true" useFooter="false">
      <calculated><formula><![CDATA[$ESTOQUE/$QUANTIDADE]]></formula></calculated>
    </field>
  </metadata>
  <show-ticks>true</show-ticks>
  <min-value>1</min-value>
  <max-value>120</max-value>
  <value-field>$GIRODIAS</value-field>
  <alert-colors values="1,30,45,70,90,120" colors="0xFF0000,0xFFFF00,0x00FF00,0xFFFF00,0xFF0000"/>
</chart>
```

### 1.3 `<pivot-table>` — tabela dinâmica / heatmap
```xml
<pivot-table id="pvt_bmq0wr" tamTexto="14">
  <expression type="sql" data-source="MGEDS">
    <![CDATA[WITH DiasUteisMes AS (...), DiasUteisAno AS (...), DiasPassados AS (...) SELECT ... ]]>
  </expression>
  <metadata>
    ... <field name="valorTotal" label="[123] Valor Total" type="C" visible="true" useFooter="SUM" mask="R$ #.##0,00"/>
    <field name="perc_rentab" label="% de Rentabilidade" type="F" visible="true" useFooter="false">
      <calculated><formula><![CDATA[(1-$CUSTO/$TOTAL_RENTAB) * 100]]></formula></calculated>
    </field>
  </metadata>
  <initial showDefaultView="true">
    <column-ini>DESCRICAOCOMPL</column-ini>
    <line-ini>ano</line-ini>
    <aggregatorName-ini>SOMA</aggregatorName-ini>
    <rendererName-ini>MAPA_CALOR</rendererName-ini>
    <vals-ini>valorTotal</vals-ini>
  </initial>
</pivot-table>
```
- `type="C"` em `<field>`: campo numérico "pivotável"/moeda, sempre com
  `mask="R$ ..."`, além dos tipos I/S/F/D.
- `rendererName-ini="MAPA_CALOR"` liga heatmap na visão inicial.
- `aggregatorName-ini` controla a agregação padrão (`SOMA` visto).

### 1.4 `<style>` embutido com pseudo-classe (dentro de CDATA de `value-expression`)
```xml
<button style="background-color: yellow; ...">
  <span id="textColor" style='color: #000000;'><b>Sub-Menu</b></span>
</button>
<style>    button:hover #textColor {
    color: #FFFF00;
}</style>
```

**Não há nenhum `<script>` JavaScript embutido em nenhum dos XMLs
analisados** — toda "lógica" é declarativa (SQL + templates de string +
`<formula>`). O único JS real do projeto é o `actions.js` server-side
(seção 6).

## 2. Mapa de navegação entre múltiplos `<level>`

`analise.vendas.xml` organiza **25 níveis** como hub-and-spoke: um nível
"Principal" com botões numerados leva a painéis de 1º nível, que abrem
sub-painéis — a numeração no `description` reflete a árvore:
```
lvl_k8bbop  "Principal"
 ├─ lvl_k8bbp9  "1 - Familia e Produto"
 │   └─ lvl_k8bbuk "1.1 - Empresa (Marca)"
 ├─ lvl_k8bb5y  "2 - Desempenho por Comprador"
 ├─ lvl_mofl21  "3 - Giro"
 ├─ lvl_qz689l  "4 - Marcadores de vendas"
 │   └─ lvl_q7uvc8 "4.1 - Análise Diária"
 ├─ lvl_qz69cj  "5 - Rentabilidade"
 │   ├─ lvl_ao9ggjx ... lvl_awob8yf "5.1..5.8"
 │   │    └─ lvl_kg4qj3 "5.8.1 Itens de grupo"
 ├─ lvl_aza3y5a "6. Ranking de clientes"
 ├─ lvl_azgcq8u "7. Análise Anual de Vendas"
 ├─ lvl_af38ei  "8. Desempenho por Vend. Repr."
 │   ├─ lvl_ug23yd "8.1 Planilha Vendedor"
 │   └─ lvl_ug24y5 "8.2 Planilha Representante"
 ├─ lvl_bmq0wn  "9. Analise Anual Beta"
 ├─ lvl_tli21o  "10. Grid Dinâmico"
 └─ lvl_af35pd  "IMAGEM"
```

Padrões de conexão:

1. **Hub-and-spoke com "voltar ao início"**: todo sub-nível tem um
   `<simple-value>` com logo cujo `on-click` volta direto ao nível
   Principal, sem `<param>`:
   ```xml
   <simple-value id="svl_qz69ck">
     <value-expression><![CDATA[<img src='.../logo270x70_v2.png'>]]></value-expression>
     <on-click navigate-to="lvl_k8bbop"/>
   </simple-value>
   ```
2. **Navegação com parâmetros "reset" fixos** — botões de menu que abrem um
   nível "sem filtro" passando sentinelas fixas (não vindas de linha
   clicada). Convenção: `-1` para integer, `"TODOS"` para text, tratado no
   SQL como `(:A_CODVEND = -1 OR CAMPO = :A_CODVEND)`:
   ```xml
   <on-click navigate-to="lvl_ao9ggjx">
     <param id="A_CODMARCA">-1</param>
     <param id="A_CODEMP">-1</param>
     <param id="A_MES">-1</param>
     <param id="A_CODPARC">-1</param>
     <param id="A_DESCRPROD">TODOS</param>
     <param id="A_CODVEND">-1</param>
   </on-click>
   ```
3. **`on-click` + `refresh-details` no MESMO elemento**: um clique pode
   navegar E atualizar componentes irmãos antes de sair, misturando grids,
   `simple-value` e `chart` num único `ui-list`, com `<param>` vindo de três
   origens (arg repassado `:A_MARCA`, campo da linha `$codparc`, ou
   constante):
   ```xml
   <on-click navigate-to="lvl_q7uvc8"><param id="A_CODEMP"/></on-click>
   <refresh-details ui-list="svl_qz69fl,svl_qz69ge,svl_qz69k0,svl_qz69g9,svl_qz69g8,svl_qz69k1,cht_ao9gf9l">
     <param id="A_MARCA">:A_MARCA</param>
     <param id="A_CODPARC">$codparc</param>
     <param id="A_CODMARCA">$CODMARCA</param>
   </refresh-details>
   ```
4. **Parâmetro literal fixo como flag de modo** — dois cliques no mesmo
   grid navegam para o **mesmo nível de destino** com comportamento
   diferente, controlado por uma constante (não `$CAMPO`):
   ```xml
   <on-click navigate-to="0DP">
     <param id="A_TIPO">$TIPO_DET</param>
     <param id="A_MODO">C</param>   <!-- literal fixo -->
   </on-click>
   <on-click navigate-to="0DP">
     <param id="A_TIPO">$TIPO_DET</param>
     <param id="A_MODO">M</param>   <!-- outro clique, outro modo -->
   </on-click>
   ```
   No nível de destino, `WHEN :A_MODO = 'C' ...` alterna agrupamento
   (Cliente vs Marca).
5. **`refresh-details` para atualizar múltiplos grids irmãos** (não
   navega, só repassa args para componentes já na tela):
   ```xml
   <refresh-details ui-list="grd_02D,grd_0DF,grd_02U">
     <param id="A_CODPARC">$CODPARC</param>
     <param id="A_NOMEPARC">$NOMEPARC</param>
   </refresh-details>
   ```
   Os grids-alvo declaram os mesmos `<arg>` **dentro de si mesmos** (não no
   `<level>`), permitindo que cada grid tenha seu conjunto de args por
   refresh, distinto dos args do `<level>` pai.

## 3. `<args>`/`<arg>` — tipos e padrões

Tipos confirmados: **`integer`** (mais comum), **`text`**, **`decimal`**
(mais raro — valores monetários/percentuais recebidos como filtro).

- **Parâmetros de prompt ficam acessíveis em SQL de níveis profundos sem
  precisar virar `<arg>`**: `:Ano`/`:Periodo`/`:Empresa` declarados uma vez
  no topo (`<prompt-parameters>`) são usados diretamente 2 saltos de
  navegação abaixo, sem nunca aparecer em `<args>`. Só valores **oriundos de
  coluna clicada** (`$CAMPO`) precisam virar `<arg>` explícito no nível de
  destino.
- **Todo componente que roda `<expression type="sql">` num nível de
  detalhe pode declarar seus próprios `<arg>`** — não é exclusivo de
  `<grid>`; `<chart>`/`<gauge>` também têm `<args>` (seção 1.2).
- **`<args>` acumula TODOS os ids usados por qualquer grid/on-click daquele
  nível**, mesmo de fluxos diferentes — funciona como namespace único de
  variáveis do nível (visto com 9 args simultâneos em um único nível de
  detalhe de comissão).
- Um mesmo `<level>` pode ter args nunca usados na query do primeiro grid,
  usados só em componentes irmãos mais abaixo.

## 4. `<formatter>` — formatação condicional de célula

Operadores confirmados: `equalThan`, `greaterThan`, `greaterEqualThan`,
`lessThan`, `lessEqualThan`, `isEmpty`, e o modo genérico `formula="true"`.

Seta verde/vermelha de crescimento:
```xml
<field name="COMPAR_VLR" label="% Cresc. A.A Vlr." type="F" visible="true" useFooter="false" mask="#.##0,00 %">
  <formatter lessThan="0">
    <![CDATA[<span style="color:#990000; background-color:#FFCCFF; src:iconArrowDown"><b>$VALUE</b></span>]]>
  </formatter>
  <formatter greaterThan="0">
    <![CDATA[<span style="color:#003300; background-color:#66FFCC; src:iconArrowUp"><b>$VALUE</b></span>]]>
  </formatter>
  <calculated><formula><![CDATA[(($VALOR/$VALOR_AA)-1)*100]]></formula></calculated>
</field>
```
Ícones internos identificados via `src:iconX` dentro do `style` do
`<span>`: `iconAccept`, `iconArrowDown`, `iconArrowDownRight`,
`iconArrowRight`, `iconArrowUp`, `iconArrowUpRight`, `iconForbidden`,
`iconWarning`.

`formula="true"` — fórmula booleana referenciando **outros campos da
mesma linha**, não só o próprio valor:
```xml
<field name="CODVEND" label="Cód." type="I" visible="true" useFooter="false">
  <formatter formula="true">
    <formula><![CDATA[$TIPVEND=='G']]></formula>
    <![CDATA[<span style="; src:iconWarning">$VALUE</span>]]>
  </formatter>
  <formatter formula="true">
    <formula><![CDATA[$CODVEND=='0']]></formula>
    <![CDATA[<span style="; src:iconForbidden">$VALUE</span>]]>
  </formatter>
</field>
```
`isEmpty="false"` usado só para pintar fundo de toda a coluna (highlight
fixo, sem condição real de vazio):
```xml
<field name="DTNEG" label="Dt.Neg." type="D" visible="true" useFooter="false">
  <formatter isEmpty="false">
    <![CDATA[<span style="; background-color:#FFFFCC">$VALUE</span>]]>
  </formatter>
</field>
```
Múltiplas regras `<formatter>` podem coexistir: **a primeira verdadeira, na
ordem da grade, prevalece.**

## 5. Cor de linha inteira via SQL (`BKCOLOR`/`FGCOLOR`)

Diferente do `<formatter>` (por célula) — a query retorna colunas com nomes
exatos `BKCOLOR`/`FGCOLOR`, marcadas `visible="false"` no metadata; o grid
reconhece e pinta a **linha inteira**:
```sql
CASE WHEN AA.ORDENACAO = 0 THEN '#FFFFFF' WHEN MARCA = 'CWB GERAL' THEN '#b12d2d' END AS BKCOLOR,
CASE WHEN AA.ORDENACAO = 0 THEN '#FFFFFF' WHEN MARCA = 'CWB GERAL' THEN '#FFFFFF' END AS FGCOLOR,
```
```xml
<field name="BKCOLOR" label="BKCOLOR" type="S" visible="false" useFooter="false"/>
<field name="FGCOLOR" label="FGCOLOR" type="S" visible="false" useFooter="false"/>
```
Usado, por exemplo, para destacar uma linha "total/separador" (injetada via
`UNION ALL` com `ORDENACAO = 0`) com fundo diferente do resto da tabela.

## 6. `<local-vars>` — variáveis SQL reutilizáveis

Só em `analise.vendas.xml`, no nível `<gadget>` (antes de qualquer
`<level>`): variáveis SQL (`SELECT ... FROM DUAL`) que retornam fragmentos
HTML/CSS reutilizados como `$NOME` em múltiplos componentes — evita
duplicar o mesmo `<button style="...">` gigante em dezenas de
`value-expression`:
```xml
<local-vars>
  <var id="V_BUTTON_INI" label="V_BUTTON_INI">
    <expression type="sql" data-source="MGEDS">
      <![CDATA[SELECT '<button style="' AS BUTTON_INI FROM DUAL]]>
    </expression>
  </var>
  <var id="V_BUTTON_MED" label="V_BUTTON_MED">
    <expression type="sql" data-source="MGEDS">
      <![CDATA[SELECT '; padding: 10px 20px; background-color: #ed3237; ...">' AS BUTTON_MED FROM DUAL]]>
    </expression>
  </var>
  <var id="V_BUTTON_FIN" label="V_BUTTON_FIN">
    <expression type="sql" data-source="MGEDS"><![CDATA[SELECT '</button>' AS BUTTON_FIN FROM DUAL]]></expression>
  </var>
</local-vars>
```
Uso: `<![CDATA[$V_BUTTON_INI display: $DISPLAY_VALUE $V_BUTTON_MED <b>Painel 1</b> $V_BUTTON_FIN]]>`.

Controle de visibilidade por permissão de usuário (campo custom
`AD_ACESSODASHNIVEL1/2/3` em `TSIUSU`), usando o parâmetro implícito
`:CODUSU_LOG` sem declará-lo em `<prompt-parameters>`:
```sql
SELECT CASE WHEN :CODUSU_LOG IN (SELECT CODUSU FROM TSIUSU WHERE AD_ACESSODASHNIVEL1 = 'S') OR :CODUSU_LOG = 0
THEN 'inline-block' ELSE 'none' END AS DISPLAY_VALUE FROM DUAL
```

## 7. Campos calculados e agregação customizada

### 7.1 `<calculated><formula>` — coluna derivada por linha
```xml
<field name="perc_rentab" label="% de Rentabilidade" type="F" visible="true" useFooter="false">
  <calculated><formula><![CDATA[(1-$CUSTO/$TOTAL_RENTAB) * 100]]></formula></calculated>
</field>
```

### 7.2 `<aggregates per="PER">` + `<personalized>` — rodapé com fórmula própria
Para colunas percentuais/razão, somar linha a linha no rodapé dá resultado
errado — sobrescrever a fórmula do totalizador:
```xml
<field name="CALC_RENTAB" label="Rentabilidade(%)" type="F" visible="true" useFooter="PER" mask="#.##0,00 %">
  <aggregates per="PER">
    <text><![CDATA[Dias]]></text>
    <personalized><![CDATA[(1-(SUM($CUSTO)/SUM($TOTAL_RENTAB)))*100]]></personalized>
  </aggregates>
  <calculated><formula><![CDATA[(1-($CUSTO/$total_rentab))*100]]></formula></calculated>
</field>
```
`useFooter="PER"` (não `SUM`) diz ao grid "use a fórmula personalizada do
rodapé" — o `<personalized>` reagrega com `SUM()` os campos-base, não a
própria coluna calculada.

## 8. `metadata.xml` ao lado de um dashboard

Não é metadado do gadget — é o **dump de definição da tabela customizada
(`AD_*`)** que alimenta as queries do gadget, gerado pelo Sankhya via
"Exportar tabela/instância" para recriar a tabela em outro ambiente:
```xml
<metadata>
  <exportInfo>
    <exportTime>10/06/2026 11:01:07</exportTime>
    <systemVersion>4.35b695</systemVersion>
    <dbMetadata>...</dbMetadata>
  </exportInfo>
  <instances>
    <instance name="AD_COMISSAODPS" isUpdate="false">
      <instanceDescription><![CDATA[Comissão DPS]]></instanceDescription>
      <tableInfo name="AD_COMISSAODPS" sequenceType="M">
        <category>...</category>
        <primaryKey><NUNOTA/><NUNOTAORIG/><SEQUENCIA/></primaryKey>
      </tableInfo>
      <fields>
        <field name="CODVEND" systemField="N" dataType="I" presentationType="P"
               calculated="N" allowSearch="S" allowDefault="S" visibleOnSearch="S"
               allowNull="S" size="5">
          <description><![CDATA[Comissionado]]></description>
        </field>
        <field name="SITUACAO" ... presentationType="O" ...>
          <options>
            <option value="A"><![CDATA[Aprovada]]></option>
            <option value="C" default="S"><![CDATA[Cancelada]]></option>
          </options>
        </field>
      </fields>
      <relationShip>
        <relation entityName="Parceiro" type="I" insert="N" update="N" remove="N">
          <targetInfo systemInstance="S" tableName="TGFPAR"/>
          <fields><field localName="CODPARC" targetName="CODPARC"/></fields>
        </relation>
      </relationShip>
    </instance>
  </instances>
</metadata>
```
Não contém layout de tela nem SQL de dashboard — só schema da tabela `AD_*`
(campos, PK composta, relacionamentos). É o que permite `metadata="entity:X@Y"`
em parâmetros referenciando esses campos. Serve como documentação viva do
schema consumido pelas queries do gadget.

**Convenção a seguir em dashboards novos**: sempre que criar uma tabela
`AD_*` auxiliar para um dashboard, exportar e manter o `metadata.xml`
irmão documentando o schema.

## 9. `entityName` no `<grid>` — grid amarrada a entidade nativa (habilita Ações)

```xml
<grid id="grd_02B" entityName="Estoque" multiplaSelecao="N" useNewGrid="S">
  ...
<grid id="grd_02C" entityName="EstoqueEndereco" multiplaSelecao="N" useNewGrid="S">
```
`entityName` amarra a grid a uma entidade Sankhya nativa — é o gancho que
habilita abrir cadastro/Ações daquela entidade a partir do dashboard. Ver
seção seguinte para como isso se conecta a um `.js` de ações customizadas.

## 10. Vínculo dashboard ↔ `.js` de ações customizadas (padrão `acerto_estoque`)

**Não existe tag XML no gadget que referencie o `.js`** — o vínculo é
conceitual: `acerto_estoque_actions.js` documenta em seus comentários que
deve ser **colado manualmente no campo "Script" de uma Ação cadastrada no
Sankhya**, associada à tela de cadastro da mesma entidade referenciada por
`entityName` no grid do dashboard (`EstoqueEndereco` → tabela `TGWEST`):
```
// Gadget      : sk-dash/acerto estoque/acerto_estoque.xml
// Tela-alvo   : Tela de cadastro da entidade EstoqueEndereco (TGWEST)
// Cole o conteúdo abaixo no campo "Script" da ação "Incluir Estoque WMS":
```
O dashboard mostra a grid consultável (read-only); a ação de escrita fica
configurada fora do XML, no cadastro de Ações da tela, e o `.js` é o
"código-fonte" documentado dessas ações para versionamento/reuso. É a API
**server-side de Ações** (não é `SankhyaAPI`/`gadget.*` de browser) —
documentada em `06-acoes-customizadas.md`.

Padrão replicável: **um `.js` por dashboard operacional**, comentado com
cabeçalho (tabela alvo, gadget, tela-alvo, API disponível), dividido em
blocos claramente demarcados com separador `// ====` e nome da ação, cada
bloco autocontido (variáveis com sufixo único por ação, ex. `_inc`, `_aum`,
`_dim`, para evitar colisão ao copiar trechos isolados).

## 11. `on-click-launcher` — abrir tela nativa ou outro dashboard/relatório

```xml
<on-click-launcher resource-id="br.com.sankhya.core.cad.produtos">
  <CODPROD/>
</on-click-launcher>
```
- `resource-id` usa notação de pacote Java e pode apontar para:
  - tela nativa (`br.com.sankhya.core.cad.produtos`,
    `br.com.sankhya.com.mov.CentralNotas`,
    `br.com.sankhya.fin.con.agendaFinanceira`,
    `br.com.sankhya.fin.con.saldoBancario`),
  - outro dashboard (`br.com.sankhya.menu.adicional.nuDsb.<id>.<versão>`),
  - um relatório (`br.com.sankhya.menu.adicional.rfe.<id>.<versão>`).
- Tags filhas tipadas (`<CODPROD/>`, `<NUNOTA/>`, `<CODPARC/>` etc.,
  self-closing quando sem valor, ou `$CAMPO` quando vindo da linha) passam
  parâmetros/PK para a tela/dashboard/relatório alvo.

## 12. Diferença estrutural: "menu" vs "dashboard" de dados

`dps menu financeiro/menu financeiro.xml` **é um `<gadget>` válido** (mesma
raiz XML), mas na prática é um "launcher" — confirmado por grep: **zero**
ocorrências de `<prompt-parameters>`, `<parameter>`, `<grid>`, `<expression
type="sql">`, `<args>`/`<arg>`, `<chart>`, `<pivot-table>`, `<metadata>`,
`<on-click navigate-to>`. Só **um `<level>` (`"Principal"`)** — sem
navegação interna nem parametrização de entrada.

```xml
<gadget>
  <level id="lvl_ah6axsg" description="Principal">
    <container orientacao="V" tamanhoRelativo="100">
      <container orientacao="V" tamanhoRelativo="7.142857142857143">
        <simple-value id="svl_aklfm6u">
          <value-expression>
            <![CDATA[<button style="background-color: Gray; ...">
              <span style="font-size: 15px;"><span style='color:#FFFFFF;'>Saldo Bancário</span></span>
            </button>]]>
          </value-expression>
          <on-click-launcher resource-id="br.com.sankhya.fin.con.saldoBancario">
            <CODCTABCOINT/>
          </on-click-launcher>
        </simple-value>
      </container>
      ...
```

| Aspecto | Dashboard de dados | Menu |
|---|---|---|
| `<prompt-parameters>` | Sim | Ausente |
| `<grid>`/`<chart>`/`<pivot-table>` | Sim | Ausente |
| `<expression type="sql">` | Onipresente | Zero |
| Nº de `<level>` | Múltiplos, árvore de navegação interna | Apenas 1 |
| Navegação | `navigate-to` interno | 100% via `on-click-launcher` externo |
| Conteúdo de cada célula | KPI dinâmico (SQL) | Botão estático |
| Layout | Containers profundamente aninhados, proporções variadas | Grade regular repetitiva, containers vazios como espaçador |

Container vazio (`<container orientacao="V" tamanhoRelativo="..."/>` sem
filho) é técnica válida de "placeholder" para manter grade fixa de botões
com posições futuras vagas — **só** válido nesse padrão de menu; em
dashboard de dados normal, container de 2º nível vazio gera erro (ver
`04-dash-gadget-componentes-avancados.md`, aviso do Layout Flexível).

## 13. Duas variações do mesmo dashboard: "comissao geral" (individual) vs "comissao gerencial"

Mesmo esqueleto (header HTML, grids de detalhe, args em `0DP`), propósito
diferente via origem do filtro:

- **`comissao gerencial`**: parâmetro `Empresa` (`entity:Empresa@CODEMP`)
  no prompt — usuário escolhe o vendedor a consultar. 3 níveis: `01Q
  (Principal) → 0FL (Filtro) → 0DP (Detalhe)`.
- **`comissao geral` (individual)**: **sem** parâmetro `Empresa` — resolve
  o vendedor a partir do usuário logado via função de sistema, então cada
  vendedor só vê a própria comissão. 2 níveis: `01Q → 0DP` (sem o
  intermediário).
  ```sql
  WITH USUARIO AS (
      SELECT sankhya.STP_GET_CODUSULOGADO() AS CODUSU_LOGADO
  ),
  VENDEDOR_LOGADO AS (
      SELECT VEN.CODVEND ...
      FROM TSIUSU USU CROSS JOIN USUARIO U
      ... AND VEN.CODVEND = USU.CODVEND
  )
  ...
  CASE WHEN (SELECT CODUSU_LOGADO FROM USUARIO) = 23 THEN 1 ELSE 0 END AS EH_MULTI_EMPRESA,
  (SELECT CODVEND FROM VENDEDOR_LOGADO) AS CODVEND_FILTRO
  ```
Padrão replicável: derivar "self-service" (cada usuário só vê o seu) via
`sankhya.STP_GET_CODUSULOGADO()` em vez de um `entity:` parameter, quando o
dashboard for pessoal em vez de gerencial.

## 14. Componente HTML5 — pacote JSP real (`sk-dash/modelo/`)

`sk-dash/modelo/` é o **modelo oficial baixado** (o que os botões "Download
Modelo Simples/Completo/JavaScript HTML5" do Construtor de BI geram —
ver `04-dash-gadget-componentes-avancados.md` § Controles > HTML5), com um
dashboard de 2 níveis funcional: nível "Primeiro" com 2 componentes HTML5
lado a lado (Parceiro mestre + Contato detalhe), nível "Segundo" com um
gráfico Pizza de receita/despesa do parceiro.

### Tag XML que hospeda o componente

```xml
<container orientacao="V" tamanhoRelativo="50">
  <html5component id="html5_ulnyo5" entryPoint="model_Parceiro.jsp"/>
</container>
<container orientacao="V" tamanhoRelativo="50">
  <html5component id="html5_ulnyo6" entryPoint="model_Contato.jsp"/>
</container>
```
`entryPoint` é o nome do `.jsp` (dentre os que foram anexados no pacote)
que será renderizado como corpo do componente. `id` é o identificador
usado como alvo de `refreshDetails(componentID, params)` a partir de
**outro** componente HTML5 do mesmo nível (padrão master/detail).

### Cabeçalho obrigatório de todo `.jsp` do pacote

```jsp
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="UTF-8" isELIgnored="false"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>
<html>
<head>
	<title>HTML5 Component</title>
	<link rel="stylesheet" type="text/css" href="${BASE_FOLDER}/css/parceiroCSS.css">
	<snk:load/> <!-- essa tag deve ficar nesta posição -->
	<script type='text/javascript'>...</script>
</head>
<body>...</body>
</html>
```
- `${BASE_FOLDER}` — variável EL injetada pelo Sankhya, aponta para a raiz
  do pacote HTML5 dentro do servidor (usar para referenciar `css/`, `js/`
  etc. do próprio pacote).
- `<snk:load/>` **deve ficar nessa posição no `<head>`** (comentário do
  próprio modelo oficial) — carrega o runtime JS do Sankhya
  (`executeQuery`, `openLevel`, etc.); sem ela essas funções não existem.

### Padrão A — "Completo": SQL server-side via `<snk:query>` + JSTL

`model_Parceiro.jsp` (mestre) e `model_Contato.jsp` (detalhe) renderizam a
tabela **no servidor** via JSTL, usando a mesma sintaxe `:PARAM` do SQL de
Gadget normal, dentro de uma tag customizada `<snk:query>`:
```jsp
<snk:query var="parceiros">
	select * from TGFPAR where CODPARC IN (:CODPARC_LIST) order by CODPARC asc
</snk:query>

<table border="1">
	<caption><h3>Parceiros</h3></caption>
	<tr><th>Código</th><th>Nome do Parceiro</th><th></th><th></th></tr>
	<c:forEach items="${parceiros.rows}" var="row">
		<tr>
			<td><c:out value="${row.CODPARC}" /></td>
			<td><c:out value="${row.NOMEPARC}" /></td>
			<td><button onclick="javascript:abrirContatos( ${row.CODPARC} )">Ver contatos</button></td>
			<td><button onclick="javascript:abrirFinanceiros( ${row.CODPARC} )">Ver financeiros</button></td>
		</tr>
	</c:forEach>
</table>
```
`${parceiros.rows}` expõe o resultado como coleção iterável; cada `row`
tem os campos do `SELECT` como propriedades (`row.CODPARC`). Botões da
linha chamam funções JS locais que disparam a API de navegação:
```jsp
<script type='text/javascript'>
	function abrirContatos(codParc){
		var params = {'CODPARC' : codParc};
		refreshDetails('html5_ulnyo6', params);   // atualiza o componente-detalhe (id do html5component)
	}
	function abrirFinanceiros(codParc){
		var params = {'CODPARC' : codParc};
		openLevel('lvl_ulnyo9', params);          // navega para outro <level> do gadget
	}
</script>
```
`model_Contato.jsp` (o detalhe) mistura JSTL com **scriptlet Java puro**
dentro do corpo de `<snk:query>` — mostra que `<snk:query>` aceita SQL
montado dinamicamente em Java, não só CDATA estático:
```jsp
<snk:query var="contatos">
	<%
		String query = "select * from TGFCTT where ";
		if (request.getAttribute("CODPARC") != null) {
			query += " CODPARC = :CODPARC ";
		} else {
			query += " 1 <> 1 ";   // nenhum resultado quando o arg ainda não chegou
		}
		query += " order by CODPARC asc ";
		out.println(query);
	%>
</snk:query>
```
`${CODPARC}` (EL puro, sem `.rows`) acessa diretamente o valor do
`<arg>`/parâmetro recebido pelo nível — usado tanto no scriptlet
(`request.getAttribute("CODPARC")`) quanto no HTML (`Contatos (parceiro: ${CODPARC})`).

### Padrão B — "Simples/JavaScript": SQL client-side via `executeQuery`

`JSP_MODELO.jsp` mostra o outro padrão: nenhuma renderização server-side,
tudo montado em runtime no browser via `executeQuery`, que recebe a query
com `?` como placeholder posicional e um array paralelo de bindings
tipados:
```js
var query1 = "SELECT TO_CHAR(DTALTER,'DD/MON/YYYY') AS DTALTER, CODPARC, NOMEPARC, RAZAOSOCIAL, TIPPESSOA FROM TGFPAR WHERE CODPARC IN (?) ";
var arr = [{value:"${MULTSQLTESTE}", type:"IN"}];   // multiList:Text

if ("${DHTESTE}" != "") { query1 += " AND DTALTER >= ? "; arr.push({value:"${DHTESTE}", type:"D"}); }        // Data/Hora
if ("${DTALTER}" != "") { query1 += " AND DTALTER >= ? "; arr.push({value:"${DTALTER}", type:"D"}); }        // Data
if ("${PERTESTE.INI}" != "") { query1 += " AND DTALTER >= ? "; arr.push({value:"${PERTESTE.INI}", type:"D"}); } // Período (início)
if ("${PERTESTE.FIN}" != "") { query1 += " AND DTALTER <= ? "; arr.push({value:"${PERTESTE.FIN}", type:"D"}); } // Período (fim)
if ("${CODPARC}" != "") { query1 += " AND CODPARC = ? "; arr.push({value:"${CODPARC}", type:"I"}); }         // Entidade/Tabela
if ("${RAZAOSOCIAL}" != "") { query1 += " AND RAZAOSOCIAL = ? "; arr.push({value:"${RAZAOSOCIAL}", type:"S"}); } // Texto

// singleList:Text — recebe "" quando não há opções, "0" quando há opções mas nenhuma selecionada; checar as duas
if ("${SINGSQLTESTE}" != "0" && "${SINGSQLTESTE}" != "") {
    query1 += " AND CODPARC = ? "; arr.push({value:"${SINGSQLTESTE}", type:"I"});
}
query1 += " ORDER BY CODPARC ASC ";

executeQuery(query1, arr, function(value){
    var dadosTabela = JSON.parse(value);   // [{"COL1":"VAL","COL2":"VAL"}, ...]
    // ...montar DOM manualmente (insertRow/insertCell)...
}, function(value){
    alert(value);   // callback de erro
});
```
Tabela de tipos aceitos no array de binding: `"D"` (Data/Data-Hora/cada
metade de Período), `"S"` (Texto), `"I"` (Inteiro/Entidade/singleList),
`"IN"` (multiList:Text, expande para a lista do `IN (?)`).

## 15. Tabela de atributos/tags não óbvios — referência rápida

| Tag/atributo | Onde | Função |
|---|---|---|
| `tamTexto="12"` | `<grid>`, `<pivot-table>` | Tamanho de fonte |
| `entityName="Estoque"` | `<grid>` | Amarra a entidade nativa (habilita Ações) |
| `multiplaSelecao="N"/"S"` | `<grid>` | Seleção múltipla de linhas |
| `useNewGrid="N"` | `<grid>` | Variante legada (ex.: mini-lista seletora de filtro) |
| `<title><![CDATA[ATENDENTE: :A_NOMEATENDENTE]]></title>` | `<grid>` | Título dinâmico interpolando arg — mostra contexto do drill-down |
| `(:PARAM IS NULL OR CAMPO = :@PARAM)` | SQL | Filtro opcional — parâmetro vazio não filtra |
| `WHERE FAIXA_CALC IN :FAIXA` | SQL | Multi-lista alimentando `IN` |
| Linha-sentinela via `UNION ALL` com `P.MSG_ERRO`/flag de validação | SQL | Retorna mensagem amigável na própria grid sem falhar a query (ver `02-sql-padroes.md`) |

## 16. Parâmetros do prompt NÃO são reativos/em cascata

Checagem exaustiva (grep em todo `sk-dash/*.xml`): nenhum `<parameter listType="sql">`
deste workspace referencia outro `:P_X` dentro da própria query de lista. O
Construtor de BI nativo resolve todos os parâmetros do `<prompt-parameters>`
de uma vez, na abertura da tela de filtros — escolher um valor num parâmetro
não reconsulta a lista de outro (diferente de um formulário web comum com
campos dependentes). Ao desenhar um dashboard novo com dois filtros
relacionados (ex.: Marca → Produto da marca), não desenhar como cascata
reativa — alternativas usadas em produção:
- Listar tudo, mas ordenar/rotular pelo campo "pai" (ex.: `LABEL = MARCA + ' - ' + PRODUTO`, `ORDER BY MARCA, PRODUTO`) para facilitar achar visualmente, com o SQL final da query de dados ainda combinando os dois parâmetros corretamente.
- Ou usar 2 níveis (`<level>`) — o primeiro só com o filtro "pai", que ao navegar (`on-click navigate-to`) já leva o valor escolhido como `<arg>` fixo para o nível seguinte, que aí sim roda a query "filha" já restrita.

**Cuidado com o tamanho da lista no padrão "listar tudo"**: em
`sk-dash/desempenho vendas marca/desempenho_vendas_marca.xml` esse padrão foi
tentado para um parâmetro `P_PRODUTO` (todo `TGFPRO`, ~63 mil linhas,
rotulado por marca) e causou lentidão perceptível na abertura da tela de
filtros do dash — o componente `multiList:Text` do Construtor de BI não
pagina/virtualiza bem listas dessa ordem de grandeza. O parâmetro foi
**removido** do dashboard (usuário decidiu filtrar só por Marca, sem filtro
de Produto). Regra prática: reservar `listType="sql"` em `multiList:Text`
para listas na casa das centenas/poucos milhares de linhas (ex.: `TGFMAR`
com ~250 marcas é ok); para uma tabela de dezenas de milhares de linhas
(produtos, parceiros), preferir o padrão dos 2 níveis (`<level>`) descrito
acima, ou simplesmente não oferecer aquele filtro se não for essencial.

## 17. `AD_DPSFERIADOS` — nome de coluna confirmado: `EXPEDIENTENORMAL`

A coluna real no banco é **`EXPEDIENTENORMAL`** (com L) — confirmado pelo
usuário. `sk-bd/feriados/insert_ad_dpsferiados.sql` (3 ocorrências) grava com
o nome **`EXPEDIENTENORMA`** (sem L) no `INSERT INTO ... (...)`, o que só
funciona se a coluna tiver um alias/sinônimo sem L no banco, ou se o script
estiver desatualizado em relação à estrutura real — não copiar esse script
como referência de nome de coluna. O SQL de produção em `analise.vendas.xml`
(`WHERE EXPEDIENTENORMAL = 'S'`) e o novo dashboard `sk-dash/desempenho
vendas marca/desempenho_vendas_marca.xml` usam a forma correta com L; usar
sempre `EXPEDIENTENORMAL` em CTEs novos que consultem essa tabela.

Também: hoje só existem linhas de feriados carregadas para `CODEMP=9` no
script deste repositório — um CTE que junta `AD_DPSFERIADOS` por empresa deve
prever fallback (contagem seg-sex pura) para empresas sem nenhuma linha
cadastrada, em vez de um `LEFT JOIN` simples que zeraria os dias úteis
delas. Ver `DiasUteis`/`EmpresasComFeriados` em
`sk-dash/desempenho vendas marca/desempenho_vendas_marca.xml` para o padrão
de fallback implementado.
