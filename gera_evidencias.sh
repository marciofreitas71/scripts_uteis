#!/bin/bash

# Informações do usuário e do projeto
USER_NAME="Seu Nome"
USER_EMAIL="seuemail@example.com"
PROJECT_NAME=$(basename "$PWD")
DATE=$(date +'%d/%m/%Y')

# Cria o diretório 'evidencias' na raiz do projeto se não existir
OUTPUT_DIR="$PWD/evidencias"
mkdir -p "$OUTPUT_DIR"

# Nome do arquivo de saída
OUTPUT_FILE="$OUTPUT_DIR/evidencias - $PROJECT_NAME - $(date +'%d-%m-%Y').txt"

# Cabeçalho do relatório
echo "Relatório de Commits - Projeto: $PROJECT_NAME" > "$OUTPUT_FILE"
echo "Data de Geração: $DATE" >> "$OUTPUT_FILE"
echo "Autor: $USER_NAME" >> "$OUTPUT_FILE"
echo "E-mail: $USER_EMAIL" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Salva a branch atual para retornar depois
current_branch=$(git branch --show-current)

# Lista todas as branches
branches=$(git branch --all | grep -v remotes | sed 's/\*//g' | sed 's/remotes\/origin\///g')

# Gera relatório para cada branch
for branch in $branches; do
    # Faz checkout para a branch
    git checkout $branch

    # Adiciona o nome da branch no relatório
    echo "Branch: $branch" >> "$OUTPUT_FILE"
    echo "=====================" >> "$OUTPUT_FILE"

    # Coleta o log e adiciona no arquivo, incluindo a data, hash reduzido, e mensagem do commit
    git log --pretty=format:"%ad - %h : %s" --date=format:'%d/%m/%Y' >> "$OUTPUT_FILE"

    # Adiciona uma linha em branco para separar os logs de diferentes branches
    echo "" >> "$OUTPUT_FILE"
    echo "---------------------" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    echo "Relatório de commits da branch '$branch' adicionado ao relatório único."
done

# Volta para a branch original
git checkout "$current_branch"

# Mensagem final informando o local do arquivo
echo "Relatório único gerado e salvo em: $OUTPUT_FILE"
