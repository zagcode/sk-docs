# API de consulta livre (`dps-consulta`) — validação de queries de dash/relatório

Desde a migração pro Sankhya Cloud (`https://dps.sankhyacloud.com.br`) não há mais acesso direto
ao banco de dados — toda leitura precisa passar pela API Sankhya (`DbExplorerSP.executeQuery`).
Isso complicou a construção/manutenção de dashboards (`sk-dash/`, Gadget XML) e relatórios
(`sk-report/`, JRXML): antes de colar uma query num `<expression type="sql">` ou numa
`textFieldExpression`, não dá mais pra simplesmente rodar o SELECT direto num client SQL para
conferir o que ela retorna.

`dps-consulta` resolve isso: uma API HTTP mínima, separada de qualquer outro projeto, cuja única
função é receber um SELECT via POST e devolver o resultado em JSON — usada só para validar o que
uma query vai retornar durante o desenvolvimento de um dash ou relatório.

## Onde fica e como rodar

Projeto próprio na raiz do workspace: `dps-consulta/` (irmão de `dps-recepcao/`, não uma pasta
dentro dele). **Não é um serviço always-on** — de propósito, não tem Docker/`docker-compose` nem
deploy contínuo em VPS. É pensado quase como "serverless": sobe local só quando alguém vai
construir/ajustar um dash ou relatório e precisa validar uma query, e encerra (`Ctrl+C`) quando
termina.

```bash
cd dps-consulta
npm install
cp .env.example .env   # preencher SANKHYA_USER / SANKHYA_PASS / QUERY_API_KEY
npm run dev             # http://localhost:3100 (porta default diferente da 3000 do dps-recepcao,
                         # pra poder rodar os dois ao mesmo tempo se precisar)
```

## Uso

`POST /consultas` — exige header `X-Query-Key` (valor de `QUERY_API_KEY` no `.env`; sem auth
nenhuma outra requisição é aceita — endpoint expõe leitura livre de qualquer tabela do Sankhya,
então a chave só deve circular entre quem constrói dash/relatório).

```bash
curl -X POST http://localhost:3100/consultas \
  -H "Content-Type: application/json" \
  -H "X-Query-Key: <QUERY_API_KEY>" \
  -d '{"sql": "SELECT TOP 10 NUNOTA, CODPARC, DTNEG FROM TGFCAB WHERE CODEMP = 1"}'
```

Resposta: `{ "quantidade": N, "colunas": [...], "linhas": [{...}, ...] }`.

## Restrições (herdadas do `DbExplorerSP.executeQuery` do próprio Sankhya)

- Só `SELECT` — `INSERT`/`UPDATE`/`DELETE` são rejeitados pela API Sankhya (é somente leitura).
- **Não aceita `WITH` (CTE)** — "O comando SELECT está em formato inválido". Reescrever como
  subquery aninhada. Isso inclui o padrão CTE `PARAMS` documentado em
  [02-sql-padroes.md](02-sql-padroes.md) — pra validar uma query de dashboard que usa esse padrão
  nesta API, inline o `PARAMS` como subquery antes de testar.
- Um único comando por chamada (sem `;` no meio).
- Colunas `CHAR`/tamanho fixo do SQL Server voltam com espaço de preenchimento à direita — a API
  já faz `.trim()` de toda string antes de devolver.

## Relação com `dps-recepcao`

`dps-consulta` reaproveita literalmente o código de login/sessão Sankhya (`src/sankhya/client.ts`)
já validado em produção no `dps-recepcao` — cache de sessão (~25min), retry automático em sessão
expirada (`status === "3"`), e fila serializada de chamadas (o Sankhya Cloud rejeita duas
requisições concorrentes na mesma sessão, `status === "4"`). Playbook completo (login/sessão,
`DbExplorerSP`, gotchas de escrita, PK auto-gerada) na memória de sessão `sankhya_api_integration`
— reaproveitável para qualquer integração nova via API.

Diferença de propósito: `dps-recepcao` é um sistema operacional (totem/painel/entrega) que fica
no ar o tempo todo. `dps-consulta` é uma ferramenta de desenvolvimento, sem estado, sem cache
próprio, sem parte alguma do domínio de negócio — só o caminho SELECT.
