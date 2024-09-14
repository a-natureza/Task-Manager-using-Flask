# Imagem base
FROM python:3.9-slim

# Definir o diretório de trabalho
WORKDIR /app

# Copiar o arquivo de requisitos e instalar dependências
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

# Copiar o código-fonte
COPY . .

# Expor a porta que a aplicação utilizará
EXPOSE 5000

# Comando para executar a aplicação
CMD ["python", "run.py"]
