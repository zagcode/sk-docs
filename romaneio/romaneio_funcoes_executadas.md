# Funcoes e Endpoints Executados no Fluxo de Romaneio

## 1) Tela e funcoes JavaScript

Arquivo: `website/js/romaneio_monta_relatorio.js`

- `carregar_separador(reimpressao, page)`
  - `reimpressao = false` -> chama `fetch_romaneio.php`
  - `reimpressao = true` -> chama `fetch_romaneio_reimpressao_paginado.php`
- `imprimir_romaneio(reimpressao)`
  - chama `montaRelatorio(selecionados, reimpressao)`
  - depois chama `printJS(...)`
- `montaRelatorio(selecionados, reimpressao)`
  - cabecalho:
    - normal -> `fetch_romaneio_cabecalho.php`
    - reimpressao -> `fetch_romaneio_cabecalho_reimpressao.php`
  - corpo:
    - normal e reimpressao -> `fetch_romaneio_corpo.php` (no codigo atual)

Arquivo: `website/js/romaneio.js`

- `confirmaImpressao()` -> chama `fetch_romaneio_tarefa_impressa.php`
- `cancelaImpressao()` -> chama `fetch_romaneio_tarefa_naoimpressa.php`
- `confirmaTodasImpressoes()` -> chama `fetch_romaneio_tarefa_impressa.php`

## 2) Arquivos PHP de ponte (website -> Node API)

- `website/fetch_romaneio.php`
  - chama `/login_romaneio/:usuario/:senha`
  - chama `/romaneio_separacao_fecha/:separador/:cod_empresa`
  - chama `/romaneio/:separador`
- `website/fetch_romaneio_reimpressao_paginado.php`
  - chama `/login_romaneio/:usuario/:senha`
  - chama `/romaneio_reimpressao_paginado/:separador`
- `website/fetch_romaneio_cabecalho.php`
  - chama `POST /romaneio_separacao_cabecalho`
- `website/fetch_romaneio_cabecalho_reimpressao.php`
  - chama `POST /romaneio_separacao_cabecalho_reimpressao`
- `website/fetch_romaneio_corpo.php`
  - chama `POST /romaneio_separacao_corpo`
- `website/fetch_romaneio_corpo_reimpressao.php`
  - chama `POST /romaneio_separacao_corpo_reimpressao` (existe, mas o JS atual usa o corpo normal)
- `website/fetch_romaneio_tarefa_impressa.php`
  - chama `POST /romaneio_confirma_impressao_tarefa`
- `website/fetch_romaneio_tarefa_naoimpressa.php`
  - chama `POST /romaneio_confirma_naoimpressao_tarefa`

## 3) Endpoints Node e SQL executado

Arquivo: `api/src/index.js`

- `GET /login_romaneio/:usuario/:senha`
  - executa `SELECT` em `TSIUSU`
- `GET /romaneio/:separador`
  - executa `CTE pedidos` para lista de impressao
- `GET /romaneio_reimpressao_paginado/:separador`
  - executa `CTE Dados` com filtros e paginacao
- `GET /romaneio_separacao_fecha/:separador/:cod_empresa`
  - `EXEC DPS_ROMANEIO_SEPARACAO_FINALIZACAO`
- `POST /romaneio_separacao_cabecalho`
  - `EXEC DPS_ROMANEIO_SEPARACAO_RETORNA_CABECALHO`
- `POST /romaneio_separacao_cabecalho_reimpressao`
  - `EXEC DPS_ROMANEIO_SEPARACAO_RETORNA_CABECALHO_SEGUNDA_VIA2`
- `POST /romaneio_separacao_corpo`
  - `EXEC DPS_ROMANEIO_SEPARACAO_RETORNA_ITENS`
- `POST /romaneio_separacao_corpo_reimpressao`
  - `EXEC DPS_ROMANEIO_SEPARACAO_RETORNA_ITENS`
- `POST /romaneio_confirma_impressao_tarefa`
  - `EXEC DPS_ROMANEIO_SEPARACAO_TAREFA_IMPRESSA`
- `POST /romaneio_confirma_naoimpressao_tarefa`
  - `EXEC DPS_ROMANEIO_SEPARACAO_TAREFA_NAOIMPRESSA`

## 4) Procedures principais envolvidas

Arquivo: `sql/`

- `DPS_ROMANEIO_SEPARACAO_RETORNA_CABECALHO.sql`
- `DPS_ROMANEIO_SEPARACAO_RETORNA_ITENS.sql`
- `DPS_ROMANEIO_SEPARACAO_RETORNA_CABECALHO_SEGUNDA_VIA2.sql`
- `DPS_ROMANEIO_SEPARACAO_TAREFA_IMPRESSA.sql`
- `DPS_ROMANEIO_SEPARACAO_TAREFA_NAOIMPRESSA.sql`
- `DPS_ROMANEIO_SEPARACAO_FINALIZACAO.sql` (chamada pelo endpoint de fechamento)

## 5) Observacao sobre PDF

- O projeto nao gera PDF no backend.
- O documento e montado em HTML e enviado para `printJS`; a saida PDF depende da opcao de impressao do navegador.
