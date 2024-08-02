#!/bin/bash

# Informações do usuário e do projeto
USER_NAME="Marcio Freitas"
USER_EMAIL="msfreitas@tre-ba.jus.br"
PROJECT_NAME="auto_candex"
DATE=$(date +'%d/%m/%Y')

# Função para validar o formato da data
validate_date_format() {
    date_input=$1
    if [[ $date_input =~ ^([0-9]{2})-([0-9]{2})-([0-9]{4})$ ]]; then
        return 0
    else
        return 1
    fi
}

# Solicita e valida a data de início do relatório
while true; do
    echo "Por favor, insira a data de início do relatório (formato dd-mm-YYYY):"
    read START_DATE
    if validate_date_format "$START_DATE"; then
        break
    else
        echo "Formato de data inválido. Por favor, tente novamente."
    fi
done

# Solicita e valida a data de fim do relatório
while true; do
    echo "Por favor, insira a data de fim do relatório (formato dd-mm-YYYY):"
    read END_DATE
    if validate_date_format "$END_DATE"; then
        break
    else
        echo "Formato de data inválido. Por favor, tente novamente."
    fi
done

# Extrai o mês e o ano da data de início para o nome do arquivo
START_MONTH=$(echo "$START_DATE" | cut -d'-' -f2)
START_YEAR=$(echo "$START_DATE" | cut -d'-' -f3)
PERIOD="$START_MONTH-$START_YEAR"

# Cria o diretório 'evidencias' na raiz do projeto se não existir
OUTPUT_DIR="$PWD/evidencias"
mkdir -p "$OUTPUT_DIR"

# Obtém a lista de autores únicos no repositório
IFS=$'\n' read -rd '' -a authors < <(git log --format='%aN' | sort -u)

# Lista os autores e solicita que o usuário escolha um
echo "Selecione o número do usuário para gerar o relatório de commits:"
for i in "${!authors[@]}"; do
    echo "[$i] ${authors[$i]}"
done
read -p "Digite o número correspondente ao usuário: " USER_INDEX
SELECTED_USER="${authors[$USER_INDEX]}"

# Nome do arquivo de saída
OUTPUT_FILE="$OUTPUT_DIR/evidencias - $PROJECT_NAME - $PERIOD.txt"

# Cabeçalho do relatório
echo "Relatório de Commits - Projeto: $PROJECT_NAME" > "$OUTPUT_FILE"
echo "Período: $START_DATE a $END_DATE" >> "$OUTPUT_FILE"
echo "Data de Geração: $DATE" >> "$OUTPUT_FILE"
echo "Autor: $USER_NAME" >> "$OUTPUT_FILE"
echo "E-mail: $USER_EMAIL" >> "$OUTPUT_FILE"
echo "Usuário selecionado: $SELECTED_USER" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Salva a branch atual para retornar depois
current_branch=$(git branch --show-current)

# Lista todas as branches
branches=$(git branch --all | grep -v remotes | sed 's/\*//g' | sed 's/remotes\/origin\///g')

# Flag para verificar se houve commits no período
has_commits=false

# Gera relatório para cada branch
for branch in $branches; do
    # Faz checkout para a branch
    git checkout $branch

    # Coleta o log de commits
    commits=$(git log --since="$START_DATE" --until="$END_DATE" --author="$SELECTED_USER" --pretty=format:"%ad - %h : %s" --date=format:'%d/%m/%Y')

    # Verifica se há commits
    if [ -n "$commits" ]; then
        has_commits=true
        # Adiciona o nome da branch no relatório
        echo "Branch: $branch" >> "$OUTPUT_FILE"
        echo "=====================" >> "$OUTPUT_FILE"
        echo "$commits" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo "---------------------" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"

        echo "Relatório de commits da branch '$branch' adicionado ao relatório único."
    fi
done

# Se não houver commits no período, adiciona uma mensagem ao relatório
if [ "$has_commits" = false ]; then
    echo "Não há commits no período de $START_DATE a $END_DATE para o usuário $SELECTED_USER." >> "$OUTPUT_FILE"
fi

# Volta para a branch original
git checkout "$current_branch"

# Mensagem final informando o local do arquivo
echo "Relatório único gerado e salvo em: $OUTPUT_FILE"
