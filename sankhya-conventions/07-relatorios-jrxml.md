# Relatórios JRXML (iReport) — convenções e armadilhas

> Este workspace foca em dashboards (`sk-dash`), mas um dashboard complexo
> pode embutir um relatório iReport via componente **IReport** (ver
> `04-dash-gadget-componentes-avancados.md`), então as convenções abaixo
> continuam relevantes. Fonte: `.github/copilot-instructions.md` §
> "Relatórios JRXML — sk-report" e os `.md` de referência salvos em
> `sk-docs/sk-ia/`.

## Padrões obrigatórios (iReport Sankhya)

- Quando o campo retornado pela consulta for `NULL`, exibir `-`:
  ```xml
  <textFieldExpression class="java.lang.String"><![CDATA[$F{CAMPO} == null ? "-" : $F{CAMPO}.toString()]]></textFieldExpression>
  ```
- Quando a consulta não retornar nenhuma linha, o relatório **não deve ser
  exibido** — definir no elemento raiz do JRXML:
  ```xml
  <jasperReport ... whenNoDataType="NoPages">
  ```

## Como descobrir o que uma classe Java compilada da vendor realmente faz

Os JRXML do DANFE (`sk-report/modelo danfe/`, `sk-mge/.../danfe_retrato_4.0/`)
importam classes utilitárias **compiladas** via `<import
value="com.sankhya.util.*"/>` e `<import
value="br.com.sankhya.jasperfuncs.*"/>` (ex.: `DanfeUtils.getFaturas(...)`,
`Funcoes.pdes(...)`). O comportamento delas **não está no jrxml** — só a
chamada. Para saber exatamente o que uma dessas chamadas faz (essencial
antes de alterar/envolver o resultado em qualquer expressão):

1. Localizar o `.class` real dentro dos jars do workspace — **cuidado**: o
   mesmo nome de classe pode existir em pacotes diferentes e ser coisas
   completamente distintas:
   - `com.sankhya.util.DanfeUtils` (usado pelos jrxml via `import
     com.sankhya.util.*`) está em
     `sk-custom/api_sankhya/sanutil-4.35b6.jar` (e variantes em
     `sk-ext/api_sankhya_ext/sanutil.jar`).
   - `br.com.sankhya.modelcore.comercial.DanfeUtils` é uma classe
     **diferente e não relacionada** (facade server-side), já decompilada
     em `sk-mge/mge jar/br/com/sankhya/modelcore/comercial/DanfeUtils.java`
     — **não confundir** ao procurar a lógica de um campo do DANFE.
   - `br.com.sankhya.jasperfuncs.Funcoes` (`Funcoes.pdes(...)`) está em
     `sk-custom/api_sankhya/sanutil-4.35b6.jar`.
2. Extrair o `.class` do jar (jar é um zip; `python -c "import
   zipfile; ..."` quando não há `unzip`/`jar` no PATH).
3. Decompilar com o CFR (Maven Central:
   `https://repo1.maven.org/maven2/org/benf/cfr/0.152/cfr-0.152.jar`):
   ```
   java -jar cfr.jar Caminho\Para\Classe.class --outputdir Caminho\Para\saida
   ```
4. Ler o `.java` gerado — inclusive métodos `private`, que não dá pra saber
   só olhando a assinatura pública.

> Sem decompilar, presumir o comportamento de uma classe vendor pelo
> nome/uso no jrxml é um risco real — caso real: suposição errada sobre o
> rótulo `OUT=` do campo FATURA/DUPLICATA gerou um bug em produção (ver
> caso completo em `.github/copilot-instructions.md`).

## `textFieldExpression` — restrições do compilador de relatórios

**NUNCA usar `new Object() { ... }` (classe anônima) nem `while`/`for`/
blocos de statements dentro de uma `textFieldExpression`.** O compilador de
relatórios do Sankhya (engine antiga, `jasperreports-1.1.0.jar`) compila
cada expressão esperando **uma única classe gerada**; uma classe anônima
produz um `.class` extra que o carregador de classes do Sankhya não sabe
carregar, e a subida do relatório falha:
```
NomeDoRelatorio_1786655344585_930317$1 (wrong name: NomeDoRelatorio_1786655344585_930317)
```
**Alternativa que funciona:** encadear `Funcoes.pdes(...)`/`DanfeUtils.*`/
métodos de `String` dentro de ternários — sem `new`, sem laço. Empurrar
formatação de data/valor para o **SQL** (`CONVERT(...,103)` para
`dd/MM/yyyy`, `REPLACE`/`CAST AS MONEY` para valor) em vez de
`SimpleDateFormat`/`DecimalFormat` em Java, já que não há como declarar
variável local fora de um bloco. Se a lógica realmente precisar de
loop/estado, criar uma **classe Java real, compilada e publicada no
classpath do servidor** — nunca uma classe definida inline na expressão.

## Docs de referência já salvas em `sk-docs/sk-ia/` (todas sobre iReport)

| Arquivo | Conteúdo |
|---|---|
| `boas-praticas-ireport.md` | Boas práticas de SQL/organização de consultas iReport |
| `eventos-de-click-no-ireport.md` | Hyperlink em TextField/série com `refreshDetails`/`openLevel`/`openApp`/`openPage` (também relevante para dashboards — ver `04-dash-gadget-componentes-avancados.md` § Eventos) |
| `funções-utilitárias-em-relatórios-ireport-1.md` | `br.com.sankhya.jasperfuncs.Funcoes.pdes(...)` |
| `propriedades-de-parametros-do-ireport.md` | Propriedades de parâmetro do iReport (busca de entidade, booleano) |
| `qr-code-no-ireport.md` | Extensão para gerar QR Code em etiquetas |

Integração de relatório embutido em dashboard: ver componente **IReport**
em `04-dash-gadget-componentes-avancados.md`.
