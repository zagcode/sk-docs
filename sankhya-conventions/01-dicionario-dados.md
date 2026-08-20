# Dicionário de dados — ERP + WMS Sankhya

> Espelho do dicionário mantido em `.github/copilot-instructions.md`. Em caso
> de divergência, o rulebook é a fonte da verdade — atualize os dois juntos.

## ERP

### TGFCAB — Cabeçalho de movimentações
| Coluna | Tipo | Descrição |
|---|---|---|
| NUNOTA | INT | Chave única da nota (PK) |
| NUMNOTA | INT | Número da nota fiscal |
| AD_NUPED | VARCHAR | Número do pedido externo |
| TIPMOV | CHAR(1) | Tipo: `'P'`=Pedido, `'V'`=Venda, `'C'`=Compra |
| STATUSNOTA | CHAR(1) | `'C'`=Cancelada — **sempre filtrar `<> 'C'`** |
| CODPARC | INT | FK → TGFPAR (parceiro/cliente) |
| CODVEND | INT | FK → TGFVEN (vendedor/atendente do pedido) |
| CODEMP | INT | FK → TGFEMP (empresa) |
| DTNEG | DATE | Data de negociação |
| VLRNOTA | DECIMAL | Valor total da nota |

### TGFITE — Itens da nota
| Coluna | Tipo | Descrição |
|---|---|---|
| NUNOTA | INT | FK → TGFCAB |
| SEQUENCIA | INT | Sequência do item na nota |
| CODPROD | INT | FK → TGFPRO (produto) |
| QTDNEG | DECIMAL | Quantidade negociada |
| QTDENTREGUE | DECIMAL | Quantidade entregue |
| QTDWMS | DECIMAL | Quantidade enviada ao WMS — `0` = não enviado, `NULL` = produto fora do WMS |
| QTDCONFERIDA | DECIMAL | Quantidade conferida no WMS (pós separação/coletor) |
| VLRUNIT | DECIMAL | Valor unitário |
| VLRTOT | DECIMAL | Valor total do item (bruto) |
| VLRDESC | DECIMAL | Valor de desconto do item |
| CODVEND | INT | FK → TGFVEN (vendedor do item) |
| CODEXEC | INT | FK → TGFVEN (atendente/executor do item) |
| AD_PERCOM_REP | DECIMAL | % de comissão do vendedor |
| AD_PERCOM_ATE | DECIMAL | % de comissão do atendente |

### TGFPAR — Parceiros (clientes / fornecedores)
| Coluna | Tipo | Descrição |
|---|---|---|
| CODPARC | INT | PK |
| NOMEPARC | VARCHAR | Nome completo |
| TIPPESSOA | CHAR(1) | `'F'`=Física, `'J'`=Jurídica |

### TGFVEN — Vendedores / Atendentes
| Coluna | Tipo | Descrição |
|---|---|---|
| CODVEND | INT | PK |
| APELIDO | VARCHAR | Nome curto — **usar sempre como display, nunca NOMEVEND** |

### TGFPRO — Produtos
| Coluna | Tipo | Descrição |
|---|---|---|
| CODPROD | INT | PK |
| DESCRPROD | VARCHAR | Descrição do produto |
| CODMARCA | INT | FK → TGFMAR (marca) — **usar para filtrar por marca, nunca `PRO.MARCA`** |
| MARCA | VARCHAR | Texto livre — **não usar em filtros com parâmetro de entidade** |
| CODFAM | INT | FK → TGFGRU (família/grupo) |
| UTILIZAWMS | CHAR(1) | `'S'` = produto controlado pelo WMS |

### TGFMAR — Marcas
| Coluna | Tipo | Descrição |
|---|---|---|
| CODIGO | INT | PK |
| DESCRICAO | VARCHAR | Nome da marca |

### TGFGRU — Grupos / Famílias de produto
| Coluna | Tipo | Descrição |
|---|---|---|
| CODGRU | INT | PK |
| DESCRGRU | VARCHAR | Descrição do grupo |

### TGFITS — Rastreamento de movimentos de estoque
| Coluna | Tipo | Descrição |
|---|---|---|
| CODEMP | INT | FK → TGFEMP |
| CODLOCAL | INT | Local de estoque (usar `CODLOCAL = 10` para WMS) |
| CODPROD | INT | FK → TGFPRO |
| NUNOTA | INT | FK → TGFCAB |
| SEQUENCIA | INT | Sequência do item |
| DTENTSAI | DATE | Data da entrada ou saída |
| QTDENT | DECIMAL | Quantidade de entrada |
| QTDSAI | DECIMAL | Quantidade de saída |
| CONTROLE | VARCHAR | Controle do lote/série |

> **Regra crítica:** `SUM(QTDENT - QTDSAI)` = saldo de rastreamento por produto/empresa/local. Se `0` ou inexistente para `CODLOCAL = 10`, o Sankhya **bloqueia a emissão da nota fiscal**.

### TGFVAS — Vínculos entre notas (origem → destino)
| Coluna | Tipo | Descrição |
|---|---|---|
| NUNOTAORIG | INT | FK → TGFCAB (nota de origem — compra/entrada) |
| SEQUENCIAORIG | INT | Sequência do item na nota de origem |
| NUNOTA | INT | FK → TGFCAB (nota de destino — venda/saída) |
| SEQUENCIA | INT | Sequência do item na nota de destino |
| QTDSAI | DECIMAL | Quantidade saída vinculada |

> Usada para rastrear o custo médio e o lote de origem de cada item vendido.

### TGFCUS — Custo dos produtos
| Coluna | Tipo | Descrição |
|---|---|---|
| CODPROD, CODEMP, DTATUAL | — | PK composta |
| CUSSEMICM | DECIMAL | Custo sem ICM — **sempre buscar com OUTER APPLY TOP 1 ORDER BY DTATUAL DESC** |

### TGFEMP — Empresas
| Coluna | Tipo | Descrição |
|---|---|---|
| CODEMP | INT | PK |
| NOMEEMP | VARCHAR | Nome da empresa |

### TGFEST — Estoque contábil (ERP)
| Coluna | Tipo | Descrição |
|---|---|---|
| CODPROD | INT | FK → TGFPRO |
| CODEMP | INT | FK → TGFEMP |
| CODLOCAL | INT | Local de estoque — **usar apenas CODLOCAL = 10 para WMS** |
| CODPARC | INT | Parceiro (usar `CODPARC = 0` para saldo geral) |
| ESTOQUE | DECIMAL | Quantidade em estoque contábil |

### TGFLOC — Locais de Estoque
| CODLOCAL | Descrição | Uso em WMS |
|---|---|---|
| 10 | Depósito Comercial | **SIM** — único local controlado pelo WMS |
| 20 | Depósito Garantia | Não |
| 30 | Depósito Uso e Consumo | Não |
| 40 | Depósito Temporário Aguardando Envio para WMS | Não |

> **Regra de venda:** o Sankhya valida disponibilidade com base em `TGFEST` do `CODLOCAL = 10 apenas`. Nunca usar `TGWEST` como critério de disponibilidade para pedidos/faturamento.

### TSIPAR — Parâmetros de sistema
| Coluna | Tipo | Descrição |
|---|---|---|
| CHAVE | VARCHAR | Nome do parâmetro (ex.: `TIPTITCREDCLI`, `UFNFEOMITV160B`, `DESFINPGCOMPDNF`, `LIMITLINHASDASH`, `ORDENARACOES`, `SOBREVALORGRAF`, `USADASHANT`, `CACHESYNCBIA`) |
| CODUSU | INT | `0` = global; código de usuário específico sobrescreve o global |
| TEXTO | VARCHAR | Valor tipo texto |
| INTEIRO | DECIMAL | Valor tipo inteiro |
| LOGICO | CHAR(1) | `'S'`/`'N'` |

Leitura típica: `SELECT INTEIRO FROM TSIPAR WHERE CHAVE = 'TIPTITCREDCLI' AND CODUSU = 0`.

### TGFFIN — Títulos financeiros
| Coluna | Tipo | Descrição |
|---|---|---|
| NUNOTA | INT | FK → TGFCAB |
| NUFIN | INT | PK do título |
| CODTIPTIT | INT | FK → TGFTIT — comparar com `TSIPAR` para significado de negócio |
| DTVENC | DATE | Vencimento da parcela |
| VLRDESDOB | DECIMAL | Valor da parcela |
| TPAGNFCE | VARCHAR | Forma de pagamento NFe/NFCe (tabela 54 SPED) — não confundir com `CODTIPTIT` |
| DHBAIXA | TIMESTAMP | Data/hora de baixa (`NULL` = em aberto) |
| DESDOBDUPL | CHAR(1) | `'M','V','K','F','T'` = ignorado na soma de faturas do DANFE |

## WMS (MGEWMS)

### Tabelas e função principal
| Tabela | Função |
|---|---|
| TGWEAX | Endereço Auxiliar |
| TGWRXN | Notas por Recebimento |
| TGWITER | Item Nota de Recebimento |
| TGWUSU | Usuários x Tarefas do WMS |
| TGWTTR | Tipos de Tarefa do WMS |
| TGWEND | Endereço de Armazenamento |
| TGWDCA | Doca do WMS |
| TGWREC | Recebimento WMS |
| TGWCON | Conferência cega de produtos |
| TGWCOI | Item da conferência cega |
| TGWITT | Item da tarefa |
| TGWTAR | Tarefas WMS |
| TGWEST | Estoque por endereço do WMS |
| TGWSEP | Separação WMS |
| TGWSXN | Nota por Separação |
| TGWITE | Item de Nota no WMS |
| TGWEXP | Endereço do Produto WMS |
| TGWARC | Área de Conferência |
| TGWARS | Área de Separação |
| TGWEAC | Endereços da Área de Conferência |
| TGWEAS | Endereços da Área de Separação |
| TGWDEV | Devolução WMS |

### Correlações WMS x ERP

- **Recebimento**: `TGWREC` ↔ tarefas (`TGWTAR`/`TGWITT` via `NUTAREFA`); `TGWRXN`/`TGWITER` fazem a ponte com `TGFCAB`/`TGFITE`. Impacto físico reflete em `TGWEST` (`ENTRADASPEND`/`ENTRPENDVOLPAD` → `ESTOQUE`/`ESTOQUEVOLPAD`).
- **Separação/conferência**: `TGWSEP` é o cabeçalho (tarefa/conferência/doca); `TGWITE`/`TGWSXN` vinculam com nota ERP; `TGWCON`/`TGWCOI` conciliam separado x conferido; `TGWITT` é a trilha operacional (origem/destino/status).
- **Endereçamento/doca**: `TGWEND` base de endereços; `TGWDCA` classifica endereços de doca (excluídos da conciliação); `TGWEXP` endereço padrão por produto; `TGWEST` saldo por produto/endereço.
- **Governança de tarefas**: `TGWTTR` tipo, `TGWUSU` vínculo usuário/tarefa, `TGWTAR`/`TGWITT` cabeçalho/detalhe.
- **Devolução**: `TGWDEV`.

### Modelo de duplo estoque: ERP x WMS

| Aspecto | TGFEST (ERP/contábil) | TGWEST (WMS/físico) |
|---|---|---|
| Granularidade | produto + empresa + local | produto + empresa + endereço físico |
| Uso principal | disponibilidade para **venda** | posição física na **expedição** |
| Vínculo de nota | TGFITE (QTDNEG/QTDENTREGUE) | TGWSEP/TGWITE/TGWITT + TGFITE.QTDWMS |
| Atualizado por | Faturamento/movimentações ERP | Recebimento, separação, conferência WMS |
| Filtro padrão | CODPARC=0, CODLOCAL=10 | Excluir endereços de doca (TGWDCA) |

> Um produto pode estar disponível em `TGFEST` mas ainda não recebido/endereçado no WMS — causa mais comum de inconsistência na expedição.

### Fluxo de saída WMS — estágios e impacto em estoque
| Estágio | TGWEST armazenamento | TGWEST checkout | TGFEST |
|---|---|---|---|
| 1. Separação criada | `SAIDASPEND` criado | `ENTRADASPEND` criado | inalterado |
| 2. Picking | `ESTOQUE` reduzido, `SAIDASPEND` zerado | `ESTOQUE` aumentado, `ENTRADASPEND` zerado | inalterado |
| 3. Conferência + faturamento | — | `ESTOQUE` reduzido (vai para doca) | decrementado pelo faturamento |
| 4. Doca | — | — | já decrementado; doca excluída do saldo WMS |

> Equação de equilíbrio: `TGFEST.ESTOQUE = TGWEST(armazenamento).ESTOQUE + TGWEST(checkout).ESTOQUE`

### Tipos de endereço WMS
| Tipo | Critério |
|---|---|
| Armazenamento | `ATIVO='S'`, `ANALITICO='S'`, `EXCLCONF<>'S'`, não em `TGWDCA`, sem DIVER/AVARI no nome |
| Checkout | `EXCLCONF='S'` |
| Doca | Presente em `TGWDCA` — excluir sempre da conciliação |
| Divergência/Avaria | `DESCREND LIKE '%DIVER%'` ou `'%AVARI%'` — excluir |

### Regras de segurança para scripts WMS
- Ajustes massivos de `TGWEST`: sempre `BEGIN TRANSACTION` + conferência antes/depois.
- Preferir critérios estritos (`CODEMP`, `CODPROD`, `CODEND`, `CODVOL`), nunca filtro amplo.
- Antes de forçar status em `TGWSEP`/`TGWITT`, validar impacto em faturamento e rastreabilidade.
