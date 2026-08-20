---
updatedAt: 2025-11-10T23:37:34.000Z
---

Fetch the complete documentation index at: https://developer.sankhya.com.br/llms.txt. Use this file to discover all available pages before exploring further. Append .md to any documentation page URL to get its markdown version.

# Propriedades de Parâmetros do iReport

Confira neste artigo, algumas propriedades de parâmetros que podem ser configuradas no iReport e sua interpretação pela aplicação.

## Entidade/Tabela

Ao ser interpretada pela aplicação, essa propriedade atua como um campo de busca (aquele com a lupinha), na qual o usuário procura pelo nome/descrição da entidade (ex. nome da empresa, descrição do produto, etc.) e é retornado o código dessa entidade.

![464](https://files.readme.io/bbbad86-01.png "01.png")

Para configurar basta ir em parâmetros > propriedades e adicionar duas propriedades:

* a primeira com o nome de “nomeTabela” e o valor igual ao nome da tabela a ser buscada (ex.: TGFPAR);
* a segunda com o nome de “PESQUISA” e seu valor igual a “TRUE”.

![690](https://files.readme.io/e1c9765-02.jpeg "02.jpeg")

## Check Box

Nesse caso, o parâmetro será apresentado na forma de um check box (caixa de seleção).\
Para exibi-lo é bem fácil. Na mesma janela de propriedades do parâmetro, simplesmente defina este como um valor booleano. Nesses casos, deve-se definir um valor padrão como falso para quando o check box não estiver marcado.

![876](https://files.readme.io/1286682-03.png "03.png")

![260](https://files.readme.io/7f5b630-04.png "04.png")

## Parâmetro Não Obrigatório

O parâmetro não obrigatório não é requerido a passagem de um valor para ele. Todos os parâmetros definidos no iReport com a opção Use As Prompt o sistema interpretá-lo-á como obrigatório. Porém, se essa opção for desmarcada, ela simplesmente não será exibida para ser preenchida. Portanto, para que o sistema interprete um parâmetro como não obrigatório, é necessário deixar a opção Use as Prompt marcada e definir um valor padrão como null.

![262](https://files.readme.io/890787c-05.png "05.png")

## Drop-down

O menu drop-down é um elemento no qual exibe uma caixa de texto que ao selecioná-lo, essa caixa exibe uma lista de opções que podem ser selecionadas abaixo dela.

![690](https://files.readme.io/fb21424-06.png "06.png")

Para configurar um menu drop-down, na caixa de propriedades do parâmetro no iReport, é necessário definir duas propriedades: a primeira é o TYPE e o seu valor deve ser I; a segunda é com o nome NOMECAMPO e o seu valor deve ser igual à tabela e o campo com os valores que serão exibidos no formato TABELA.CAMPO.

![342](https://files.readme.io/a4cbb0c-07.png "07.png")

## Data

Por fim, para o sistema exibir o parâmetro com uma seleção de datas por um calendário, basta simplesmente definir o tipo do parâmetro como TimeStamp.

![319](https://files.readme.io/e8cd939-08.png "08.png")

![268](https://files.readme.io/e0c342c-09.png "09.png")

## Como tirar dúvidas?

Para tirar suas dúvidas e compartilhar informações, use a sala [Relatórios Formatados](https://comunidade.sankhya.com.br/c/personalizacoes/relatorios-formatados/22) da comunidade Sankhya Developer.

**Contribuição:** Felipe Salles Lopes