---
fetchedAt: 2026-08-20
source: https://developer.sankhya.com.br/docs/04_dashboard.md
---

Fetch the complete documentation index at: https://developer.sankhya.com.br/llms.txt. Use this file to discover all available pages before exploring further. Append .md to any documentation page URL to get its markdown version.

# 📊 Dashboards Embarcados

Guia para criar dashboards customizados na interface do Sankhya.

> 📘 **Disponibilidade**: Funcionalidade disponível a partir da versão 2.0 do Add-on Studio.

Agora, é possível inserir os arquivos dos dashboards exportados do Sankhya Om para o Addon Studio. Essa nova funcionalidade permite que o dashboard seja incorporado à estrutura do addon, facilitando sua manutenção e instalação no ambiente do cliente. Para embarcar o seu dashboard no Addon Studio, siga os passos abaixo.

> 🚧 ATENÇÃO
>
> A versão mínima do Sankhya Om que suportará o dashboard contextualizado no addon é a 4.35b44.

## **Criação e Exportação do XML do Dashboard no Sankhya Om**

Primeiro, é necessário criar e exportar o arquivo XML do dashboard no Sankhya Om. Caso ainda não tenha conhecimento de como criar um dashboard siga as instruções no link:

Após exportar o dashboard para o seu computador, descompacte o arquivo .zip. Dentro dele, você encontrará um arquivo chamado **`dashboardMetadata.xml`**. Mova esse arquivo para dentro da pasta **`dashboards`** no Addon Studio, conforme exemplo abaixo:

<Image align="center" src="https://files.readme.io/90216d57f4dafe3d1afddb95c98a5af6b7de84db91ea9201b1b028cd87429f67-dash.png" />

<br />

> ❗️ Importante
>
> Caso queira adicionar mais dashboards ao seu addon, é necessário que você renomeei o arquivo do dashboard gerado pelo Sankhya.

## **Criando um Menu ou uma NativeFolder no diretório datadictionary**

Para que seu dashboard seja apresentado como uma tela no Sankhya, é necessário criar um **`menu`** ou uma **`nativeFolder`** dentro do diretório **`datadictionary`**, referenciando o arquivo do dashboard. Se houver uma hierarquia de pastas (component folder) dentro do menu ou da nativeFolder, o dashboard pode ser organizado e  referenciado dentro dessas pastas, conforme o exemplo abaixo:

```xml
<?xml version="1.0" encoding="iso-8859-1" ?>
<metadados xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:noNamespaceSchemaLocation="../.gradle/metadados.xsd">

   <menu id="dash" description="Dashboard" icon="/$ctx/assets/icon_2.png">
       <dashboard id="1" file="dashboardMetadata.xml" description="Dashboard Teste 1"/>
       <folder id="folder" description="Dashboards">
           <dashboard id="2" file="dashboard3" description="Dashboard Teste 2"/>
       </folder>
   </menu>
   <nativeFolder name="CONFIGURACOES_CADASTROS">
       <dashboard id="3" file="dashboardMetadata2.xml" description="Dashboard Teste 3"/>
   </nativeFolder>

</metadados>
```

Na tag **`<dashboard>`** temos alguns atributos:

* **id:** Identificador único do seu dashboard. Deve **ser único** para cada dashboard.
* **file:** Caminho que referencia o arquivo XML do dashboard dentro do diretório **`dashboards`**.
  * **Exemplo:** minhapasta/dash1.xml
* **description:** Descrição do dashboard que será exibida na tela do **Sankhya**.

**Observações importantes:**

* O atributo **'id'** da tag \<dashboard>, é único para cada dashboard. Não recomendamos a alteração deste ID APÓS o dashboard ter sido instalado em seu cliente. A alteração deste, traria a necessidade de novas liberações de acesso, afinal, ao mudar o ID, o Sankhya OM entende este item de menu/lançador como algo novo. Portanto, nossa recomendação é que os IDs sejam números, e que a medida em que mais dashboards forem criados, você apenas incremente o próximo ID (nunca editando o ID dos antigos). O Dashboard criado não aparecerá na tela Construtor de Dashboards.
* O ID final do dashboard é um hash, computado em tempo de compilação. É importante que você tenha ciência disso, pois você pode, e vai encontrar nos metadados um ID diferente do que você informou nos metadados. Não se preocupe com isso!

## **Efetuando o deploy do addon**

Após configuração do menu ou da nativeFolder com o seu dashboard, execute o comando abaixo:

```shell
./gradlew clean deployAddon
```

Ao deployar o addon, verifique se seu dashboard foi processado, acessando o menu no Sankhya Om, no ícone , conforme exemplo abaixo:

![](https://files.readme.io/2d344e06832370c4f03d56631ca5645f056524ee415f4f386859a115ce57ff99-image.png)

<br />

Dessa forma você conseguirá testar a funcionalidade dos dashs embarcados no seu addon.

![](https://files.readme.io/df9ced767f7965e9ec2201d38f8f8ba7e02c66a77918e975163164ff5913f7b1-image.png)
