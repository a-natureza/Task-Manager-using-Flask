#!/bin/bash

# Defina a URL da API e a chave da API
API_URL="http://localhost:8090"
API_KEY="9ctslp8in9e6a9aq17dssmpbio"

# Iniciar o spidering para o alvo
response=$(curl -s "$API_URL/JSON/spider/action/scan/?url=http://localhost:5000&maxChildren=10&apikey=$API_KEY")
if [[ "$response" == *'"result":"OK"'* ]]; then
    echo "Spidering iniciado com sucesso."
else
    echo "Falha ao iniciar o spidering."
    echo "Resposta: $response"
    exit 1
fi

# Esperar o spidering terminar
echo "Esperando o spidering terminar..."
for i in {1..60}; do
    status=$(curl -s "$API_URL/JSON/spider/view/status/?apikey=$API_KEY")
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
response=$(curl -s "$API_URL/JSON/ascan/action/scan/?url=http://localhost:5000&apikey=$API_KEY")
if [[ "$response" == *'"result":"OK"'* ]]; then
    echo "Scan ativo iniciado com sucesso."
else
    echo "Falha ao iniciar o scan ativo."
    echo "Resposta: $response"
    exit 1
fi

# Esperar o scan ativo terminar
echo "Esperando o scan ativo terminar..."
for i in {1..60}; do
    progress=$(curl -s "$API_URL/JSON/ascan/view/status/?apikey=$API_KEY")
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
