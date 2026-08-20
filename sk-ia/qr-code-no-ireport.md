---
updatedAt: 2025-11-10T23:37:37.000Z
---

Fetch the complete documentation index at: https://developer.sankhya.com.br/llms.txt. Use this file to discover all available pages before exploring further. Append .md to any documentation page URL to get its markdown version.

# QRCode no iReport

Embora seja possível criar uma etiqueta que contenha **“QRCODE**” no iReport, será necessário adicionar “Variáveis” para que a inserção de “QRCODE” fique disponível no Layout.

## Instalando as extensões

Baixar as extensões nos links abaixo e salve os arquivos no caminho abaixo:\
**C:\iReport-4.0.1\ide10\modules**

<HTMLBlock>{`
<div class="center">
 <a class="button_background button_size"
                    href="https://drive.google.com/file/d/1wicce9w-GOUIby-iv38cK2mJcmXXBFWp/view?usp=sharing" target=blank_
                    rel="noopener noreferrer">Download javase-2.2.jar</a>
</div>

<style>
    
    .center {
       display: flex;
       justify-content: center;
       align-items: center;
       height: 100px;
   }
  
   .button_size {
       background-color: #4CAF50;
  		 border: none;
  		 color: white;
       padding: 15px 32px;
       text-align: center;
       text-decoration: none !important;
       display: inline-block;
       font-size: 16px;
       margin: 4px 2px;
       cursor: pointer;
       box-shadow: 0 8px 16px 0 rgba(0,0,0,0.2), 0 6px 20px 0 rgba(0,0,0,0.19);

    }

    .button_background {
        background-color: #66cc66;
        color: #fff !important;
    }

</style>
`}</HTMLBlock>

<HTMLBlock>{`
<div class="center">
 <a class="button_background button_size"
                    href="https://drive.google.com/file/d/1H4nt4pM-9jsgzIbfR_w7wJuLgTyKIDrR/view?usp=sharing" target=blank_
                    rel="noopener noreferrer">Download core-2.2.jar</a>
</div>

<style>
    
    .center {
       display: flex;
       justify-content: center;
       align-items: center;
       height: 100px;
   }
  
   .button_size {
       background-color: #4CAF50;
  		 border: none;
  		 color: white;
       padding: 15px 32px;
       text-align: center;
       text-decoration: none !important;
       display: inline-block;
       font-size: 16px;
       margin: 4px 2px;
       cursor: pointer;
       box-shadow: 0 8px 16px 0 rgba(0,0,0,0.2), 0 6px 20px 0 rgba(0,0,0,0.19);

    }

    .button_background {
        background-color: #66cc66;
        color: #fff !important;
    }

</style>
`}</HTMLBlock>

## Configurando as variáveis para "QRCODE"

Abra o aplicativo iReport e vá em “Ferramentas » Opções » Classpath” e adicione os arquivos através do botão **“Add JAR”** e clique em **“OK”** para salvar:

![1241](https://files.readme.io/5f93e05-img1.jpg "img1.jpg")

## Criando um relatório simples

Crie um relatório e delete todas as bandas, deixando somente a band “Detail 1”:

![1160](https://files.readme.io/a3b18e3-img2.jpg "img2.jpg")

## Criando o QR Code

Adicione um elemento do tipo “Imagem” e configure o tamanho desejado. No exemplo, configurei 90 x 90 (Largura x Altura):

![1164](https://files.readme.io/3d93c5a-img3.jpg "img3.jpg")

## Configurando o QR Code

Para que o “QRCODE” seja impresso, insira a expressão abaixo na imagem:

"<http://zxing.org/w/chart?cht=qr&chs=230x230&chld=L&choe=UTF-8&chl="> + java.net.URLEncoder.encode(**$F\{HOMEPAGE})**

![1162](https://files.readme.io/e0484c7-img4.jpg "img4.jpg")

Outro exemplo: br.com.sankhya.util.QRcodeUtil.generate(**$F\{ETIQUETA}**,87,83)

![1156](https://files.readme.io/18e459f-img5.jpg "img5.jpg")

Os dois exemplos são válidos, sendo que o primeiro exemplo busca o QRCODE de domínio público, já o segundo exemplo no site da Sankhya.

> ❗️ Importante
>
> O parâmetro em vermelho, é importante para que retorne um parâmetro automaticamente ou crie um prompt para que seja possível informar o parâmetro ao gerar o relatório.

## Como tirar dúvidas?

Para tirar dúvidas e compartilhar informações, use a sala [Relatórios Formatados](https://comunidade.sankhya.com.br/c/personalizacoes/relatorios-formatados/22) da comunidade Sankhya Developer.

**Contribuição:** Hiária Oliveira