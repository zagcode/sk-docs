---
updatedAt: 2025-11-10T23:37:38.000Z
---

Fetch the complete documentation index at: https://developer.sankhya.com.br/llms.txt. Use this file to discover all available pages before exploring further. Append .md to any documentation page URL to get its markdown version.

# Eventos de Click no iReport

Na versão corrente da plataforma Sankhya se encontra presente o componente de BI chamado iReport que permite a exibição dos relatórios formatados nos dashboards.

É possível utilizar eventos de click no componente iReport, mas é necessário criá-los no editor do Jasper Report (iReport Design ou outro). Para isto basta adicionar *Hyperlink* na série do gráfico ou em algum TextField.

Segue abaixo um exemplo de como configurar um TextField:

<Image title="1.png" alt={1213} className="border" border={true} src="https://files.readme.io/2ae3e2e-1.png" />

Clique com o botão direito do mouse sobre o textField (ou série de um gráfico) e vá em Hyperlink.

![860](https://files.readme.io/4fa3d3f-2.png "2.png")

Exemplo de configuração de link para abrir a tela Relatórios Formatados passando o número do relatório como parâmetro.

> ❗️ Importante
>
> Observe que o link deve iniciar com **“javascript:”** e  a parte fixa dele deve estar entre aspas. As funções para os eventos são:
>
> * Atualizar detalhes: refreshDetail&#x73;*(id\_do\_gadget, parâmetros)*.
> * Abrir outro nível: openLeve&#x6C;*(id\_do\_nivel, parâmetros)*.
> * Abrir uma tela do sistema: openAp&#x70;*(id\_da\_tela, parâmetros)*.
> * Abrir uma página em outra aba: openPag&#x65;*(url\_da\_página, parâmetros)*.

## Como tirar dúvidas?

Para tirar dúvidas e compartilhar informações, use a sala [Relatórios formatados](https://comunidade.sankhya.com.br/c/personalizacoes/relatorios-formatados/22) da comunidade Sankhya Developer.