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
- **Tabelas**:
  - `product_item`: Dados de itens de produtos.
  - `purchase`: Dados de compras.
  - `purchase_extra_info`: Informações extras sobre compras.

### Silver Layer
- **Propósito**: Limpeza, normalização e enriquecimento dos dados.
- **Características**: Dados são validados, duplicatas removidas e tipos de dados padronizados.
- **Tabelas**:
  - `product_item`: Dados limpos de itens de produtos.
  - `purchase`: Dados limpos de compras.
  - `purchase_extra_info`: Informações extras limpas.

### Gold Layer
- **Propósito**: Agregações e métricas analíticas prontas para consumo.
- **Características**: construção de visões analíticas e relacionamentos entre entidades, voltados para responder perguntas de negócio.
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
└── README.md                    # Esta documentação
```

## Instalação e Configuração

### Pré-requisitos do Sistema
- Docker e Docker Compose instalados.
- Pelo menos 4GB de RAM disponível para o container Spark.

### Configuração do Ambiente
1. Clone ou navegue para o diretório do projeto.
2. Execute `docker compose up -d` para iniciar o container Spark.
3. Acesse o Jupter Notebook em `localhost:8888` - utilizando o `Token`: 1234
4. Acesso o Spark UI em `localhost:4040`

## Como Executar

### Orquestramento
1. **Bronze Layer**: Execute os notebooks Bronze em ordem (Product-Item, Purchase, Purchase-Extra-Info).
2. **Silver Layer**: Após Bronze, execute os notebooks Silver correspondentes.
3. **Gold Layer**: Após Silver, execute o notebook Gold_GVM.

### Scripts de Produção
- Desenvolva scripts Python/Scala baseados nos notebooks para execução automatizada.
- Utilize ferramentas como Apache Airflow ou cron jobs para orquestração diária em D-1.

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
