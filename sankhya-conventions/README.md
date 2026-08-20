# Base de conhecimento Sankhya — DPS

Esta pasta é o repositório permanente e crescente de definições, convenções e
referências técnicas sobre o Sankhya usadas neste workspace. Objetivo: ter em
um único lugar tudo que já aprendemos sobre o sistema (dicionário de dados,
construção de dashboards/Gadget, customizações Java/JS, relatórios JRXML),
para que qualquer projeto novo — em especial dashboards complexos — comece
com o máximo de contexto já disponível, sem precisar redescobrir nada.

> **Regra de manutenção:** sempre que se aprender algo novo e não óbvio sobre
> o Sankhya (um comportamento de campo, uma armadilha de sintaxe, um recurso
> descoberto num dashboard real, um parâmetro de sistema), registrar aqui —
> não deixar o conhecimento só na conversa. Preferir atualizar o arquivo do
> tópico certo a criar um novo arquivo solto.

## Relação com `.github/copilot-instructions.md`

O arquivo [`.github/copilot-instructions.md`](../../.github/copilot-instructions.md)
continua sendo o **rulebook autoritativo**, carregado automaticamente pelo
Copilot/Claude em toda conversa deste workspace — regras obrigatórias de
geração de SQL, dicionário de tabelas ERP/WMS e padrões de código não devem
ser duplicadas com risco de divergência. Esta pasta:

- **Espelha** os trechos essenciais do rulebook (dicionário de dados, padrões
  SQL) para consulta isolada por tópico, já que esses assuntos raramente
  mudam sozinhos.
- **Expande** com tudo que o rulebook não cobre em profundidade — sobretudo
  a construção avançada de dashboards (Gadget/BI), que é o motivo desta
  pasta ter sido criada: um projeto novo de dashboard mais complexo do que
  qualquer um já existente em `sk-dash/` vai precisar de recursos do Sankhya
  ainda não documentados em lugar nenhum do workspace.
- Se um dia este espelho divergir do rulebook, **o rulebook vence** — e este
  README deve ser atualizado para refletir a mudança.

## Índice

| Arquivo | Conteúdo |
|---|---|
| [01-dicionario-dados.md](01-dicionario-dados.md) | Dicionário de tabelas ERP (TGF*) e WMS/MGEWMS (TGW*), correlações e regras de estoque duplo |
| [02-sql-padroes.md](02-sql-padroes.md) | Padrões SQL obrigatórios (filtros, custo, rentabilidade, parâmetros `:@`) e regras de negócio DPS |
| [03-dash-gadget-basico.md](03-dash-gadget-basico.md) | Estrutura mínima de um Gadget XML (`level`, `container`, `grid`, `parameter`, `on-click`) |
| [04-dash-gadget-componentes-avancados.md](04-dash-gadget-componentes-avancados.md) | Catálogo oficial de componentes de BI: gráficos, geomapa, HTML5, pivot table, relatório embutido, licenciamento, BeanShell, sintaxe avançada de parâmetro |
| [05-dash-gadget-padroes-reais.md](05-dash-gadget-padroes-reais.md) | Padrões extraídos dos dashboards mais complexos já construídos no workspace (navegação hub-and-spoke, `local-vars`, `formatter`, cor de linha, `on-click-launcher`, `metadata.xml`, actions.js) |
| [06-acoes-customizadas.md](06-acoes-customizadas.md) | As 4 modalidades de Ação vinculável a um componente/tela: Rotina no Banco de Dados, Script (JavaScript server-side), Rotina Java, Lançador |
| [07-relatorios-jrxml.md](07-relatorios-jrxml.md) | Convenções de relatórios iReport/JRXML e o procedimento de decompilar classes vendor compiladas |
| [08-referencias-externas.md](08-referencias-externas.md) | Onde buscar mais: portal developer.sankhya.com.br, docs locais já salvas, e o que falta baixar |
| [09-api-consulta-dps.md](09-api-consulta-dps.md) | `dps-consulta`: API sob demanda (não always-on) pra validar SELECTs de dash/relatório contra o Sankhya, já que não há mais acesso direto ao banco |

## Estrutura das pastas Sankhya do workspace (contexto)

| Pasta | Conteúdo |
|---|---|
| `sk-dash/` | Dashboards Sankhya em XML (Gadgets) — os exemplos reais minerados nesta base |
| `sk-docs/sk-ia/` | Documentação oficial Sankhya salva localmente (iReport + Construtor de BI) |
| `sk-docs/romaneio/` | Documentação de um fluxo de negócio específico (romaneio de separação) |
| `sk-custom/` | Customizações Java (rotinas, regras de negócio) |
| `sk-ext/` | Extensões do Sankhya (módulos externos) |
| `sk-report/` | Relatórios do projeto no padrão iReport (JRXML) |
| `sk-mge/` | Núcleo Sankhya (jars decompilados/referência) |
| `sk-bd/` | Scripts de banco avulsos (feriados, WMS) |
| `dps-recepcao/` | Sistema operacional (Node.js) — totem/painel/entrega, integração 100% via API Sankhya, sempre no ar |
| `dps-consulta/` | API sob demanda (não always-on) pra validar SELECTs de dash/relatório contra o Sankhya — ver [09-api-consulta-dps.md](09-api-consulta-dps.md) |
