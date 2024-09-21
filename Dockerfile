# Imagem base
FROM python:3.9-slim

# Definir o diretório de trabalho
WORKDIR /app

# Copiar o arquivo de requisitos e instalar dependências
COPY requirements.txt requirements.txt
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*  # Limpar listas para reduzir o tamanho da imagem

RUN pip install --no-cache-dir -r requirements.txt  # Usar --no-cache-dir para não armazenar em cache as dependências

# Copiar o código-fonte da pasta todo_project para /app
COPY todo_project/ /app/todo_project

# Expor a porta que a aplicação utilizará
EXPOSE 5000

# Healthcheck para monitorar a saúde do container
HEALTHCHECK CMD curl --fail http://localhost:5000/health || exit 1

# Definir a variável de ambiente FLASK_APP
ENV FLASK_APP=/app/todo_project/run.py

# Comando para executar a aplicação
CMD ["python", "todo_project/run.py"]

ENV JAVA_OPTS="-Xmx1024m"
