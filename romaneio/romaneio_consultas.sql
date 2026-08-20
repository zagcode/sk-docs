/*
  Consultas SQL e EXECs usadas no fluxo de construcao do romaneio
  Origem: website -> api/src/index.js -> procedures SQL
*/

/* ==========================================================
   1) AUTENTICACAO DO SEPARADOR
   Endpoint Node: GET /login_romaneio/:usuario/:senha
   ========================================================== */

SELECT CODUSU, CODEMP, NOMEUSU, CODGRUPO
FROM TSIUSU
WHERE
    (
        (TRY_CAST(@usuario AS INT) IS NOT NULL AND CODUSU = TRY_CAST(@usuario AS INT))
        OR (TRY_CAST(@usuario AS INT) IS NULL AND RTRIM(LTRIM(NOMEUSU)) = @usuario)
    )
    AND AD_SENHA_INTRANET = @senha;


/* ==========================================================
   2) LISTAGEM DE PEDIDOS PARA IMPRESSAO
   Endpoint Node: GET /romaneio/:separador
   ========================================================== */

WITH pedidos AS (
    SELECT
        ROW_NUMBER() OVER (PARTITION BY S.AD_NUMPED ORDER BY S.AD_DTLIBPED DESC) AS rn,
        NULL AS sel,
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
        CONCAT(
            (
                SELECT COUNT(*)
                FROM TGWSEP S3
                WHERE S3.AD_CODCLI = S.AD_CODCLI
                  AND S3.NUNOTA = S.NUNOTA
                  AND S3.AD_CODUSUEXEC > 0
            ),
            '/',
            (
                SELECT COUNT(*)
                FROM TGWSEP S2
                WHERE S2.AD_CODCLI = S.AD_CODCLI
                  AND S2.NUNOTA = S.NUNOTA
            )
        ) AS pagina,
        S.NUNOTA AS nunota,
        S.AD_CODCLI AS cd_cadastro,
        U.CODUSU AS separador,
        'Normal' AS prioridade
    FROM TGWSEP S
    INNER JOIN TGWITT T ON T.NUTAREFA = S.NUTAREFA
    INNER JOIN TSIUSU U ON U.CODUSU = @separador
    LEFT JOIN TGFPAR C ON C.CODPARC = S.AD_CODCLI
    LEFT JOIN TGFPAR C2 ON C2.CODPARC = S.AD_CODTRANSP
    LEFT JOIN TSICID CID ON CID.CODCID = C.CODCID
    WHERE
        S.SITUACAO = 1
        AND (S.AD_CODUSUEXEC = 0 OR S.AD_CODUSUEXEC IS NULL)
        AND T.CODENDDESTINO NOT IN (17937, 20791, 42622, 47346, 77265)
        AND S.CODEMPOC = U.CODEMP
)
SELECT *
FROM pedidos
WHERE rn = 1
ORDER BY dt_pedido ASC;


/* ==========================================================
   3) FECHAMENTO DE SEPARACOES ABERTAS (antes de listar)
   Endpoint Node: GET /romaneio_separacao_fecha/:separador/:cod_empresa
   ========================================================== */

EXEC DPS_ROMANEIO_SEPARACAO_FINALIZACAO @cod_empresa, @separador;


/* ==========================================================
   4) CABECALHO DO ROMANEIO (impressao normal)
   Endpoint Node: POST /romaneio_separacao_cabecalho
   ========================================================== */

EXEC DPS_ROMANEIO_SEPARACAO_RETORNA_CABECALHO @ids, @separador;

/* Procedure:
   - Arquivo: sql/DPS_ROMANEIO_SEPARACAO_RETORNA_CABECALHO.sql
   - Principais fontes: TGWSEP, TGFCAB, TGFPAR, TGFVEN, TSIUSU, TGFPPG
   - Funcoes auxiliares: dps_my_string_split, DPS_GERA_EAN13_NUMERO_ROMANEIO
*/


/* ==========================================================
   5) CORPO/ITENS DO ROMANEIO (impressao normal)
   Endpoint Node: POST /romaneio_separacao_corpo
   ========================================================== */

EXEC DPS_ROMANEIO_SEPARACAO_RETORNA_ITENS @codfilial, @ids, @separador;

/* Procedure:
   - Arquivo: sql/DPS_ROMANEIO_SEPARACAO_RETORNA_ITENS.sql
   - Principais fontes: TGWSEP, TGWITT, TGFPRO, TGWEND, TSIUSU
   - Funcao auxiliar: dps_my_string_split
   - Atualiza andamento dos itens: UPDATE TGWITT SET SITUACAO = 'E', ...
*/


/* ==========================================================
   6) CONFIRMACAO POS-IMPRESSAO
   ========================================================== */

-- Endpoint Node: POST /romaneio_confirma_impressao_tarefa
EXEC DPS_ROMANEIO_SEPARACAO_TAREFA_IMPRESSA @codfilial, @ids, @separador;

-- Endpoint Node: POST /romaneio_confirma_naoimpressao_tarefa
EXEC DPS_ROMANEIO_SEPARACAO_TAREFA_NAOIMPRESSA @codfilial, @ids, @separador;


/* ==========================================================
   7) REIMPRESSAO - LISTAGEM
   Endpoint Node: GET /romaneio_reimpressao_paginado/:separador
   ========================================================== */

DECLARE @codusu INT = (SELECT codusu FROM tsiusu WHERE UPPER(nomeusu) = UPPER(@separador));

;WITH Dados AS (
    SELECT
        cab.NUNOTA AS nunota,
        cab.NUMNOTA AS nr_pedido,
        FORMAT(cab.DTALTER, 'dd-MM-yy HH:mm') AS dt_pedido,
        cab.DTFATUR AS dt_faturamento,
        par1.CODPARC AS codparc,
        par1.NOMEPARC AS Cliente,
        cid.NOMECID AS cidade,
        par2.NOMEPARC AS cd_transportador,
        'N' AS incl,
        COUNT(DISTINCT sep.NUTAREFA) AS pagina,
        itt.CODUSUEXEC AS separador,
        cab.CODEMP AS filial
    FROM TGFCAB cab
    LEFT JOIN TGFPar par1 ON cab.CODPARC = par1.CODPARC
    LEFT JOIN TGFPar par2 ON cab.CODPARCTRANSP = par2.CODPARC
    LEFT JOIN TSICID cid ON cab.CODCIDDESTINO = cid.CODCID
    LEFT JOIN TGWSEP sep ON cab.NUNOTA = sep.NUNOTA
    LEFT JOIN TGWITT itt ON sep.NUTAREFA = itt.NUTAREFA
    WHERE cab.STATUSNOTA = 'L'
      AND itt.CODUSUEXEC = @codusu
      AND itt.DHINICIALEXEC IS NOT NULL
      AND itt.DHFINALEXEC IS NOT NULL
    GROUP BY cab.NUNOTA, cab.NUMNOTA, cab.DTALTER, cab.DTFATUR,
             par1.CODPARC, par1.NOMEPARC, cid.NOMECID,
             par2.NOMEPARC, itt.CODUSUEXEC, cab.CODEMP
)
SELECT d.*, t.total
FROM Dados d
CROSS APPLY (SELECT COUNT(*) AS total FROM Dados) t
ORDER BY d.dt_faturamento DESC, d.nunota DESC
OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY;


/* ==========================================================
   8) REIMPRESSAO - CABECALHO
   Endpoint Node: POST /romaneio_separacao_cabecalho_reimpressao
   ========================================================== */

EXEC DPS_ROMANEIO_SEPARACAO_RETORNA_CABECALHO_SEGUNDA_VIA2 @ids, @separador;

/* ==========================================================
   9) REIMPRESSAO - CORPO
   No JS atual, usa o mesmo endpoint de corpo da impressao normal.
   ========================================================== */

EXEC DPS_ROMANEIO_SEPARACAO_RETORNA_ITENS @codfilial, @ids, @separador;
