USE [SANKHYA_PROD]
GO
/****** Object:  StoredProcedure [SANKHYA].[DPS_ROMANEIO_SEPARACAO_RETORNA_CABECALHO]    Script Date: 12/03/2026 15:01:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [SANKHYA].[DPS_ROMANEIO_SEPARACAO_RETORNA_CABECALHO]
    @nunota_ids VARCHAR(100),
    @separador  VARCHAR(10)
    AS
BEGIN
SET NOCOUNT ON;

DECLARE @numero_nota INT;
DECLARE @saida_transp VARCHAR(10);
DECLARE @numero_romaneio INT;
DECLARE @codigo_filial INT;
DECLARE @nome_filial CHAR(40);
DECLARE @paginas INT;
DECLARE @data_hora DATETIME;
DECLARE @serie_pedido CHAR(3);
DECLARE @numero_pedido INT;
DECLARE @box INT;
DECLARE @data_hora_liberacao2 DATETIME;
DECLARE @codigo_digitador INT;
DECLARE @nome_digitador CHAR(10);
DECLARE @cliente_numero INT;
DECLARE @nome_cliente CHAR(40);
DECLARE @razao_cliente CHAR(40);
DECLARE @numero_separador INT;
DECLARE @nome_separador CHAR(10);
DECLARE @end_cliente VARCHAR(500);
DECLARE @cidade_cliente VARCHAR(50);
DECLARE @estado_cliente CHAR(2);
DECLARE @codigo_transportador INT;
DECLARE @nome_transportador CHAR(40);
DECLARE @cod_representante SMALLINT;
DECLARE @nome_representante CHAR(15);
DECLARE @tipo_frete VARCHAR(10);
DECLARE @valor_frete FLOAT;
DECLARE @codigo_condicao_venda SMALLINT;
DECLARE @descicao_condicao_venda CHAR(36);
DECLARE @valor_pedido FLOAT;
DECLARE @segunda_via VARCHAR(50);
DECLARE @inclusao VARCHAR(15);
DECLARE @cod_barras VARCHAR(13);
DECLARE @cd_frete VARCHAR(1);
DECLARE @dt_pedido SMALLDATETIME;
DECLARE @obs_pedido VARCHAR(250);
DECLARE @hora VARCHAR(5);
DECLARE @codigo_condicao_venda1 INT;

SELECT @segunda_via = '';
SET @box = 0;

CREATE TABLE #Retorno_impressao (nunota INT NULL);

    INSERT INTO #Retorno_impressao (nunota)
SELECT * FROM dps_my_string_split(@nunota_ids, ',');

/* nome separador */
SELECT @numero_separador = 0;

SELECT
    @numero_separador = CODUSU,
    @nome_separador   = NOMEUSU
FROM TSIUSU WITH (NOLOCK)
WHERE CODUSU = @separador;

CREATE TABLE #Retorno_cabecalho (
    numero_nota INT NULL,
    saida_transp VARCHAR(5) NULL,
    numero_romaneio INT NULL,
    codigo_filial INT NULL,
    nome_filial CHAR(40) NULL,
    paginas INT NULL,
    data_hora DATETIME NULL,
    serie_pedido CHAR(3) NULL,
    numero_pedido INT NULL,
    box INT NULL,
    data_hora_liberacao2 DATETIME NULL,
    codigo_digitador INT NULL,
    nome_digitador CHAR(10) NULL,
    cliente_numero INT NULL,
    nome_cliente CHAR(40) NULL,
    numero_separador INT NULL,
    nome_separador CHAR(10) NULL,
    end_cliente VARCHAR(500) NULL,
    cidade_cliente VARCHAR(50) NULL,
    estado_cliente CHAR(2) NULL,
    codigo_transportador INT NULL,
    nome_transportador CHAR(40) NULL,
    cod_representante SMALLINT NULL,
    nome_representante CHAR(15) NULL,
    tipo_frete VARCHAR(10) NULL,
    valor_frete FLOAT NULL,
    codigo_condicao_venda SMALLINT NULL,
    descicao_condicao_venda CHAR(36) NULL,
    valor_pedido FLOAT NULL,
    segunda_via VARCHAR(50) NULL,
    inclusao VARCHAR(15) NULL,
    cod_barras VARCHAR(13) NULL,
    NUTAREFA INT NULL,
    razao_cliente CHAR(40) NULL
    );

DECLARE @nr_pedido INT;
DECLARE @dv CHAR(1);

DECLARE c_impressao CURSOR FOR
SELECT nunota FROM #Retorno_impressao ORDER BY nunota;

                   OPEN c_impressao;

WHILE (1 = 1)
BEGIN
    FETCH NEXT FROM c_impressao INTO @numero_nota;
IF (@@FETCH_STATUS <> 0) BREAK;

-- SEPARACAO
SELECT @numero_romaneio = 0;

SELECT
    @numero_pedido         = AD_NUMPED,
    @codigo_condicao_venda = AD_CODTIPVENDA,
    @numero_romaneio       = NUTAREFA,
    @cliente_numero        = AD_CODCLI,
    @codigo_transportador  = AD_CODTRANSP,
    @data_hora_liberacao2  = AD_DTLIBPED
FROM TGWSEP
WHERE NUNOTA   = @numero_nota
  AND SITUACAO = 1
  AND (AD_CODUSUEXEC IS NULL OR AD_CODUSUEXEC = 0);

IF @numero_romaneio > 0
BEGIN
UPDATE TGWSEP
SET AD_CODUSUEXEC = @numero_separador
WHERE NUNOTA   = @numero_nota
  AND SITUACAO = 1
  AND NUTAREFA = @numero_romaneio
  AND (AD_CODUSUEXEC IS NULL OR AD_CODUSUEXEC = 0);
END

SELECT
    @codigo_digitador = 0,
    @cd_frete = '',
    @codigo_condicao_venda = 0;

SELECT
    @codigo_digitador       = CODUSUINC,
    @dt_pedido              = DTNEG,
    @cd_frete               = CIF_FOB,
    @codigo_condicao_venda  = AD_CODTIPVENDAFAIXA,
    @codigo_condicao_venda1 = CODTIPVENDA,
    @cod_representante      = CODVEND,
    @obs_pedido             = OBSERVACAO,
    @codigo_filial          = CODEMP,
    @valor_pedido           = VLRNOTA,
    @valor_frete            = VLRFRETE,
    @cd_frete               = CIF_FOB
FROM TGFCAB
WHERE NUNOTA = @numero_nota;

IF @codigo_condicao_venda IS NULL OR @codigo_condicao_venda = 0
SELECT @codigo_condicao_venda = @codigo_condicao_venda1;

SELECT @data_hora = GETDATE();

IF @cd_frete = 'C' SELECT @tipo_frete = 'PAGO  ';
IF @cd_frete = 'F' SELECT @tipo_frete = 'A PAGAR';

SELECT @saida_transp = '';

SELECT @saida_transp =
       SUBSTRING(CONVERT(VARCHAR, horafiN), 1, LEN(CONVERT(VARCHAR, horafiN)) - 2)
           + ':' +
       SUBSTRING(CONVERT(VARCHAR, horafiN), LEN(CONVERT(VARCHAR, horafiN)) - 2, 2)
FROM AD_TDPSTABFRETE
         LEFT JOIN AD_TDPSTABFRETEHORA
                   ON AD_TDPSTABFRETE.CODIGO = AD_TDPSTABFRETEHORA.CODIGO
WHERE CODPARCTRANSP = @codigo_transportador;

-- TRANSPORTADOR
SELECT @nome_transportador = NOMEPARC
FROM TGFPAR WITH (NOLOCK)
WHERE CODPARC = @codigo_transportador;

-- REPRESENTANTE
SELECT @nome_representante = APELIDO
FROM TGFVEN
WHERE CODVEND = @cod_representante;

-- FILIAL
SELECT @nome_filial = NOMEPARC
FROM TGFPAR
WHERE CODPARC = @codigo_filial;

SELECT @hora = CONVERT(VARCHAR, GETDATE(), 108);

-- DIGITADOR
SELECT @nome_digitador = NOMEUSU
FROM TSIUSU
WHERE CODUSU = @codigo_digitador;

SELECT
    @nome_cliente   = cliente.NOMEPARC,
    @razao_cliente  = cliente.RAZAOSOCIAL,
    @end_cliente    = CONCAT(endereco_cliente.TIPO, ' ', LTRIM(RTRIM(endereco_cliente.NOMEEND)), ',', cliente.NUMEND),
    @cidade_cliente = cidade_cliente.NOMECID,
    @estado_cliente = estado_cliente.UF,
    @box            = COALESCE(TRY_CONVERT(INT, cliente.AD_BOXSEPBOQUETA), 0)
FROM TGFPAR cliente WITH (NOLOCK)
                     LEFT JOIN TSIEND endereco_cliente ON cliente.CODEND = endereco_cliente.CODEND
    LEFT JOIN TSICID cidade_cliente   ON cliente.CODCID = cidade_cliente.CODCID
    LEFT JOIN TSIUFS estado_cliente   ON cidade_cliente.UF = estado_cliente.CODUF
WHERE cliente.CODPARC = @cliente_numero;

SELECT @inclusao = '';

IF EXISTS (
                SELECT 0
                FROM TGFCAB WITH (NOLOCK)
                WHERE CODEMP = @codigo_filial
                  AND CODPARC = @cliente_numero
                  AND DTNEG = @dt_pedido
                  AND PENDENTE = 'S'
                  AND NUNOTA <> @numero_nota
            )
BEGIN
SELECT @inclusao = 'I N C L U S A O ';
END

SET @descicao_condicao_venda = '';
SELECT @descicao_condicao_venda =
       'CONDIÇÃO VENDA :' + STRING_AGG(PRAZO, '/') + '  DIAS'
FROM TGFPPG
WHERE CODTIPVENDA = @codigo_condicao_venda;

EXEC @cod_barras = DPS_GERA_EAN13_NUMERO_ROMANEIO @nr_romaneio = @numero_romaneio;

INSERT INTO #Retorno_cabecalho (
    numero_nota, saida_transp, numero_romaneio, codigo_filial, nome_filial,
    paginas, data_hora, serie_pedido, numero_pedido, box, data_hora_liberacao2,
    codigo_digitador, nome_digitador, cliente_numero, nome_cliente, numero_separador,
    nome_separador, end_cliente, cidade_cliente, estado_cliente, codigo_transportador,
    nome_transportador, cod_representante, nome_representante, tipo_frete, valor_frete,
    codigo_condicao_venda, descicao_condicao_venda, valor_pedido, segunda_via,
    inclusao, cod_barras, NUTAREFA, razao_cliente
    )
VALUES (
    @numero_nota, @saida_transp, @numero_romaneio, @codigo_filial, @nome_filial,
    @paginas, @data_hora, @serie_pedido, @numero_pedido, @box, @data_hora_liberacao2,
    @codigo_digitador, @nome_digitador, @cliente_numero, @nome_cliente, @numero_separador,
    @nome_separador, @end_cliente, @cidade_cliente, @estado_cliente, @codigo_transportador,
    @nome_transportador, @cod_representante, @nome_representante, @tipo_frete, @valor_frete,
    @codigo_condicao_venda, @descicao_condicao_venda, @valor_pedido, @segunda_via,
    @inclusao, @cod_barras, @numero_romaneio, @razao_cliente
    );
END

    CLOSE c_impressao;
    DEALLOCATE c_impressao;

SELECT
    numero_nota, saida_transp, numero_romaneio, codigo_filial, nome_filial,
    paginas, data_hora, serie_pedido, numero_pedido, box, data_hora_liberacao2,
    codigo_digitador, nome_digitador, cliente_numero, nome_cliente, numero_separador,
    nome_separador, end_cliente, cidade_cliente, estado_cliente, codigo_transportador,
    nome_transportador, cod_representante, nome_representante, tipo_frete, valor_frete,
    codigo_condicao_venda, descicao_condicao_venda, valor_pedido, segunda_via,
    inclusao, cod_barras,
    numero_romaneio AS NUTAREFA,
    razao_cliente
FROM #Retorno_cabecalho;

     DROP TABLE #Retorno_cabecalho;
DROP TABLE #Retorno_impressao;
    END