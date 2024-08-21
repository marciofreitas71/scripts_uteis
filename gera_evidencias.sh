#!/bin/bash

# Obtém o nome do usuário e e-mail configurados no Git
DEFAULT_USER_NAME=$(git config user.name)
DEFAULT_USER_EMAIL=$(git config user.email)

# Caso as variáveis estejam vazias, tenta obter do Git global
if [ -z "$DEFAULT_USER_NAME" ]; then
    DEFAULT_USER_NAME=$(git config --global user.name)
fi

if [ -z "$DEFAULT_USER_EMAIL" ]; then
    DEFAULT_USER_EMAIL=$(git config --global user.email)
fi

# Informações do projeto e data atual
DEFAULT_PROJECT_NAME="nome_do_projeto"
DATE=$(date +'%d/%m/%Y')

# Solicita os dados do usuário, utilizando valores padrão, mas permitindo edição
read -p "Digite o nome do usuário [$DEFAULT_USER_NAME]: " USER_NAME
USER_NAME=${USER_NAME:-$DEFAULT_USER_NAME}

read -p "Digite o e-mail do usuário [$DEFAULT_USER_EMAIL]: " USER_EMAIL
USER_EMAIL=${USER_EMAIL:-$DEFAULT_USER_EMAIL}

read -p "Digite o nome do projeto [$DEFAULT_PROJECT_NAME]: " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-$DEFAULT_PROJECT_NAME}

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

# Abre uma janela para selecionar a pasta do projeto
PROJECT_DIR=$(zenity --file-selection --directory --title="Selecione a pasta do projeto")

if [ -z "$PROJECT_DIR" ]; then
    echo "Nenhuma pasta selecionada. Saindo..."
    exit 1
fi

cd "$PROJECT_DIR" || { echo "Falha ao acessar a pasta do projeto. Saindo..."; exit 1; }

# Extrai o mês e o ano da data de início para o nome do arquivo
START_MONTH=$(echo "$START_DATE" | cut -d'-' -f2)
START_YEAR=$(echo "$START_DATE" | cut -d'-' -f3)
PERIOD="$START_MONTH-$START_YEAR"

# Cria o diretório 'evidencias' na raiz do projeto se não existir
OUTPUT_DIR="$PWD/evidencias"
mkdir -p "$OUTPUT_DIR"

# Obtém a lista de autores únicos no repositório
IFS=$'\n' read -rd '' -a authors < <(git log --format='%aN' | sort -u)

# Adiciona a opção de todos os usuários
authors+=("Todos os Usuários")

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

    # Coleta o log de commits de acordo com o usuário selecionado
    if [ "$SELECTED_USER" = "Todos os Usuários" ]; then
        commits=$(git log --since="$START_DATE" --until="$END_DATE" --reverse --pretty=format:"%ad - %an : %s" --date=format:'%d/%m/%Y')
    else
        commits=$(git log --since="$START_DATE" --until="$END_DATE" --reverse --author="$SELECTED_USER" --pretty=format:"%ad - %h : %s" --date=format:'%d/%m/%Y')
    fi

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
