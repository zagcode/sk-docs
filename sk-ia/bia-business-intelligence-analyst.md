---
fetchedAt: 2026-08-20
source: https://ajuda.sankhya.com.br/hc/pt-br/articles/360047266793-B-I-A-Business-Intelligence-Analyst
note: "Extraído manualmente do HTML salvo pelo usuário (ajuda.sankhya.com.br bloqueia fetch automatizado com 403) — sk-docs/sk-ia/B.I.A - Business Intelligence Analyst – Sankhya Gestão de Negócios.html"
---

# B.I.A - Business Intelligence Analyst

A B.I.A é a **Assistente Virtual de Gestão** da Sankhya — um app mobile
(Android/iOS) que permite consultar dados do sistema por voz ou texto
quando o acesso ao computador é restrito. **Não é uma aba de configuração
dentro do editor de um componente de BI** — é um produto/app separado que
consome os dashboards já construídos.

## Requisitos mínimos

- Sankhya Om com **Gerente On-line** parametrizado (Módulo Comercial).
- Licença de uso do app B.I.A (sem ela, funciona só em período de teste).
- Servidor liberado para **acessos externos** — a B.I.A depende de um
  serviço externo ao Sankhya Om
  (`http://bia-production.sa-east-1.elasticbeanstalk.com`), portas TCP
  80 e 22.

## Configuração inicial do app

Ao abrir o app pela primeira vez, informar o **endereço externo** do
sistema Sankhya e depois usuário/senha (os mesmos do Sankhya).

> **Importante:** o "Endereço externo" **NÃO pode conter `/mge` no
> final**. Ex.: se o link do sistema for
> `https://suaempresa.sankhya.com.br/mge/system.jsp`, informar no app
> apenas `https://suaempresa.sankhya.com.br`. Incluir `/mge` causa
> **falha de autenticação e falha na exibição dos dashboards** — o
> próprio app já adiciona esse sufixo internamente.

## Duas fontes de informação

- **Perguntas Nativas** — vêm das análises do **Gerente On-line**.
- **Perguntas Customizadas (treinadas)** — vêm de **Dashboards
  customizados** criados pela empresa (o Construtor de BI documentado em
  `sk-docs/sankhya-conventions/04-dash-gadget-componentes-avancados.md`).
  É aqui que a construção de um dashboard novo se conecta à B.I.A: um
  componente/dashboard bem construído vira uma pergunta que o app sabe
  responder.

### Central de Perguntas

Tela dentro do app (menu **Preferências > Configurações**) onde se veem
todas as perguntas treinadas (nativas e customizadas) e se cria uma nova:
1. Escolher o **dashboard** e a **área do dashboard** (o componente
   específico dentro dele) que vai virar a pergunta.
2. Definir **como a pergunta será feita** (o texto/frase que o usuário vai
   falar ou digitar para disparar essa consulta).
3. "Executar esta pergunta" abre a tela de Conversação com o resultado.

## Filtros na B.I.A

Os filtros usados numa pergunta são **os mesmos disponíveis no Dashboard
de origem** (mesmos parâmetros/prompt-parameters já documentados em
`03-dash-gadget-basico.md`):
- **Filtro obrigatório no Dashboard** → a B.I.A também exige o
  preenchimento antes de responder essa pergunta.
- **Filtro não informado na pergunta** → a B.I.A usa **o último filtro
  salvo pelo usuário no sistema Sankhya** para aquele dashboard (o mesmo
  comportamento de `keep-last="true"` no `<parameter>` do Gadget).

## Parâmetro de sistema relevante

- `TSIPAR` **`CACHESYNCBIA`** — "Valida se é necessário a atualização do
  cache" — controla como a B.I.A consulta informações de dashboards e
  permissões, para economizar processamento e melhorar performance da
  sincronização. Recomendado manter no padrão (ativado).

## Implicação prática para construção de dashboards

Se o dashboard novo precisar ser consultável pela B.I.A: manter os
parâmetros do Gadget claros e com `keep-last`/`required` bem definidos
(afeta diretamente o comportamento de filtro da B.I.A), e testar a
associação via **Central de Perguntas** no app depois de publicado — não
existe configuração adicional a fazer no XML do Gadget em si além do que
já é padrão (a aba "BIA" citada no editor do Construtor de BI, ver
`04-dash-gadget-componentes-avancados.md`, é o atalho para essa mesma
associação a partir da tela de edição do componente).
