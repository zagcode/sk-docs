/*
  Consultas/execucoes especificamente usadas para montar o HTML de impressao
  Origem: romaneio_monta_relatorio.js
*/

/* =====================================================
   A) CABECALHO - IMPRESSAO NORMAL
   JS: fetch_romaneio_cabecalho.php
   Node endpoint: POST /romaneio_separacao_cabecalho
   ===================================================== */
EXEC DPS_ROMANEIO_SEPARACAO_RETORNA_CABECALHO @ids, @separador;

/* Procedure alvo:
   sql/DPS_ROMANEIO_SEPARACAO_RETORNA_CABECALHO.sql

   Principais fontes internas:
   - TGWSEP   (pedido/tarefa)
   - TGFCAB   (dados comerciais)
   - TGFPAR   (cliente, transportador, filial)
   - TGFVEN   (representante)
   - TSIUSU   (digitador/separador)
   - TGFPPG   (descricao condicao venda)

   Funcoes internas:
   - dps_my_string_split(@nunota_ids, ',')
   - DPS_GERA_EAN13_NUMERO_ROMANEIO(@nr_romaneio)
*/


/* =====================================================
   B) CABECALHO - REIMPRESSAO (SEGUNDA VIA)
   JS: fetch_romaneio_cabecalho_reimpressao.php
   Node endpoint: POST /romaneio_separacao_cabecalho_reimpressao
   ===================================================== */
EXEC DPS_ROMANEIO_SEPARACAO_RETORNA_CABECALHO_SEGUNDA_VIA2 @ids, @separador;

/* Procedure alvo:
   sql/DPS_ROMANEIO_SEPARACAO_RETORNA_CABECALHO_SEGUNDA_VIA2.sql
*/


/* =====================================================
   C) CORPO / ITENS (NORMAL E REIMPRESSAO NO JS ATUAL)
   JS: fetch_romaneio_corpo.php
   Node endpoint: POST /romaneio_separacao_corpo
   ===================================================== */
EXEC DPS_ROMANEIO_SEPARACAO_RETORNA_ITENS @codfilial, @ids, @separador;

/* Procedure alvo:
   sql/DPS_ROMANEIO_SEPARACAO_RETORNA_ITENS.sql

   Principais fontes internas:
   - TGWSEP   (resolve NUNOTA por NUTAREFA)
   - TGWITT   (itens da separacao)
   - TGFPRO   (dados do produto)
   - TGWEND   (localizador origem/destino)
   - TSIUSU   (nome/cod separador)

   Funcao interna:
   - dps_my_string_split(@nunota_ids, ',')
*/


/* =====================================================
   D) LISTAGEM BASE (NAO MONTA HTML IMPRESSO, MAS ALIMENTA SELECAO)
   JS: carregar_separador(false)
   ===================================================== */
WITH pedidos AS (
    SELECT
        ROW_NUMBER() OVER (PARTITION BY S.AD_NUMPED ORDER BY S.AD_DTLIBPED DESC) AS rn,
        S.CODempoc AS cd_empresa,
        ISNULL(S.AD_NUMPED, 0) AS nr_pedido,
        CONVERT(VARCHAR(10), S.AD_DTLIBPED, 103) + ' ' + CONVERT(VARCHAR(5), S.AD_DTLIBPED, 108) AS dt_pedido,
        LTRIM(RTRIM(CONVERT(VARCHAR, S.AD_CODCLI) + '- ' + SUBSTRING(C.RAZAOSOCIAL, 1, 20))) AS Cliente,
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM TGFCAB
                WHERE CODEMP = U.CODEMP
                  AND CODPARC = S.AD_CODCLI
                  AND DTNEG = CONVERT(DATE, S.AD_DTLIBPED)
                  AND PENDENTE = 'S'
                  AND NUNOTA <> S.NUNOTA
            ) THEN 'S'
            ELSE 'N'
        END AS incl,
        LTRIM(RTRIM(CONVERT(VARCHAR, S.AD_CODTRANSP) + '- ' + SUBSTRING(C2.RAZAOSOCIAL, 1, 20))) AS cd_transportador,
        LTRIM(RTRIM(CID.DESCRICAOCORREIO)) AS cidade,
        S.NUNOTA AS nunota,
        U.CODUSU AS separador
    FROM TGWSEP S
    INNER JOIN TGWITT T ON T.NUTAREFA = S.NUTAREFA
    INNER JOIN TSIUSU U ON U.CODUSU = @separador
    LEFT JOIN TGFPAR C ON C.CODPARC = S.AD_CODCLI
    LEFT JOIN TGFPAR C2 ON C2.CODPARC = S.AD_CODTRANSP
    LEFT JOIN TSICID CID ON CID.CODCID = C.CODCID
    WHERE S.SITUACAO = 1
      AND (S.AD_CODUSUEXEC = 0 OR S.AD_CODUSUEXEC IS NULL)
      AND T.CODENDDESTINO NOT IN (17937, 20791, 42622, 47346, 77265)
      AND S.CODEMPOC = U.CODEMP
)
SELECT *
FROM pedidos
WHERE rn = 1
ORDER BY dt_pedido ASC;


/* =====================================================
   E) LOGIN (SUPORTE AO FLUXO)
   ===================================================== */
SELECT CODUSU, CODEMP, NOMEUSU, CODGRUPO
FROM TSIUSU
WHERE
    (
        (TRY_CAST(@usuario AS INT) IS NOT NULL AND CODUSU = TRY_CAST(@usuario AS INT))
        OR (TRY_CAST(@usuario AS INT) IS NULL AND RTRIM(LTRIM(NOMEUSU)) = @usuario)
    )
    AND AD_SENHA_INTRANET = @senha;
