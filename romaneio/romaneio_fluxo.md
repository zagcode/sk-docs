# Fluxo do Romaneio (Impressao e Reimpressao)

## Diagrama (Mermaid)

```mermaid
flowchart TD
    A[romaneio.php / romaneio_reimpressao.php] --> B[js/romaneio_monta_relatorio.js]

    B --> C1[carregar_separador(false)]
    C1 --> D1[fetch_romaneio.php]
    D1 --> E1[GET /login_romaneio/:usuario/:senha]
    E1 --> F1[SQL Login em TSIUSU]
    D1 --> E2[GET /romaneio_separacao_fecha/:separador/:cod_empresa]
    E2 --> F2[EXEC DPS_ROMANEIO_SEPARACAO_FINALIZACAO]
    D1 --> E3[GET /romaneio/:separador]
    E3 --> F3[CTE pedidos - TGWSEP/TGWITT/TGFPAR/TSICID]

    B --> C2[imprimir_romaneio(false)]
    C2 --> G1[montaRelatorio(selecionados)]
    G1 --> H1[fetch_romaneio_cabecalho.php]
    H1 --> I1[POST /romaneio_separacao_cabecalho]
    I1 --> J1[EXEC DPS_ROMANEIO_SEPARACAO_RETORNA_CABECALHO]
    G1 --> H2[fetch_romaneio_corpo.php]
    H2 --> I2[POST /romaneio_separacao_corpo]
    I2 --> J2[EXEC DPS_ROMANEIO_SEPARACAO_RETORNA_ITENS]
    C2 --> K1[printJS(printable: impressao_dentro)]
    K1 --> L1[Dialogo do navegador -> Salvar como PDF/Imprimir]

    B --> C3[confirmaImpressao / cancelaImpressao]
    C3 --> M1[fetch_romaneio_tarefa_impressa.php]
    M1 --> N1[POST /romaneio_confirma_impressao_tarefa]
    N1 --> O1[EXEC DPS_ROMANEIO_SEPARACAO_TAREFA_IMPRESSA]
    C3 --> M2[fetch_romaneio_tarefa_naoimpressa.php]
    M2 --> N2[POST /romaneio_confirma_naoimpressao_tarefa]
    N2 --> O2[EXEC DPS_ROMANEIO_SEPARACAO_TAREFA_NAOIMPRESSA]

    B --> C4[carregar_separador(true)]
    C4 --> D2[fetch_romaneio_reimpressao_paginado.php]
    D2 --> E4[GET /romaneio_reimpressao_paginado/:separador]
    E4 --> F4[CTE Dados + paginacao OFFSET/FETCH]

    B --> C5[imprimir_romaneio(true)]
    C5 --> G2[montaRelatorio(selecionados, true)]
    G2 --> H3[fetch_romaneio_cabecalho_reimpressao.php]
    H3 --> I3[POST /romaneio_separacao_cabecalho_reimpressao]
    I3 --> J3[EXEC DPS_ROMANEIO_SEPARACAO_RETORNA_CABECALHO_SEGUNDA_VIA2]
    G2 --> H4[fetch_romaneio_corpo.php]
    H4 --> I4[POST /romaneio_separacao_corpo]
    I4 --> J4[EXEC DPS_ROMANEIO_SEPARACAO_RETORNA_ITENS]
```

## Observacao

- Nao ha geracao de PDF server-side no fluxo atual.
- O documento final e gerado como HTML e enviado ao `printJS`; o PDF sai pelo dialogo de impressao do navegador.
