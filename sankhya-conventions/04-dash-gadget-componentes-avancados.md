# Componentes de BI avançados — catálogo oficial Sankhya

> Fonte: documentação oficial salva localmente em
> `sk-docs/sk-ia/Construtor de Componentes de BI – Sankhya Gestão de
> Negócios.html` (módulo Configurações > Avançado > Construtor de
> Componentes de BI). Este arquivo cobre tudo que **não** está no básico
> (`03-dash-gadget-basico.md`) — é o catálogo de recursos disponíveis para
> dashboards mais complexos.

## Licenciamento (checar antes de planejar um dashboard grande)

- **20495 – JIVA-ANÁLISES PARA DASHBOARDS/W** (Jiva Om): limita quantidade de
  análises em dashboards personalizados/adquiridos. Estourar bloqueia
  visualização ou instalação via Jiva Place.
- **20482 – JIVA-DASHBOARD VIEWER/W**: visualizador que não consome licença
  de "análises"; se os assentos de visualização se esgotarem, nenhum
  dashboard abre.
- Variante mais nova: **30616 – EDITOR DE DASHBOARD/W** + **30647 –
  DASHVIEWER/W**, mesma lógica de não-consumo cruzado.
- `TSIPAR` **`USADASHANT`** ("Usa dashboard antigo"): se ativo, o quadro
  "Ferramentas" de layout flexível some (volta ao modo legado).

## Catálogo completo de componentes

**Controles:** Valor, Tabela, Tabela Dinâmica (pivot), Geomapa, HTML5, IReport (relatório embutido).

**Gráficos:** Linha, Barras, Colunas, Pizza, Análise de Rentabilidade, Velocímetro (Gauge), Geográfico, Área, Donut, Bolha, TreeMap, Dispersão (Scatter), Radar, Funil, Intervalo de Área.

Toolbar por componente: **Alterar tipo** (só Gráficos — trocar tipo de chart sem refazer), **Mover para cima/baixo**, **Editar** (duplo clique), **Remover** (Delete).

## Cartões Inteligentes (Smart Cards)

Exibe um gadget como card na área de trabalho do usuário. Requisitos:
- Componente ativo, sem parâmetros/filtros.
- Nenhum nível com mais de 1 gadget (exceção: componentes **Valor**, sem limite).
- Controle de acesso por usuário na tela **Acessos**; card só some de lá se o componente for excluído (desativar preserva permissões salvas).

## Área de Trabalho — Layout Flexível (multi-coluna)

- Quadro **"Ferramentas"**: aba **Dividir** (divide área/coluna em N colunas) e **Inserir** (acrescenta colunas).
- Botões: Desfazer última ação, Excluir coluna selecionada, Limpar coluna selecionada (mantém coluna, remove conteúdo), Mesclar coluna selecionada (volta componentes ao painel principal).
- **Layout "Top-Down"** (só vertical) vs **"Personalizado"** (padrão — vertical e horizontal simultâneos).
- **Aviso importante:** não deixar containers de 2º nível vazios — o sistema tenta interpretá-los como contendo um gadget e gera erro.

## Fontes de dados externas

`data-source` não precisa ser sempre `MGEDS` — o Sankhya permite consumir
bancos de dados **externos** ao Sankhya Om como fonte de um dashboard.
Doc completa já baixada e minerada:
`sk-docs/sk-ia/bancos-de-dados-dashboards.md`.

- SGBDs suportados: **PostgreSQL, Firebird, DB2, SQL Server** (o artigo
  também exemplifica Oracle e MySQL).
- Setup de infraestrutura (uma vez, feito pelo admin do servidor, não pelo
  autor do dashboard): driver JDBC do banco copiado para
  `$jboss\server\default\lib` + bloco `<local-tx-datasource>` cadastrado
  em `$jboss\server\default\deploy\mge-ds.xml` com `<connection-url>`,
  `<driver-class>`, `<user-name>`/`<password>` etc.
- **O que importa para quem escreve o Gadget**: o `<jndi-name>` desse
  bloco é um **nome escolhido livremente pelo admin** (exemplos reais do
  artigo: `homologaMYSQL`, `homologaPostgresql`) — **não precisa ser
  `MGEDS`**. Esse nome é literalmente o valor a usar em
  `data-source="homologaMYSQL"` dentro de `<expression type="sql"
  data-source="...">` para rodar a query contra o banco externo em vez do
  MGEDS nativo.
- Mesmo mecanismo de fonte de dados é usado por **Extrator de Dados** e
  **Consolidador de Dados** (telas relacionadas, fora do escopo de
  Gadget/BI em si).

## Dashboards embarcados em Add-on (Add-on Studio)

Caminho separado do Construtor de BI (tela do Sankhya Om, foco deste
documento): **embarcar um dashboard já pronto dentro de um Add-on**
(Add-on Studio ≥ 2.0, Sankhya Om mínimo 4.35b44) — relevante se o projeto
novo for distribuído como addon em vez de um Gadget solto. Doc completa já
baixada em `sk-docs/sk-ia/dashboards-embarcados.md`. Fluxo resumido:
1. Criar/exportar o dashboard normalmente no Sankhya Om (Construtor de BI);
   o `.zip` exportado contém `dashboardMetadata.xml`.
2. Mover esse XML para a pasta `dashboards` do projeto Add-on Studio.
3. Referenciá-lo via `<dashboard id="..." file="..." description="..."/>`
   dentro de um `<menu>` ou `<nativeFolder>` no `datadictionary`:
   ```xml
   <menu id="dash" description="Dashboard" icon="/$ctx/assets/icon_2.png">
     <dashboard id="1" file="dashboardMetadata.xml" description="Dashboard Teste 1"/>
     <folder id="folder" description="Dashboards">
       <dashboard id="2" file="dashboard3" description="Dashboard Teste 2"/>
     </folder>
   </menu>
   ```
4. `./gradlew clean deployAddon`.

**Cuidado:** o atributo `id` da tag `<dashboard>` deve ser único e
**nunca reeditado** após instalado em cliente (o Sankhya OM interpreta
mudança de id como item novo, exigindo nova liberação de acesso) —
convenção recomendada: ids numéricos incrementais, nunca reaproveitados.

## Aba BIA (presente em quase todo componente)

BIA = **Sankhya BIA (Business Intelligence Analyst)**, o app mobile
assistente virtual da Sankhya (Android/iOS) que responde perguntas sobre a
operação por voz/texto — **não é uma feature do editor do Gadget em si**,
é um produto separado que consome os dashboards já publicados. Doc
completa já baixada e minerada: `sk-docs/sk-ia/bia-business-intelligence-
analyst.md`.

- Duas fontes de pergunta: **Nativas** (Gerente On-line) e
  **Customizadas/treinadas** (Dashboards customizados — é aqui que um
  dashboard novo se conecta à BIA).
- Uma pergunta treinada é criada na tela **Central de Perguntas** (dentro
  do app, menu Preferências): escolhe-se o **dashboard** + a **área/
  componente** dentro dele, e define-se a frase que dispara a consulta.
  A aba "BIA" no editor do componente (Construtor de BI) é o atalho para
  essa mesma associação a partir da tela de edição.
- **Filtros da BIA = filtros do dashboard**: parâmetro `required="true"`
  no Gadget vira exigência da BIA também; parâmetro não informado na
  pergunta usa o **último valor salvo pelo usuário** no Sankhya para
  aquele dashboard (mesmo efeito de `keep-last="true"`).
- Requisito de infraestrutura: servidor liberado para acesso externo
  (`bia-production.sa-east-1.elasticbeanstalk.com`, TCP 80/22); endereço
  externo configurado no app **sem** o sufixo `/mge` (senão falha
  autenticação e exibição dos dashboards).
- `TSIPAR` **`CACHESYNCBIA`** — controla cache de sincronização de
  dashboards/permissões consultados pela BIA; manter no padrão (ativado).

Não há nada específico a configurar no XML do Gadget além do que já é
padrão — construir o dashboard normalmente e testar a associação via
Central de Perguntas depois de publicado.

## Restrição de acesso a dashboard ("Central de Certificações")

Não existe artigo dedicado localizável para "Restrição por Dashboard"; o
controle real fica na tela **Comercial > Avançado > Certificações >
Central de Certificações** do Sankhya Om (achado via busca).

---

## Controles > Valor

- Barra de formatação HTML (negrito/sublinhado/itálico/quebra de
  linha/alinhamento/fonte/tamanho/cor de fonte/cor de realce), aplicável a
  Título e Texto.
- Parâmetros/variáveis arrastáveis para dentro do campo, ou digitados
  diretamente (`:ID_PARAM`).
- Link customizado:
  ```html
  <a href="http://www.google.com" target="_blank">Nome do link</a>
  ```
  (sempre `target="_blank"`).

## Controles > Tabela — recursos avançados

- **Ações vinculadas a Entidade**: campo "Entidade" define a tabela; ações
  cadastradas no Dicionário de Dados (aba Ações) viram um botão de ações no
  componente renderizado. Ver `06-acoes-customizadas.md`.
- Seleção múltipla de linhas (`Ctrl`+clique).
- **"Utilizar a nova versão da grade"**: nova UI de configuração/menu
  (ordenação/filtro/busca avançados).
- **Campo Farol** — expressão SQL retorna cor de indicador:
  ```sql
  SELECT
    CASE WHEN F.VLRDESDOB < 100 THEN '#86C154' ELSE '#C3C3C3' END AS FAROL,
    F.NUFIN, F.VLRDESDOB
  FROM TGFFIN F
  ```
  Marcar o campo como tipo "Farol(G)" (grande) ou "Farol(P)" (pequeno).
- Filtro/ordenação por coluna via ícone no header (crescente/decrescente/
  remover/filtrar).
- `Ctrl+C` copia célula/linha.
- `TSIPAR` **`LIMITLINHASDASH`** — limite máx. de linhas em Tabela/Tabela
  Dinâmica. Exportação ignora o limite (exporta tudo), mas o ícone de
  exportação só aparece se `LIMITLINHASDASH > 0`.

### Coloração de linha inteira (BKCOLOR / FGCOLOR)

Colunas especiais retornadas pela query controlam cor de fundo/texto da
**linha inteira** (não célula):
```sql
SELECT
  F.NUFIN, F.VLRDESDOB, F.DHBAIXA, F.CODPARC,
  CASE WHEN F.VLRDESDOB < 100 THEN '#FF0000' ELSE '' END AS FGCOLOR,
  CASE WHEN F.VLRDESDOB < 100 THEN '#FFFF00' ELSE '' END AS BKCOLOR
FROM TGFFIN F
```
No `<metadata>`, declarar os campos `BKCOLOR`/`FGCOLOR` com `visible="false"`
— o grid reconhece esses nomes automaticamente. Ver exemplo real em
`05-dash-gadget-padroes-reais.md`.

### Formatação Condicional por célula

Disponível só para **Tabela**, campos `Inteiro`, `Moeda`, `Decimal`, `Data`,
`Data e Hora`. Editor no canto direito da grade ("Expressão").

- **Tipo**: `Formatação` (regras individuais) **ou** `Escala de Cores`
  (mutuamente exclusivos).
- **Escala de Cores — Bicolor**: 2 pontos (Mínimo/Máximo), cada ponto
  `Menor valor`/`Valor`/`Percentil` e `Maior valor`/`Valor`/`Percentil`.
- **Escala de Cores — Tricolor**: 3 pontos (Mínimo/Médio/Máximo); Médio só
  `Valor` ou `Percentil`. Percentil sempre 0–100.
- **Regras de Formatação**: `Maior(>)`, `Maior igual(>=)`, `Menor(<)`,
  `Menor igual(<=)`, `Igual(=)`, `Diferente(<>)`, `Entre`, `Não entre`,
  `Vazia(NULL)`, `Não vazia(NOT NULL)`, **`Fórmula Personalizada`** (ex.:
  `'CODCR>=100'`, pode usar outros campos do mesmo componente).
- Pode associar **ícone** a cada regra + "Mostrar somente ícone".
- Múltiplas regras coexistem no mesmo campo: **a primeira verdadeira, na
  ordem da grade, prevalece** — as demais são ignoradas.

## Controles > Tabela Dinâmica (Pivot)

- Drag-and-drop de campos (linhas/colunas/valores); config só aplicada na
  1ª execução — mudanças do usuário depois são preservadas.
- **"Sempre usar visualização padrão"**: ignora alterações do usuário,
  sempre volta ao layout configurado.
- Campo usado como filtro fica destacado em **vermelho** na UI.
- Sujeito ao `LIMITLINHASDASH`.
- Restrição: descrição da consulta não pode conter `.`.
- Ver sintaxe XML real (`<pivot-table>`, `rendererName-ini="MAPA_CALOR"`) em
  `05-dash-gadget-padroes-reais.md`.

## Controles > Geomapa

- **"Configurações do mapa"**: "Endereço" define ponto central (default =
  Brasil); "Raio" (KM) desenha raio ao redor do ponto.
- **Marcadores**: `Apenas marcar` (pino vermelho) vs `Marcar com uma bolha`
  (tamanho/cor proporcional).
- Clique no marcador → link "Mais detalhes" no balão.
- **"Detalhe do marcador"**: Título (resumo, texto + variáveis + campos SQL)
  e Texto (mesmo + tags HTML).
- **Limite: apenas os primeiros 400 marcadores** são exibidos.
- Requer `Latitude`/`Longitude` preenchidos (para Parceiros, aba Endereço do
  cadastro); campos nulos são descartados pela API do Maps.

## Controles > HTML5 (componente 100% customizado)

1. Baixar modelo via **"Download Modelo Simples HTML5"** ou **"Download
   Modelo Completo HTML5"** (botão "Outras Opções...").
2. O pacote tem 2 XMLs de modelo (SqlServer / Oracle) — copiar o correto.
3. Colar no editor **XML** do componente, definir Título.
4. **"Upload do Pacote HTML"** — subir o zip completo.
5. **"Ponto de Entrada"** — nome do arquivo **JSP** a compilar (botão
   auxiliar lista `.jsp`/`.html` do pacote).
6. Link "Editando {Nome} [{Nível}]" no topo — hover mostra o **Id do
   componente**, clique copia.

Suporta parâmetros no formato padrão (`:PARAM`, listas `:P_LIST`, período
`.INI`/`.FIN`):
```sql
SELECT CAB.CODPARC, CAB.NOMEPARC
FROM TGFCAB CAB WHERE CAB.CODPARC IN
(SELECT PAR.CODPARC
 FROM TGFPAR PAR INNER JOIN TGFCTT CTT ON (PAR.CODPARC = CTT.CODPARC)
 WHERE PAR.ATIVO IN (:P_ATIVOLIST)
 AND PAR.CODPARC IN (:P_CODPARCLIST)
 AND CTT.ATIVO IN (:P_ATIVOLIST))
AND (:P_DTNEG.INI IS NULL OR CAB.DTNEG >= :P_DTNEG.INI)
AND (:P_DTNEG.FIN IS NULL OR CAB.DTNEG <= :P_DTNEG.FIN)
AND (:P_SERIENOTA IS NULL OR CAB.SERIENOTA LIKE '%' || :P_SERIENOTA || '%')
```
> **SQL Server**: trocar `||` por `+` na concatenação.

Também via "Outras Opções": **"Download Modelo JavaScript Simples HTML5"** —
executa queries **em runtime via JavaScript**, suporta parâmetros
`Data/Hora`, `Data`, `MultiList:Text`, `Período`, `Entidade/Tabela`, `Texto`,
`SingleList:Text`. Nota: `MultiList:Text` sem nenhum item selecionado
retorna **todos** os registros — marcar como obrigatório se precisar de
filtro fixo.

### Confirmado no workspace: `sk-dash/modelo/` (pacote HTML5 real)

O workspace já tem o **modelo baixado e funcional** (o mesmo que os botões
"Download Modelo..." geram): `sk-dash/modelo/model_XML_SqlServer.xml` /
`model_XML_Oracle.xml` (o XML a colar no gadget), `JSP_MODELO.jsp` (modelo
JavaScript), `model_Parceiro.jsp` + `model_Contato.jsp` (modelo Completo,
master/detail) e `css/*.css`. Ver detalhamento completo com os dois
padrões (JSTL server-side vs JavaScript client-side) em
`05-dash-gadget-padroes-reais.md` § "Componente HTML5 — pacote JSP real".
Resumo dos pontos que a doc oficial não deixa claro:
- A tag XML que hospeda o componente dentro de um `<container>` é
  `<html5component id="..." entryPoint="nome_do_arquivo.jsp"/>`.
- `<snk:load/>` é **obrigatória no `<head>`, nessa posição** (carrega o
  runtime JS do Sankhya) — sem ela, `executeQuery`/`openLevel`/etc. não
  existem.
- CSS do pacote vai numa subpasta `css/`, referenciada via
  `${BASE_FOLDER}/css/arquivo.css` (variável EL injetada pelo Sankhya).
- API JS de navegação disponível no **client-side** (dentro do JSP, não
  confundir com a API server-side de Ações do `06-acoes-customizadas.md`):
  `executeQuery(query, parametros, onSuccess, onError)`,
  `openApp(resourceID, params)`, `openLevel(nivel, params)`,
  `refreshDetails(componentID, params)`, `openPage(page, params)`.

## Controles > IReport (relatório JasperReports embutido)

- Requer relatório já criado em **Relatórios Formatados** (JRXML).
- **"Importar Parâmetros do Relatório"**: traz os parâmetros do JRXML para
  o gadget (não reimporta parâmetro já existente com mesmo nome).
- **"Ignorar paginação"**: paginação contínua em vez de quebra de página.
- Cuidados de parâmetro:
  - `Multi List` do dashboard → parâmetro do relatório deve ser tipo
    **String**.
  - `Período` → exige **dois parâmetros** `Data`/`Timestamp` no relatório,
    mesmo nome base, sufixo `.ini`/`.fin` (ex.: dashboard `ENTRADA` →
    relatório `ENTRADA.INI` + `ENTRADA.FIN`).
- Eventos de clique configurados no **editor Jasper**, não no Sankhya — ver
  funções JS na seção "Eventos" abaixo.

---

## Gráficos cartesianos (Linha, Barras, Colunas, Área, Intervalo de Área)

- **Aba Eixos**: Tipo = `Categoria` (agrupamento) ou `Valor` (contínuo). Em
  Barras: horizontal fixo `Valor`, vertical fixo `Categoria`. Em
  Colunas/Área/Intervalo: o oposto.
- **Rotação de Títulos/Resultados**: -90° a 90°.
- **Visão Parcial**: `Primeiros Registros` (padrão) ou `Últimos Registros`.
- **Redimensionamento Vertical**: `Automático` ou `Fixo` (min/máx com 4
  casas decimais). Não se aplica se houver série com Escala Secundária.
- **"Omitir valores nulos"**.
- **"Rotacionar Resultados"** (Colunas): range visível do eixo Y via
  slider, sem alterar dados.
- **Máscara de valores nos eixos**: só para eixo `Valor`, via "Assistente
  de edição de máscara".
- **Zoom**: clique+arrasta na área do gráfico; botão "Resetar Zoom" some
  automaticamente quando aplicável.

### Aba Série

- Uma série = uma linha/barra/coluna/área. N séries por gráfico.
- Campos: `Descrição`, `Campo na Horizontal`, `Campo na Vertical`, `Cor`
  (checkbox "Usar cor padrão").
- **"Destacar pontos"**: enfatiza mudança de valor; auto-liga "Mostrar
  placa de valor" (tooltip).
- **Agrupar séries**: `Ctrl`+seleção múltipla + "Agrupar séries".
- Barras/Colunas podem combinar série `Barra/Coluna` + série `Linha` no
  mesmo gráfico.
- `TSIPAR` **`SOBREVALORGRAF`**: se desligado, oculta placas de valor que
  se sobrepõem.
- **Escala Secundária** (Colunas, série Linha+Coluna): eixo vertical
  secundário para destacar uma série; campo "Sufixo da Escala".
- Ordem das séries afeta empilhamento visual.
- **Balão customizado**: campo calculado no `Descrição`, sempre prefixado
  `$` (ex. `$NOMECAMPO`).
- Engrenagem: `Mostrar/Ocultar Título`, `Mostrar/Ocultar Legenda`,
  `Imprimir Gráfico`.
- **Acumular Valores** (Linha/Barras/Colunas): soma progressiva (running
  total), só campos numéricos.

## Gráfico > Pizza
Sem abas Eixos/Série. Campos: `Valor` (percentual do setor), `Agrupamento`.
`Tamanho dos Títulos`: nº de caracteres na legenda (trunca com "...").

## Gráfico > Análise de Rentabilidade (waterfall/DRE hierárquico)
- **Apresentação**: `Produto` ou `Serviço`.
- Posição da legenda, `Apresentação dos Valores` (`Percentual`/`Valores`),
  colunas na legenda, "Abreviar legenda" (ex. "Faturamento"→"FAT").
- **Evento** por ponto da cascata: `Faturamento`, `CMV/PV`, `Gasto
  Variável`, `Gasto Fixo`, `M. Contribuição`, `Resultado`.
- Margem de Contribuição **não tem evento configurável** — é sempre
  calculada: `MC = Faturamento - CMV - Gasto Variável`.
- Duplo clique em qualquer segmento abre um construtor de expressão
  **independente** para aquela parte (pode reusar variáveis da expressão
  principal). MC sem expressão informada é calculada automaticamente.

## Gráfico > Velocímetro (Gauge)
- `Campo de Valor`, `Valor Mínimo`, `Valor Máximo`.
- `Faixa de alerta`: cores por intervalo de valor (validação automática
  alerta problemas na grade de intervalos).
- Ver sintaxe XML real (`<show-ticks>`, `<alert-colors>`) em
  `05-dash-gadget-padroes-reais.md`.

## Gráfico > Geográfico (mapa coroplético)
- `Modo de apresentação`: `Países` ou `Estados`.
- `Legenda`: faixas de cores e quantidade. Marcadores e Nomenclaturas
  próprias.

## Gráfico > Donut
Como Pizza, + `Tipo de Donut`: `Completo - 360º` ou `Semicírculo - 180º`.

## Gráfico > Bolha (Bubble)
3 dimensões: `X`, `Y`, `Z` (diâmetro). Sem `Categoria`, só `Valor`. Cada
série = uma coloração.

## Gráfico > TreeMap
- Abas: Geral, Categorias, BIA.
- `"Exibir valor no item"`.
- `Layout de Apresentação` (Categoria e Item, separado), 4 opções: `Simples
  e rápido`, `Listra`, `Proporcional alternado`, `Proporcional`.
- Aba Categorias: `Id` (deve casar com `Campo de Categoria` dos itens),
  `Descrição`, `Cor`.
- Colunas: `Campo de Nome`, `Campo de Categoria` (define quadrante),
  `Campo de Valor` (numérico, define tamanho do retângulo).

## Gráfico > Dispersão (Scatter)
`Tipo`: `Pontos e linhas` ou `Somente pontos`. Série: `Descrição`,
Horizontal/Vertical, `Cor`, `Placas de valor`.

## Gráfico > Radar
Eixos `Valor`/`Categoria` com Máscara. `"Omitir valores nulos"` e `"Omitir
títulos"`. Rotação de título -90°/90°. Série `Linha` **ou `Área`**
(preenchimento).

## Gráfico > Funil
`Campo Valor` (por etapa), `Campo Etapa` (rótulo). `Exibição dos Títulos`:
`Valor` (absoluto) ou `% da etapa anterior` (funil de conversão).

## Gráfico > Intervalo de Área (Area Range)
Série `Intervalo de Área` ou `Linha`. `Campo Mín.`/`Campo Máx.` definem a
banda preenchida (ex.: mín/máx de preço por período).

---

## Parâmetros — tipos e sintaxe avançada

Tipos disponíveis no Design: `Entidade/Tabela`, `Período`, `Data`, `Texto`,
`Data/Hora`, `Número Inteiro`, `Número Decimal`, `Verdadeiro/Falso`, `Single
List`, `Multi List`.

Campos comuns: `Id`, `Descrição`, `Requerido`, `Salvar último valor`,
`Mostrar inativas`. Por tipo:
- `Texto`/`Número Inteiro`/`Número Decimal`: `Limite de caracteres`.
- `Data`/`Data/Hora`/`Período`: `Considerar data atual?`. **Restrição**:
  `Data` não pode ter "Salvar último valor" + "Considerar data atual?"
  simultâneos; `Período` pode ter ambos, mas "data atual" só se aplica ao
  fim do período.
- `Número Inteiro`/`Número Decimal`: `Range`.
- `Single List`/`Multi List`: `Tipo de dado` = `Texto`, `SQL` ou
  `Entidade/Campo`.
- `Entidade/Tabela`: campo de busca com lupa no filtro do dashboard.
- Gadget pode ter **atualização automática** por tempo configurável.

### Sintaxe de referência de parâmetro: `:`, `:#`, `:@`

| Sintaxe | Comportamento |
|---|---|
| `:ID_PARAMETRO` | Clássica — o tradutor envolve em `(...)`, adiciona aspas simples se for texto |
| `:#PARAMETRO` | **Recomendada por performance** — auto-preenche aspas conforme o tipo, substituição direta |
| `:@PARAMETRO` | Trata NULOS e DATAS corretamente; strings exigem aspas manuais `':@PARAMETRO'`; também melhora performance |

Exemplo `:` clássico:
```sql
SELECT * FROM TCSOSE WHERE CODPARC IN :P_PARCEIRO AND DHCHAMADA >= '01/01/2021' ORDER BY NUMOS
-- com P_PARCEIRO=2135 vira:
-- ... WHERE CODPARC IN (2135) AND DHCHAMADA >= '01/01/2021' ...
```
Exemplo `:#`:
```sql
SELECT * FROM TSICID WHERE DTALTER > :#DTALTER
```
Exemplo `:@`:
```sql
WHERE NOMECID = ':@DTALTER'
```

### Parâmetros internos do sistema (globais, sempre disponíveis, tipo Número Inteiro)
- `CODUSU_LOG` — usuário logado (também aparece como `:CODUSU_LOG` sem
  precisar declarar em `prompt-parameters` — visto em uso real em
  `analise.vendas.xml`, ver `05-dash-gadget-padroes-reais.md`)
- `CODGRU_LOG` — grupo do usuário logado
- `CODPARC_B2B` — parceiro B2B
- `CODVEN_LOG` — vendedor logado

### Delimitador `/*inCollection*/` — limite de 1000 valores em Multi List/SQL

Quando um parâmetro Multi List (Tipo de dado `SQL`) retorna **mais de 1000
valores**, é **obrigatório** envolver a cláusula:
```sql
-- Antes:
SELECT CODPARC, NOMEPARC, TIPPESSOA, CODCID FROM TGFPAR WHERE CODCID in :P_CODCID
-- Depois (obrigatório se > 1000 valores):
SELECT CODPARC, NOMEPARC, TIPPESSOA, CODCID FROM TGFPAR WHERE /*inCollection*/
CODCID in :P_CODCID/*inCollection*/
```

**Limite prático observado bem abaixo de 1000** (confirmado em
`sk-dash/desempenho vendas marca/desempenho_vendas_marca.xml`, 2026-08-20):
selecionando "todas as opções" de um `multiList:Text` com apenas **241**
valores (`P_MARCA`, código inteiro `TGFMAR.CODIGO`), a execução falhou com
`A identificador iniciado com 'PARAM('2', '139', '133', ...' é muito
extensa. O comprimento máximo é 128` — erro clássico de identificador do SQL
Server (limite de 128 caracteres para `sysname`), indicando que sem o
marcador o Sankhya tenta nomear algum bind/identificador interno a partir da
própria lista de valores substituída, e isso já estoura com poucas dezenas
de itens. **Não confiar no limiar de "1000 valores" da documentação oficial
— aplicar `/*inCollection*/` em todo `IN :PARAM` de multiList por padrão**,
mesmo em listas pequenas (o marcador não tem custo perceptível quando a
lista é pequena). Aplica-se também a `IN` dentro de subquery (não só direto
no `WHERE` principal) — colocar `/*inCollection*/` logo antes da coluna e
logo depois do parâmetro, onde quer que o `IN :PARAM` apareça.

## Aba Configurações (≠ Parâmetros)

Mesmos campos de Parâmetros, mas com **"Valor Padrão"** fixo — uma vez
salvo, aplicado automaticamente sempre, sem o usuário reinformar. Não é
filtro do usuário, é config fixa do componente.

## Aba Variáveis — SQL vs Java BeanShell

### Variável tipo SQL
- **Assistente**: montagem visual (Tabela → tabelas relacionadas →
  Campos → Filtros). Filtro pode ser **associado por nome** a um parâmetro
  já existente no gadget — permite compartilhar um único parâmetro (ex.
  `CODUSU`) entre múltiplos gadgets do mesmo dashboard (renderizado uma
  vez, reaproveitado por todos).
- **Avançado**: SQL direto sem assistência. **Atenção**: uma vez usado,
  desativa o assistente permanentemente para aquela query.
- **Resultado**: testa a query antes de usar; **limitado a 20 linhas**.

### Variável tipo Java BeanShell
Código Java simplificado direto, sem assistente. Casos de uso: metadata
dinâmica de colunas, transformação de dados. API interna:
`uiElement()`, `var("NOME_VAR")`, manipulação de `org.jdom.Element` para
metadata, retorno de `Collection`/`Object[]` como linhas de dados —
alternativa programática ao `expression type="sql"`.

```java
void addColumn(String name, String type, String description){
  ui = uiElement();
  meta = ui.getChild("metadata");
  if( meta == null){
    meta = new org.jdom.Element("metadata");
    ui.addContent( meta );
  }
  f = new org.jdom.Element("field");
  f.setAttribute("name",name);
  f.setAttribute("label",description);
  f.setAttribute("type",type);
  f.setAttribute("visible","true");
  f.setAttribute("useFooter","false");
  meta.addContent(f);
}
void initMetadata(){
  addColumn("CODPROJ","I","Cód.Projeto");
  addColumn("NOMEPROJ","S","Nome Prj");
  // tipos: I=Inteiro, S=String, T=DataHora
}
initMetadata();
return var("_vprojects");
```

```java
import java.math.BigDecimal;
int qtdSaidas = ((BigDecimal) var("QTD_SAIDAS")).intValue();
Collection linhas = new ArrayList();
linhas.add(new Object[]{ "Qtde. Saídas", qtdSaidas, qtdSaidas });
return linhas;
```

## Argumentos (passagem de parâmetros entre níveis)

- `Id` + `Tipo`, mas ao contrário de Parâmetros/Configurações/Variáveis
  (por gadget), **Argumentos são por nível** — cada nível de drill-down tem
  os seus.
- Uso típico: nível 1 "Vendas por Vendedor" → duplo clique abre nível 2
  passando código do vendedor como Argumento.
- **Integração com Portal de Importação de XML**: um Argumento (ex.
  `NUARQUIVO`) pode direcionar, ao clicar numa linha, para o registro
  correspondente naquela tela.

## Eventos — Gráficos, Tabela, Valor

Em gráficos, eventos são **por Série** (botão "Evento" em cada série). Duas
opções:

1. **"Abrir um novo nível"**: escolhe nível já criado; se tiver
   Argumentos, associa variável/campo pela coluna "Valor". Níveis mais
   profundos **herdam automaticamente** as variáveis passadas como
   argumento pelos níveis anteriores.
2. **"Lançar uma tela do sistema"**: abre tela ou Dashboard do Sankhya Om
   via duplo clique. A **PK** da tabela principal da tela alvo vira
   "Argumento", associável a variável local. Restrição: a tela só abre se o
   usuário logado tiver permissão de visualização. Ver sintaxe XML real
   (`on-click-launcher`) em `05-dash-gadget-padroes-reais.md`.

### Aba "Atualizar detalhes" (drill-across)

Componente corrente força atualização de **outro(s) controle(s)** no mesmo
nível, passando valores do componente mestre como argumentos utilizáveis na
query/expressão do(s) detalhe(s). Exemplo do doc: Pizza (mestre, por
segmento) + Tabela de Parceiros (detalhe); clicar numa fatia refiltra a
tabela pelo segmento. Tabela: evento único, pela linha clicada. Valor:
evento é renderizado como **link**.

### Funções JavaScript de evento (hyperlink, iReport e navegação de gadget)
Sempre prefixadas por `javascript:`:
- `refreshDetails(id_do_gadget, parâmetros)`
- `openLevel(id_do_nivel, parâmetros)`
- `openApp(id_da_tela, parâmetros)`
- `openPage(url_da_página, parâmetros)`

## Quadrante Expressão — assistentes

- **Editar Campos Calculados**: combina campos (ex. concatenar cidade +
  estado).
- **Editar Máscara**: formatação de valores em eixos `Valor`.
- **Formatação condicional**: ver acima.
- **Assistente de Formatação e Agregação** (coluna "Agregador", substitui
  "Totalizar"), para `Inteiro`/`Decimal`/`Moeda`, resultado no rodapé:
  `Maior`, `Menor`, `Média`, `Somar`, **`Personalizada`**.
  - Personalizada — expressão livre com funções de agregação:
    ```sql
    SUM(VALOR_VENDA) / SUM(VALOR_CUSTO)
    ```
    Só aceita variáveis da "Seleção de Variáveis"; sem cálculos fora da
    Fórmula Personalizada.
  - Também aplicável a campos **Hora** (somar, média, mín, máx,
    personalizado).
- CDATA necessário para HTML em expressões:
  ```xml
  <title><![CDATA[Mês negociado<br><br>Junho</br></br>]]></title>
  ```
- No painel de filtros do dashboard, `Enter` aplica o filtro.

## Pré-visualização
Botão "Pré-visualizar" abre o gadget como num Dashboard real (Design e
XML). "Editar" retorna à edição (se permissão). **No mobile, gráficos são
exibidos maximizados automaticamente.**

## Impressão / Exportação
- Gráficos: engrenagem → "Imprimir Gráfico".
- Tabela: exportar como **PDF**, **Excel**, ou **"Visualizar em Cubo"**
  (OLAP-like).
- Botão de estatísticas sobre campos numéricos da grade.

## Ações nos Componentes de BI

Fluxo para lançar ações (não só navegação) a partir de um componente
Tabela — ver detalhamento completo em `06-acoes-customizadas.md`:
1. Componente Tabela com Entidade + query definidos.
2. `Configurações > Avançado > Dicionário de Dados` → localizar entidade →
   aba **Ações** → cadastrar `Rotina no Banco de Dados`, `Script
   (JavaScript)`, `Lançador` ou `Rotina Java`.
3. Ao visualizar o componente, aparece um botão com as ações configuradas.
- `TSIPAR` **`ORDENARACOES`**: ordena ações alfabeticamente no botão.
- **Restrição**: campos usáveis num botão de ação são só os da entidade
  relacionada ao componente.

## Botão "Outras Opções"
- **"Dashboards que usam esse componente"**: lista dependências;
  duplo clique abre o dashboard correspondente já posicionado.
- **"Download Modelo JavaScript Simples HTML5"** — ver seção HTML5.
