# Base: OpenJDK 17
FROM eclipse-temurin:17-jdk-jammy

# Instalar dependências
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    bash \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Variáveis de ambiente
ENV SPARK_VERSION=3.4.1
ENV HADOOP_VERSION=3
ENV DELTA_VERSION=2.4.0
ENV SPARK_HOME=/opt/spark
ENV PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH

# Baixar e extrair Spark
RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    tar -xvzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /opt && \
    rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    mv /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} $SPARK_HOME

# Baixar Delta Lake JAR e colocar no Spark jars
RUN wget https://repo1.maven.org/maven2/io/delta/delta-core_2.12/${DELTA_VERSION}/delta-core_2.12-${DELTA_VERSION}.jar \
    -P $SPARK_HOME/jars/

# Instalar delta-spark Python compatível
RUN pip install --no-cache-dir delta-spark==2.4.0

# Diretório de trabalho
WORKDIR $SPARK_HOME

# Comando padrão ao iniciar o container
CMD ["bash"]