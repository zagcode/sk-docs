USE [SANKHYA_PROD]
GO
/****** Object:  StoredProcedure [SANKHYA].[DPS_ROMANEIO_SEPARACAO_RETORNA_ITENS]    Script Date: 12/03/2026 15:07:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


  
ALTER     PROCEDURE [SANKHYA].[DPS_ROMANEIO_SEPARACAO_RETORNA_ITENS]    

  @codemp int,  
  @nunota_ids VARCHAR(1000), -- serao os nutarefas.   
		@codigo_separador INT                                              
AS      
    
--select  @codemp = 1,   @nunota_ids = '426', @codigo_separador = 26
  
declare @box INT    
declare @segunda_via varchar(30)    
DECLARE @numero_nota INT   
declare @obs_pedido varchar(250)
    
select @segunda_via = '';    
select @box = 0;    
    
    
CREATE TABLE #Retorno_impressao (nr_romaneio INT NULL);    
    
INSERT INTO #Retorno_impressao (nr_romaneio)    
SELECT * FROM dps_my_string_split(@nunota_ids, ',' );    
  
  
    
CREATE TABLE #Retorno_itens (numero_nota int NULL, /* numero_nota */    
nutarefa int NULL, /* numero_tarefa */    
codprod int NULL, /* codigo_produto */    
quant int null,   
referencia varchar(20) NULL, /* referencia */    
descricao varchar(40) NULL, /* descricao */    
unidade char(2) NULL, /* unidade */    
marca char(30) NULL, /* marca */    
Localizador char(30) NULL, /* s.r.l.c.a */    
cestinha char(30) null,   
cod_usuario_separador int NULL, /* codigo usuario separador */    
nome_usuario_separador varchar(10) NULL, /* nome usuario separador */    
subestoque varchar(20) NULL, /* subestoque */    
ObsPedido varchar(250) null);    
    
--DECLARE @codigo_separador INT;    
DECLARE @nome_separador VARCHAR(10);    
    
--  /* nome separador */  
--select @codigo_separador = codusu,   
--       @nome_separador = nomeusu  
--  from tsiusu  
--  where nomeusu = @separador;    
    
    
  
DECLARE @nr_romaneio INT    
    
DECLARE c_impressao CURSOR FOR     
SELECT nr_romaneio from #Retorno_impressao order by nr_romaneio    
OPEN c_impressao    
WHILE(1=1)    
BEGIN    
 FETCH NEXT FROM c_impressao INTO @nr_romaneio    
  IF (@@FETCH_STATUS <> 0)    
   BREAK    
  
   SELECT  @numero_nota = 0  
   SELECT  @numero_nota = NUNOTA  
      FROM TGWSEP  WITH(NOLOCK) 
       WHERE NUTAREFA   = @nr_romaneio  
         and CODEMPOC = @codemp

     SELECT @obs_pedido       =''									
     SELECT @obs_pedido       = SUBSTRING(OBSERVACAO,1 ,250)
       FROM tgfcab WITH(NOLOCK)                                           
       WHERE nunota   = @numero_nota 
     
					IF @obs_pedido IS NULL OR @obs_pedido = ''
					  SELECT @obs_pedido = ''

  
  
     /*  
     Na tgfitt, quando um produto estiver em dois  lugares ( pratileira e pulmao ) vai gerar duas linhas, ou seja a somatoria da coluna QTDDEST é igual ao pedido.  
  
     entao vai precisar melhorar este processo ai..   
     */  
  
    INSERT INTO #Retorno_itens    
    (numero_nota , /* numero_nota */    
    nutarefa, /* numero_tarefa */    
    codprod , /* codigo_produto */    
    quant ,  
    referencia , /* referencia */   
    Localizador,  /* s.r.l.c.a */    
    unidade, /* unidade */    
    marca,  
    descricao , /* descricao */    
    cestinha ,   
    subestoque,   
    cod_usuario_separador , /* codigo usuario separador */    
    nome_usuario_separador, /* nome usuario separador */    
    ObsPedido )  
    select @numero_nota, @nr_romaneio, TGFPRO.CODPROD,  QTDDEST,  referencia, origem.endereco LOCALIZADOR , codvol, marca, SUBSTRING(DESCRPROD,1,28) ,   
                         destino.endereco  CESTINHA , '' AS SUBESTOQUE , @codigo_separador ,  
                         @nome_separador ,@obs_pedido  
															from tgwitt   
                           left join tgfpro on (tgwitt.codprod = tgfpro.codprod )   
                           left join tgwend origem  on  (tgwitt.codendorigem = origem.codend )  
                           left join tgwend destino  on  (tgwitt.codenddestino = destino.codend ) 
                where NUTAREFA  = @nr_romaneio  
                 and tgwitt.CODEMP = @codemp  
  
  
--  UPDATE tgwitt  
--     SET situacao = 'E', -- em andamento  
--     DHINICIALEXEC = GETDATE(),   
--     DHINICIOMAPA = GETDATE()   
--     where NUTAREFA  = @nr_romaneio  
--       and tgwitt.CODEMP = @codemp  
    
END    
DEALLOCATE c_impressao    
    
SELECT numero_nota, /* numero_nota */    
nutarefa, /* numero_tarefa */    
codprod, /* codigo_produto */    
quant ,  
referencia, /* referencia */    
Localizador, /* s.r.l.c.a */    
unidade, /* unidade */   
marca, /* marca */    
descricao, /* descricao */    
cestinha ,   
subestoque,   
cod_usuario_separador, /* codigo usuario separador */    
nome_usuario_separador, /* nome usuario separador */    
ObsPedido
FROM #Retorno_itens    
order by Localizador
    
  
drop table #Retorno_itens    
drop table #Retorno_impressao    
    