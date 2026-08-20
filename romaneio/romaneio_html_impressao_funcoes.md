# Montagem HTML da Impressao do Romaneio (para migracao iReport)

## Funcoes que geram o HTML impresso

Arquivo: `website/js/romaneio_monta_relatorio.js`

1. `imprimir_romaneio(reimpressao = false)`
- Entrada: pedidos selecionados na grade (`idCheck_<nunota>`)
- Acao: chama `montaRelatorio(selecionados, reimpressao)`
- Saida: dispara `printJS({ printable: 'impressao_dentro', type: 'html' })`
- Referencia: `website/js/romaneio_monta_relatorio.js:60`

2. `montaRelatorio(selecionados, reimpressao)`
- Entrada: lista de IDs selecionados
- Acao:
  - busca cabecalho (`fetch_romaneio_cabecalho.php` ou `fetch_romaneio_cabecalho_reimpressao.php`)
  - limpa e monta paginas dentro de `#impressao_dentro`
  - chama `preencherCabecalho(...)` para o bloco superior
  - busca itens (`fetch_romaneio_corpo.php`)
  - monta tabela de itens e rodape (incluindo codigo de barras da cestinha)
- Referencia: `website/js/romaneio_monta_relatorio.js:363`

3. `preencherCabecalho(cabecalhoItem, paginaAtual, totalPaginas)`
- Entrada: objeto retornado pela query de cabecalho
- Acao: gera HTML do cabecalho completo (romaneio, filial, pedido, parceiro, endereco, frete, condicao de venda, etc.)
- Saida: retorna `<div class="cabecalho-romaneio">...</div>`
- Referencia: `website/js/romaneio_monta_relatorio.js:684`

4. `abrirHtmlEmNovaAba()`
- Utilitaria para abrir o HTML montado de `#impressao_dentro` em outra aba
- Referencia: `website/js/romaneio_monta_relatorio.js:788`

## Endpoints chamados especificamente para montar o HTML

1. Cabecalho (normal)
- JS -> `fetch_romaneio_cabecalho.php`
- PHP -> `POST /romaneio_separacao_cabecalho`
- Node -> `exec DPS_ROMANEIO_SEPARACAO_RETORNA_CABECALHO '<ids>','<separador>'`

2. Cabecalho (reimpressao)
- JS -> `fetch_romaneio_cabecalho_reimpressao.php`
- PHP -> `POST /romaneio_separacao_cabecalho_reimpressao`
- Node -> `exec DPS_ROMANEIO_SEPARACAO_RETORNA_CABECALHO_SEGUNDA_VIA2 '<ids>','<separador>'`

3. Corpo/itens (normal e reimpressao no codigo atual)
- JS -> `fetch_romaneio_corpo.php`
- PHP -> `POST /romaneio_separacao_corpo`
- Node -> `exec DPS_ROMANEIO_SEPARACAO_RETORNA_ITENS '<codfilial>','<ids>','<separador>'`

## Mapeamento de campos HTML para origem de dados

Cabecalho HTML (`preencherCabecalho`):
- `numero_romaneio` <- procedure de cabecalho
- `saida_transp` <- procedure de cabecalho
- `nome_filial` <- procedure de cabecalho
- `data_hora` <- procedure de cabecalho
- `serie_pedido`, `numero_pedido` <- procedure de cabecalho
- `box` <- procedure de cabecalho
- `data_hora_liberacao2` <- procedure de cabecalho
- `nome_digitador` <- procedure de cabecalho
- `numero_separador`, `nome_separador` <- procedure de cabecalho
- `cliente_numero`, `razao_cliente`, `nome_cliente` <- procedure de cabecalho
- `end_cliente`, `cidade_cliente`, `estado_cliente` <- procedure de cabecalho
- `codigo_transportador`, `nome_transportador` <- procedure de cabecalho
- `cod_representante`, `nome_representante` <- procedure de cabecalho
- `tipo_frete`, `valor_frete` <- procedure de cabecalho
- `descicao_condicao_venda` <- procedure de cabecalho
- `inclusao` <- procedure de cabecalho
- Codigo de barras principal usa `NUTAREFA`

Itens HTML (`montaRelatorio`):
- `quant` <- procedure de itens
- `referencia` <- procedure de itens
- `Localizador` <- procedure de itens
- `unidade` <- procedure de itens
- `marca` <- procedure de itens
- `descricao` <- procedure de itens
- `subestoque` <- procedure de itens
- `cestinha` <- procedure de itens (usado no barcode do rodape)
- `ObsPedido` <- usado no JS como observacao de rodape; validar no retorno real da procedure/endpoint

## Observacao importante para iReport

- A estrutura atual e mestre-detalhe:
  - Mestre: cabecalho por pedido/tarefa
  - Detalhe: itens por `NUTAREFA`
- Para iReport, o ideal e usar:
  - Dataset 1: cabecalho (`DPS_ROMANEIO_SEPARACAO_RETORNA_CABECALHO` ou segunda via)
  - Dataset 2: itens (`DPS_ROMANEIO_SEPARACAO_RETORNA_ITENS`)
  - Relacionar pelo campo `NUTAREFA`.
