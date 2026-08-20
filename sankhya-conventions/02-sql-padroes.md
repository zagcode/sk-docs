# Padrões SQL obrigatórios e regras de negócio DPS

> Espelho do rulebook `.github/copilot-instructions.md`. Em caso de
> divergência, o rulebook vence.

## Regras gerais de geração de scripts SQL (fora de dashboard)

- **SEMPRE** gerar um bloco de diagnóstico/preview (`PRINT`, `SELECT`) que executa primeiro e mostra o que será feito.
- **SEMPRE** deixar o bloco de execução (`INSERT`, `UPDATE`, `DELETE`, `EXEC sp_executesql`) comentado com `/* ... */`.
- O comentário deve deixar claro que o bloco só deve ser descomentado **após confirmar que o preview está correto**.
- Nunca criar scripts SQL que executem DML diretamente sem essa separação preview/execução.

## Filtro padrão em pedidos
```sql
WHERE CAB.TIPMOV = 'P'
  AND ISNULL(CAB.STATUSNOTA, '') <> 'C'
```

## Custo mais recente por produto/empresa/data (NUNCA usar JOIN direto em TGFCUS)
```sql
OUTER APPLY (
    SELECT TOP 1 C.CUSSEMICM
    FROM TGFCUS C
    WHERE C.CODPROD = ITE.CODPROD
      AND C.CODEMP = CAB.CODEMP
      AND C.DTATUAL <= CAB.DTNEG
    ORDER BY C.DTATUAL DESC
) CUS
```

## Valor líquido do item (sempre usar no lugar de VLRTOT puro)
```sql
ISNULL(ITE.VLRTOT, 0) - ISNULL(ITE.VLRDESC, 0) AS VLRTOT_LIQ
```
Ao agregar por nota:
```sql
SUM(ISNULL(ITE.VLRTOT, 0) - ISNULL(ITE.VLRDESC, 0)) AS VLR_ITENS_TOTAL
```
**Nunca usar `TGFCAB.VLRNOTA` diretamente para cálculos de valor ou rentabilidade.**

## Rentabilidade de uma nota/item
```sql
CASE
    WHEN ISNULL(VLR_ITENS_TOTAL, 0) = 0 THEN 0
    ELSE ((ISNULL(VLR_ITENS_TOTAL, 0) - ISNULL(VLR_CUSTO_TOTAL, 0)) / ISNULL(VLR_ITENS_TOTAL, 0)) * 100.0
END
```

## Parâmetro Empresa — sempre converter para INT
```sql
CAST(:Empresa AS INT) AS CODEMP_FILTRO
-- ou, usando o cast nativo do Sankhya:
EST.CODEMP = :@Empresa
```
> O prefixo `:@` no Sankhya faz o cast automático do parâmetro para o tipo numérico. Ver também `02-sql-padroes.md` → `04-dash-gadget-componentes-avancados.md` para a variante `:#` (recomendada por performance) e a diferença entre as três sintaxes de parâmetro.

## Parâmetros de período no Gadget
```sql
:Periodo.INI   -- data inicial
:Periodo.FIN   -- data final (incluir +1 dia com DATEADD(DAY, 1, ...))
```

## Padrão CTE `PARAMS` no topo (recorrente em quase todo dashboard real)
Normalizar/validar todos os parâmetros de uma vez numa CTE única, reaproveitada via `CROSS JOIN PARAMS` no resto da query — evita repetir `:@PARAM` espalhado e centraliza casts/validações:
```sql
WITH PARAMS AS (
    SELECT :@Empresa AS CODEMP_FILTRO, ...
)
SELECT ...
FROM TGFCAB CAB
CROSS JOIN PARAMS P
WHERE CAB.CODEMP = P.CODEMP_FILTRO
```

## Validação de parâmetros sem falhar a query (linha-sentinela)
Calcular uma flag de validade (`DATAS_INVALIDAS`, `ANO_FILTRO invalido`, etc.) na CTE `PARAMS` e, se inválida, retornar via `UNION ALL` uma única linha com mensagem de erro amigável — em vez de a query falhar ou devolver dataset vazio sem explicação:
```sql
CASE
    WHEN :Periodo_sem.INI > :Periodo_sem.FIN
      OR :Periodo_com.INI > :Periodo_com.FIN
      OR :Periodo_sem.FIN >= :Periodo_com.INI
      OR :Periodo_com.INI BETWEEN :Periodo_sem.INI AND :Periodo_sem.FIN
    THEN 1 ELSE 0
END AS DATAS_INVALIDAS
```
Quando `DATAS_INVALIDAS = 1`, retornar linha de erro via `UNION ALL` no lugar dos dados. Visto em produção nos dashboards `bi_reativacao` e `comissao gerencial`.

## Regras de negócio DPS

### Parceiros reativados
Parceiro que pediu no **Periodo_com** e **não** pediu no **Periodo_sem**:
```sql
AND NOT EXISTS (
    SELECT 1 FROM BASE_PEDIDOS BS
    WHERE BS.CODEMP = BC.CODEMP
      AND BS.CODPARC = BC.CODPARC
      AND BS.DTNEG >= P.DT_SEM_INI
      AND BS.DTNEG < DATEADD(DAY, 1, P.DT_SEM_FIM)
)
```

### Cliente semanal / faturamento
Ver memória dedicada `cliente_semanal_faturamento` — renegociação entra em `codtiptit 31`; financeiro precisa abater créditos antes de consolidar.

## Padrões SQL avançados vistos em dashboards reais (referência de técnica)

- **CTEs encadeadas** para regras de calendário (dias úteis do mês/ano) antes do `SELECT` final.
- **Tally table sem tabela de calendário**, via `sys.columns` cross join, para gerar série de datas:
  ```sql
  SELECT TOP (DATEDIFF(DAY, @ini, @fim) + 1)
         DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1, @ini) AS DATA
  FROM sys.columns c1 CROSS JOIN sys.columns c2
  ```
- **`SUM(...) OVER ()`** para percentual do total sem subquery correlacionada:
  ```sql
  (DD.VALOR / (SUM(DD.VALOR) OVER ())) * 100 AS PERCTOTAL
  ```
- **`STRING_AGG`** para concatenar lista de valores selecionados num único texto/KPI:
  ```sql
  'Cód.Emp: ' + STRING_AGG(TSIEMP.CODEMP, ' / ') AS RESULTADO
  ```
- **Linha "separador"/placeholder** injetada via `UNION ALL` com coluna de ordenação artificial, combinada com `BKCOLOR`/`FGCOLOR` (ver `05-dash-gadget-padroes-reais.md`) para destacar visualmente a linha.
- `OUTER APPLY`/subquery correlacionada reaparece para "última alteração" em outras tabelas além de `TGFCUS`, ex. último `DHALTER` de `TGFTOP`.
- Máscara `mask="#.##0;-n"` (seção positiva;negativa, estilo Excel) como alternativa a `#.##0,00` simples.

## Convenções gerais do projeto (fora de SQL)

- Nunca usar `NOMEVEND` — sempre `TGFVEN.APELIDO`.
- Sempre `ISNULL(campo, 0)` em valores numéricos antes de operar.
- Nunca `JOIN` direto em `TGFCUS` — sempre `OUTER APPLY TOP 1`.
- Mensagens de erro para usuário final: claras, objetivas, sem jargão técnico, com orientação prática do que corrigir. Detalhe técnico vai para o campo LOG.
