# Hotmart Data Lakehouse Project

## Descrição do Projeto

Este projeto implementa um data lakehouse utilizando a arquitetura medalhão (Bronze, Silver, Gold) para processar e analisar dados de eventos de produtos e compras da plataforma Hotmart. O processamento é orquestrado em camadas, começando pela ingestão de dados brutos (Bronze), seguido pela limpeza e transformação (Silver), e finalizando com agregações analíticas (Gold). A solução utiliza Apache Spark com Delta Lake para garantir versionamento, rastreabilidade e imutabilidade dos dados.

O projeto aborda cenários reais com possíveis inconsistências nos dados (como valores faltantes) e implementa estratégias para lidar com atualizações incrementais, garantindo que o passado não seja alterado mesmo em reprocessamentos completos.

## Arquitetura Medalhão

### Bronze Layer
- **Propósito**: Ingestão de dados brutos diretamente das fontes de eventos.
- **Características**: Dados são armazenados no formato original, sem transformações significativas. Inclui tratamento básico de inconsistências.
- **Tabelas**:
  - `product_item`: Dados de itens de produtos.
  - `purchase`: Dados de compras.
  - `purchase_extra_info`: Informações extras sobre compras.

### Silver Layer
- **Propósito**: Limpeza, normalização e enriquecimento dos dados.
- **Características**: Dados são validados, duplicatas removidas, tipos de dados padronizados e relacionamentos estabelecidos.
- **Tabelas**:
  - `product_item`: Dados limpos de itens de produtos.
  - `purchase`: Dados limpos de compras.
  - `purchase_extra_info`: Informações extras limpas.

### Gold Layer
- **Propósito**: Agregações e métricas analíticas prontas para consumo.
- **Características**: Dados agregados por dimensões como tempo, produto, etc., otimizados para consultas rápidas.
- **Tabelas**:
  - `gvm` (Gross Value Metric?): Métricas agregadas finais.

## Pré-Requisitos e Critérios de Implementação

### Interpretação dos Dados
- Os dados das tabelas de eventos (`product_item`, `purchase`, `purchase_extra_info`) representam transações reais e devem ser interpretados considerando possíveis inconsistências como dados faltantes, duplicatas ou formatos inconsistentes.

### Tratamento de Inconsistências
- A solução deve ser robusta para lidar com dados faltantes, valores nulos ou inválidos, aplicando imputações ou filtros apropriados conforme necessário.

### Gatilhos de Atualização
- Todas as tabelas são gatilhos para atualização da tabela final (Gold).
- Se uma tabela foi atualizada e as demais não, os dados ativos das demais tabelas devem ser repetidos para manter consistência temporal.

### Atualização Incremental
- As atualizações ocorrem em D-1 (dia anterior), processando apenas dados novos ou modificados.
- A modelagem garante imutabilidade do passado: reprocessamentos completos não alteram dados históricos.

### Navegação Temporal
- Usuários devem poder consultar valores históricos de forma consistente. Por exemplo, o valor de janeiro/2023 consultado em 31/03/2023 deve ser diferente do valor consultado hoje, refletindo apenas as atualizações até aquela data.
- Implementação via versionamento do Delta Lake, permitindo time travel.

### Rastreabilidade Diária
- Todos os processos devem registrar logs diários para rastreabilidade, incluindo timestamps de processamento e versões dos dados.

### Particionamento
- As tabelas são particionadas por `transaction_date` para otimizar consultas e processamento incremental.

### Recuperação de Registros Correntes
- Deve ser fácil identificar e recuperar os registros mais atuais da base histórica, utilizando colunas de controle como `effective_date` ou flags de versão.

### Linguagem de Programação
- Preferencialmente Python com Apache Spark (PySpark), Scala ou Spark SQL.

## Tecnologias Utilizadas

- **Apache Spark**: Processamento distribuído de dados.
- **Delta Lake**: Versionamento, ACID transactions e time travel.
- **Docker**: Containerização do ambiente Spark.
- **Python**: Linguagem principal para scripts e notebooks.
- **Jupyter Notebooks**: Desenvolvimento e documentação dos processos (pasta `Estudos`).

## Estrutura do Projeto

```
Hotmart-AndreLamounier/
├── Dockerfile                    # Configuração do container Spark
├── docker-compose.yml           # Orquestração de serviços
├── jars/                        # JARs adicionais (se necessário)
├── workspace/                   # Dados processados
│   ├── data_lake/
│   │   ├── bronze/              # Dados brutos
│   │   ├── silver/              # Dados transformados
│   │   └── gold/                # Dados agregados
│   └── spark-warehouse/         # Metastore Spark
├── Estudos/                     # Notebooks de desenvolvimento
│   ├── Bronze_Product-Item.ipynb
│   ├── Bronze_Purchase-Extra-Info.ipynb
│   ├── Bronze_Purchase.ipynb
│   ├── Silver_Product-Item.ipynb
│   ├── Silver_Purchase-Extra-Info.ipynb
│   ├── Silver_Purchase.ipynb
│   └── Gold_GVM.ipynb
└── README.md                    # Esta documentação
```

## Instalação e Configuração

### Pré-requisitos do Sistema
- Docker e Docker Compose instalados.
- Pelo menos 4GB de RAM disponível para o container Spark.

### Configuração do Ambiente
1. Clone ou navegue para o diretório do projeto.
2. Execute `docker compose up -d` para iniciar o container Spark.
3. Acesse o container via `docker exec -it <container_id> bash` ou utilize Jupyter para os notebooks.

### Dependências
- OpenJDK 17
- Apache Spark 3.4.1 com Hadoop 3
- Delta Lake 2.4.0
- Python 3 com bibliotecas: delta-spark, pyspark

## Como Executar

### Orquestramento
1. **Bronze Layer**: Execute os notebooks Bronze em ordem (Product-Item, Purchase, Purchase-Extra-Info).
2. **Silver Layer**: Após Bronze, execute os notebooks Silver correspondentes.
3. **Gold Layer**: Após Silver, execute o notebook Gold_GVM.

### Scripts de Produção
- Desenvolva scripts Python/Scala baseados nos notebooks para execução automatizada.
- Utilize ferramentas como Apache Airflow ou cron jobs para orquestração diária em D-1.

### Exemplo de Comando
```bash
# Dentro do container
spark-submit --packages io.delta:delta-core_2.12:2.4.0 bronze_product_item.py
```

## Estrutura de Dados

### Tabelas Bronze
- **product_item**: Colunas como `product_id`, `item_id`, `transaction_date`, etc.
- **purchase**: Colunas como `purchase_id`, `user_id`, `transaction_date`, etc.
- **purchase_extra_info**: Colunas adicionais relacionadas a compras.

### Tabelas Silver
- Mesmas tabelas com dados limpos, normalizados e enriquecidos.
- Adição de colunas de controle: `processed_date`, `version`.

### Tabelas Gold
- **gvm**: Agregações como soma de valores por período, produto, etc.
- Colunas: `date`, `product_id`, `total_value`, `version`.

## Considerações de Implementação

- **Versionamento**: Utilize Delta Lake para commits versionados.
- **Time Travel**: Consultas históricas via `SELECT * FROM table VERSION AS OF X`.
- **Incremental Processing**: Use `MERGE` statements para upserts.
- **Qualidade de Dados**: Implemente validações e logs de qualidade.
- **Performance**: Otimize com particionamento e cache quando necessário.

## Contribuição
- Desenvolva nos notebooks da pasta `Estudos`.
- Teste mudanças no ambiente Docker.
- Documente alterações neste README.

## Licença
Este projeto é para fins educacionais e de demonstração.