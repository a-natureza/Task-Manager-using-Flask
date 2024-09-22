#!/bin/bash

# Função para logar erros
log_error() {
    echo "Erro: $1"
    echo "Código HTTP: $2"
    exit 1
}

# Testar a conexão com OWASP ZAP
curl -s -o /dev/null "http://localhost:8090/JSON/spider/view/status/"
if [ $? -ne 0 ]; then
    log_error "OWASP ZAP não está acessível." "N/A"
fi

# Iniciar o spidering para o alvo
response=$(curl -s -w "%{http_code}" -o /dev/null "http://localhost:8090/JSON/spider/action/scan/?url=http://127.0.0.1:5000&maxChildren=10")
if [[ "$response" == "200" ]]; then
    echo "Spidering iniciado com sucesso."
else
    log_error "Falha ao iniciar o spidering." "$response"
fi

# Esperar o spidering terminar
echo "Esperando o spidering terminar..."

# Iniciar o spidering para a sua aplicação Flask
response=$(curl -s "http://localhost:8090/JSON/spider/action/scan/?url=http://127.0.0.1:5000&maxChildren=10")
if [[ "$response" == *'"result":"OK"'* ]]; then
  echo "Spidering iniciado com sucesso."
else
  echo "Falha ao iniciar o spidering."
  echo "Código HTTP: $response"
  exit 1
fi

# Esperar o spidering terminar
echo "Esperando o spidering terminar..."
for i in {1..60}; do
  status=$(curl -s "http://localhost:8090/JSON/spider/view/status/")
  if [[ "$status" == *'"status":"0"'* ]]; then
    echo "Spidering concluído."
    break
  fi
  echo "Spidering em andamento..."
  sleep 10
done

if [[ "$status" != *'"status":"0"'* ]]; then
  echo "Spidering não completou dentro do tempo limite."
  exit 1
fi

# Iniciar o scan ativo
response=$(curl -s "http://localhost:8090/JSON/ascan/action/scan/?url=http://127.0.0.1:5000")
if [[ "$response" == *'"result":"OK"'* ]]; then
  echo "Scan ativo iniciado com sucesso."
else
  echo "Falha ao iniciar o scan ativo."
  exit 1
fi

# Esperar o scan ativo terminar
echo "Esperando o scan ativo terminar..."
for i in {1..60}; do
  progress=$(curl -s "http://localhost:8090/JSON/ascan/view/status/")
  if [[ "$progress" == *'"status":"0"'* ]]; then
    echo "Scan ativo concluído."
    break
  fi
  echo "Scan ativo em andamento..."
  sleep 10
done

if [[ "$progress" != *'"status":"0"'* ]]; then
  echo "Scan ativo não completou dentro do tempo limite."
  exit 1
fi
