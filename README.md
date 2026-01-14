# Hotmart Data Lake Project

## Observações
  Não foi possível configurar, dentro do prazo, o ambiente necessário para utilizar a engine Delta Lake no Spark. Essa seria a abordagem ideal, pois facilitaria a implementação de operações de merge e o gerenciamento incremental dos dados no Data Lake.
  
  Diante dessa limitação, optei por utilizar Parquet como formato de armazenamento das tabelas do Data Lake, simulando os processos de merge por meio de union e deduplicação com window functions.

  Além disso, o cenário ideal incluiria a configuração de um orquestrador, como o Airflow, para explicitar as dependências entre as etapas do pipeline (Bronze → Silver → Gold), controlar execuções incrementais e garantir observabilidade do processo. Neste projeto, apresento apenas a proposta teórica de como essa orquestração poderia ser estruturada, considerando os pré-requisitos definidos.

## Descrição do Projeto

  Este projeto implementa um Data Lake baseado na arquitetura Medalhão (camadas Bronze, Silver e Gold) para processamento e análise de dados de eventos de produtos e compras da plataforma Hotmart. O processamento foi desenvolvido utilizando Apache Spark em ambiente local. 
  A infraestrutura foi configurada com Docker Compose, e o desenvolvimento e execução dos scripts ocorreram por meio de Jupyter Notebook, garantindo reprodutibilidade e isolamento do ambiente.

## Arquitetura Medalhão

### Bronze Layer
- **Propósito**: Ingestão de dados brutos diretamente das fontes de eventos.
- **Características**: Dados são armazenados no formato original, sem transformações significativas, apenas ajuste de schema. Inclui tratamento básico de inconsistências.
- **Escrita**: Incremental
- **Tabelas**:
  - `product_item`: Dados de itens de produtos.
  - `purchase`: Dados de compras.
  - `purchase_extra_info`: Informações extras sobre compras.

### Silver Layer
- **Propósito**: Limpeza, normalização e enriquecimento dos dados.
- **Características**: Dados são validados, duplicatas removidas e tipos de dados padronizados.
- **Lógica**: União da tabela atual com novos dados da bronze em relação a última execução e deduplicação com window functions.
- **Escrita**: Sobrescrita
- **Tabelas**:
  - `product_item`: Dados limpos de itens de produtos.
  - `purchase`: Dados limpos de compras.
  - `purchase_extra_info`: Informações extras limpas.

### Gold Layer
- **Propósito**: Tabela resultante da aplicação das regras de negócio, com dados padronizados e organizados, visando facilitar o uso e a interpretação pelas áreas da empresa.
- **Características**: Construídas a partir de relacionamentos de tabelas da camada silver, agregadas ou analíticas.
- **Tabelas**:
  - `gvm` (Gross Value Metric)

## Estrutura do Projeto

```
Hotmart-AndreLamounier/
├── infra                        # Configuração do container Spark
    ├── Dockerfile               # Configuração do container Spark
    ├── docker-compose.yml       # Orquestração de serviços
├── workspace/                   # Dados processados
│   ├── data_lake/               # Data Lake
│   │   ├── bronze/              # Dados brutos
│   │   ├── silver/              # Dados transformados
│   │   └── gold/                # Dados negócio
│   ├── Notebooks
│     ├── Bronze
│       ├── Bronze_Product-Item.ipynb
│       ├── Bronze_Purchase-Extra-Info.ipynb
│       ├── Bronze_Purchase.ipynb
│     ├── Silver
│       ├── Silver_Product-Item.ipynb
│       ├── Silver_Purchase-Extra-Info.ipynb
│       ├── Silver_Purchase.ipynb
│     ├── Gold
│       └── Gold_GVM.ipynb
└── README.md                    
```

## Instalação e Configuração

### Pré-requisitos do Sistema
- Docker e Docker Compose instalados.
- Pelo menos 4GB de RAM disponível para o container Spark.

### Configuração do Ambiente
1. Clone ou navegue para o diretório do projeto.
2. Acesse a pasta infra e execute:
  2.1 `docker compose build
  2.2 `docker compose up -d` para iniciar o container Spark.
3. Execute `docker compose up -d` para iniciar o container Spark.
4. Acesse o Jupter Notebook em `localhost:8888` - utilizando o `Token`: 1234
5. Acesso o Spark UI em `localhost:4040` (Opcional)


## Orquestração Airflow

1. **Bronze Layer**: As ingestões das tabelas `purchase`, `product_item` e `purchase_extra_info` são independentes entre si e podem ser executadas em paralelo.
2. **Silver Layer**: Cada tabela Silver depende exclusivamente de sua respectiva tabela Bronze.
3. **Gold Layer**: A tabela GMV depende da conclusão de todas as tabelas Silver.

O sequenciamento das tasks no Airflow pode ser representado da seguinte forma:

```python
# Dependências Bronze -> Silver
bronze_purchase >> silver_purchase
bronze_product_item >> silver_product_item
bronze_purchase_extra_info >> silver_purchase_extra_info

# Dependências Silver -> Gold
[
    silver_purchase,
    silver_product_item,
    silver_purchase_extra_info
] >> gold_gvm
yaml
```

## Resultados

