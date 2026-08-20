---
fetchedAt: 2026-08-20
source: https://ajuda.sankhya.com.br/hc/pt-br/articles/360045109733-Bancos-de-Dados-Dashboards-no-Sankhya-Om
note: "Extraído manualmente do HTML salvo pelo usuário (ajuda.sankhya.com.br bloqueia fetch automatizado com 403) — sk-docs/sk-ia/Bancos de Dados - Dashboards no Sankhya Om – Sankhya Gestão de Negócios.html"
---

# Bancos de Dados - Dashboards no Sankhya Om

Para a criação de dashboards você pode utilizar gerenciadores de bancos de
dados **externos** ao sistema Sankhya Om: **PostgreSQL, Firebird, DB2 e SQL
Server** (o artigo também traz exemplos de Oracle e MySQL). É necessário
que estejam em suas versões mais recentes.

## Pré-requisito: driver JDBC

Para conectar com o banco externo, o Sankhya Om precisa do driver de
conexão **JDBC** correspondente:
1. Baixar a versão mais recente do driver no site oficial do fabricante do
   banco de dados.
2. Copiar o `.jar` do driver para o servidor, em `$jboss\server\default\lib`.
3. Configurar a conexão em `$jboss\server\default\deploy\mge-ds.xml`
   (arquivo já criado pelo próprio Sankhya Om nesse diretório).

## Estrutura do bloco de datasource (`mge-ds.xml`)

Cada banco externo vira um bloco `<local-tx-datasource>` dentro de
`<datasources>`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<datasources>
  <local-tx-datasource>
    <jndi-name>NOME_ESCOLHIDO</jndi-name>
    <connection-url>URL_DE_CONEXAO</connection-url>
    <driver-class>CLASSE_DO_DRIVER</driver-class>
    <user-name>Usuário</user-name>
    <password>senha</password>
    <exception-sorter-class-name>...</exception-sorter-class-name>
    <new-connection-sql>...</new-connection-sql>
    <min-pool-size>5</min-pool-size>
    <max-pool-size>5</max-pool-size>
    <transaction-isolation>TRANSACTION_READ_COMMITTED</transaction-isolation>
  </local-tx-datasource>
</datasources>
```

> **Ponto mais importante para quem só quer usar isso num Gadget**:
> `<jndi-name>` é um **nome escolhido livremente pelo administrador** (ex.:
> nos exemplos do artigo aparecem `homologaMYSQL`, `homologaPostgresql`) —
> **não precisa ser `MGEDS`**. Esse é exatamente o valor que deve ir no
> atributo `data-source="..."` de um `<expression type="sql"
> data-source="...">` dentro do Gadget XML para consultar aquele banco
> externo em vez do MGEDS nativo. Ver `sankhya-conventions/04-dash-gadget-
> componentes-avancados.md` § "Fontes de dados externas".

## Valores por SGBD (extraídos dos exemplos do artigo)

| Banco | `connection-url` (exemplo) | `driver-class` | Observação |
|---|---|---|---|
| Oracle | `jdbc:oracle:thin:@192.168.0.210:1521:ORCL` | `oracle.jdbc.driver.OracleDriver` | `exception-sorter-class-name = org.jboss.resource.adapter.jdbc.vendor.OracleExceptionSorter`; `new-connection-sql = select 1 from dual` |
| MySQL | `jdbc:mysql://localhost:3306/NOME` | `com.mysql.jdbc.Driver` | — |
| PostgreSQL | `jdbc:postgresql://localhost:5432/postgres` | — | — |
| Firebird | `jdbc:firebirdsql://localhost:3050/C:/...` (ou `jdbc:FirebirdSQL:host:/path/data.fdb`) | driver `jaybird-2.2.4.jar` | Usa `<connection-property name="charSet">ISO8859-1</connection-property>` e `<connection-property name="roleName">ROLE_APP</connection-property>` adicionais; bloco de `<security>` separado com `<user-name>`/`<password>` |
| IBM DB2 | `jdbc:db2://localhost:50000/SAMPLE` (ou `jdbc:db2:SUA_BASE_DE_DADOS`) | — | — |
| SQL Server | `jdbc:sqlserver://localhost` (variante legada: `jdbc:microsoft:sqlserver://localhost:1433`) | `com.microsoft.sqlserver.jdbc.SQLServerDriver` | — |

O artigo repete um segundo conjunto de exemplos ("Criação do Datasource")
por SGBD (Oracle, MySQL, PostgreSQL, MS SQL Server, IBM DB2, Firebird) com
a mesma estrutura, voltado a criação via console administrativo do
Wildfly em vez de edição manual do XML — os valores de `connection-url`
seguem o mesmo padrão da tabela acima.

## Configurações adicionais de pool/validação (bloco completo, Firebird)

```xml
<security>
  <user-name>userdb</user-name>
  <password>passwddb</password>
</security>
<validation>
  <validate-on-match>false</validate-on-match>
  <background-validation>false</background-validation>
</validation>
<timeout>
  <idle-timeout-minutes>1</idle-timeout-minutes>
</timeout>
<statement>
  <share-prepared-statements>false</share-prepared-statements>
</statement>
```
