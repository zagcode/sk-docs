# Referências externas — onde buscar mais

## Já salvo localmente (fonte primária desta base)

- `sk-docs/sk-ia/Construtor de Componentes de BI – Sankhya Gestão de
  Negócios.html` — doc oficial completa do Construtor de BI/Dashboard,
  já minerada em `04-dash-gadget-componentes-avancados.md`.
- `sk-docs/sk-ia/llms.txt` — índice completo da documentação do portal
  [developer.sankhya.com.br](https://developer.sankhya.com.br). Qualquer
  página do portal pode ser obtida em Markdown anexando `.md` à URL.
- `sk-docs/sk-ia/dashboards-embarcados.md` — **baixado em 2026-08-20**:
  guia de embarcar um dashboard exportado dentro de um Add-on (Add-on
  Studio ≥ 2.0), já minerado em `04-dash-gadget-componentes-avancados.md`
  § "Dashboards embarcados em Add-on".
- `sk-docs/sk-ia/specialist-dashboards.md` — **baixado em 2026-08-20**:
  descrição da trilha de certificação Specialist Dashboards (conteúdo
  programático, não referência técnica de sintaxe).
- `sk-docs/sk-ia/bancos-de-dados-dashboards.md` — **baixado/minerado em
  2026-08-20** (usuário salvou o `.html` manualmente, `ajuda.sankhya.com.br`
  bloqueia fetch automatizado): fontes de dados externas
  (PostgreSQL/Firebird/DB2/SQL Server), setup de `mge-ds.xml`, e o achado
  chave de que `jndi-name` = valor de `data-source` no Gadget. Já minerado
  em `04-dash-gadget-componentes-avancados.md` § "Fontes de dados
  externas".
- `sk-docs/sk-ia/bia-business-intelligence-analyst.md` — **baixado/
  minerado em 2026-08-20** (mesmo processo manual): o app mobile B.I.A,
  como uma "pergunta treinada" se conecta a um Dashboard customizado via
  Central de Perguntas, e como os filtros/parâmetros do Gadget afetam o
  comportamento da BIA. Já minerado em
  `04-dash-gadget-componentes-avancados.md` § "Aba BIA".
- `sk-docs/sk-ia/*.md` (demais) — páginas de iReport e ações de entidade
  (ver `07-relatorios-jrxml.md` e `06-acoes-customizadas.md`).
- `sk-dash/modelo/` — pacote **real** de componente HTML5 (o que os
  botões "Download Modelo..." do Construtor de BI geram), já minerado em
  `05-dash-gadget-padroes-reais.md` § 14.

## Nota sobre o domínio `ajuda.sankhya.com.br`

Esse domínio (central de ajuda, Zendesk) **bloqueia fetch automatizado com
403** — só dá para obter o conteúdo salvando manualmente pelo navegador
(`Ctrl+S` → "Página web, completa", que gera o `.html` + pasta `_files` de
assets) e depois eu minero o conteúdo salvo. Já foi o processo usado para
as 3 páginas acima desse domínio. Páginas de `developer.sankhya.com.br`
(domínio diferente) não têm esse bloqueio — dá para baixar direto
anexando `.md` à URL.

## Não encontrado como artigo dedicado

- **"Restrição por Dashboard"** — não existe artigo específico localizável
  por esse nome. O controle de acesso real é feito na tela **Comercial >
  Avançado > Certificações > Central de Certificações** do Sankhya Om
  (achado via busca) — não uma doc, é a tela em si.
- **Botão de Estatísticas da grade** — nenhuma referência encontrada além
  da menção no Construtor de BI ("botão de estatísticas sobre campos
  numéricos"); comportamento exato ainda desconhecido, testar direto na
  tela quando for relevante.

## Como decidir se vale baixar mais

Antes de pedir um download, verificar primeiro se o recurso já está
coberto por um dos arquivos desta pasta (`03` a `07`) ou pelos exemplos
reais em `sk-dash/` — boa parte do que "parece faltar" já apareceu minerado
nos dashboards reais do workspace (`05-dash-gadget-padroes-reais.md`), que
é mais confiável que a doc oficial genérica por já ter passado pelo
ambiente real do projeto.

## Índice completo do portal (para descoberta rápida)

O `llms.txt` local lista dezenas de guias (Add-on Studio, Dicionário de
Dados, Dynamic Forms, Regras de Negócio, Listeners, Callbacks, `@Service`,
Jobs, SDK) e toda a API Reference (autenticação OAuth2, endpoints REST de
naturezas/vendedores/centros de resultado/etc.) — consultar o arquivo
diretamente (`sk-docs/sk-ia/llms.txt`) antes de perguntar, é mais rápido
que buscar no portal.
