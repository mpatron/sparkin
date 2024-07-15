# builder step used to download and configure spark environment
FROM openjdk:11.0.11-jre-slim-buster as builder

# Add Dependencies for PySpark
RUN apt-get update && apt-get install -yqq curl vim wget software-properties-common ssh net-tools ca-certificates python3 python3-pip
RUN apt-get install -yqq python3-numpy python3-matplotlib  python3-scipy python3-pandas python3-simpy
# RUN apt-get install -yqq build-essential zlib1g-dev
# RUN python3 -m pip install numpy matplotlib scipy pandas simpy
# python3 -m pip install --upgrade numpy matplotlib scipy pandas simpy

RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1

# Fix the value of PYTHONHASHSEED
# Note: this is needed when you use Python 3.3 or greater
ENV SPARK_VERSION=3.3.1 \
HADOOP_VERSION=3 \
SPARK_HOME=/opt/spark \
PYTHONHASHSEED=1

# Download and uncompress spark from the apache archive
# RUN wget --no-verbose -O apache-spark.tgz "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" \
# && mkdir -p /opt/spark \
# && tar -xf apache-spark.tgz -C /opt/spark --strip-components=1 \
# && rm apache-spark.tgz
RUN wget -O apache-spark.tgz "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"
RUN mkdir -p /opt/spark
RUN tar -xf apache-spark.tgz -C /opt/spark --no-same-owner --strip-components=1
RUN rm apache-spark.tgz

# Apache spark environment
FROM builder as apache-spark

WORKDIR /opt/spark

ENV SPARK_MASTER_PORT=7077 \
SPARK_MASTER_WEBUI_PORT=8080 \
SPARK_LOG_DIR=/opt/spark/logs \
SPARK_MASTER_LOG=/opt/spark/logs/spark-master.out \
SPARK_WORKER_LOG=/opt/spark/logs/spark-worker.out \
SPARK_WORKER_WEBUI_PORT=8080 \
SPARK_WORKER_PORT=7000 \
SPARK_MASTER="spark://spark-master:7077" \
SPARK_WORKLOAD="master"

EXPOSE 8080 7077 7000 6066

RUN mkdir -p $SPARK_LOG_DIR && \
touch $SPARK_MASTER_LOG && \
touch $SPARK_WORKER_LOG && \
ln -sf /dev/stdout $SPARK_MASTER_LOG && \
ln -sf /dev/stdout $SPARK_WORKER_LOG

COPY start-spark.sh /

CMD ["/bin/bash", "/start-spark.sh"]
