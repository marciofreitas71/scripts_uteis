
# Script de Geração de Relatório de Commits

Este script Bash foi desenvolvido para gerar um relatório detalhado de commits realizados em um projeto Git, dentro de um intervalo de datas especificado. Ele permite que você escolha um autor específico ou todos os autores do repositório para incluir no relatório. O relatório é gerado em um arquivo de texto dentro de uma pasta chamada `relatorios_commits`, criada na raiz do projeto.

## Funcionalidades
- **Validação de Data:** O script valida o formato das datas de início e fim do período.
- **Seleção de Usuário:** Permite selecionar um autor específico ou todos os autores para gerar o relatório de commits.
- **Relatório de Commits:** Gera um relatório de commits de todas as branches do repositório dentro do período especificado.
- **Relatório por Branch:** Adiciona o nome da branch ao relatório para identificar os commits.
- **Geração de Arquivo de Saída:** O relatório é salvo em um arquivo de texto com o nome e período especificado.

## Pré-requisitos
- Git instalado e configurado no sistema.
- Acesso a um repositório Git com histórico de commits.
- Shell Bash disponível no ambiente.
- `zenity` instalado para a seleção da pasta do projeto.

## Como Usar

### 1. Clonar o Repositório ou Acessar a Pasta do Projeto
Se você ainda não clonou o repositório onde deseja gerar o relatório de commits, faça isso usando:

```bash
git clone <url-do-repositorio>
```

Depois, navegue até a pasta do projeto:

```bash
cd <nome-da-pasta-do-projeto>
```

### 2. Executar o Script
Certifique-se de que o script está marcado como executável. Se necessário, execute:

```bash
chmod +x gerador_relatorio_commits.sh
```

Em seguida, execute o script:

```bash
./gerador_relatorio_commits.sh
```

### 3. Inserir as Informações
O script solicitará que você insira o nome do usuário, o e-mail e o nome do projeto. Estes dados serão preenchidos com as configurações do Git local (ou global), mas você pode editá-los conforme necessário.

### 4. Inserir as Datas
O script solicitará que você insira a data de início e a data de fim do período para o relatório. As datas devem ser inseridas no formato `dd-mm-YYYY`. O script validará o formato das datas. Se o formato estiver incorreto, você será solicitado a tentar novamente.

### 5. Selecionar o Autor
O script exibirá uma lista de autores únicos encontrados no histórico de commits do repositório. Cada autor será numerado, e você deverá selecionar o número correspondente ao autor desejado. Também é possível selecionar "Todos os Usuários" para incluir todos os commits de todos os autores no período especificado.

### 6. Geração do Relatório
O script processará todas as branches do repositório, coletando os commits realizados no período especificado pelo autor selecionado. Cada branch será processada uma a uma, e os commits serão adicionados ao relatório, identificando a branch correspondente.

Se nenhum commit for encontrado no período, o script informará no relatório.

### 7. Localização do Relatório
Após a execução, o relatório será salvo em um arquivo de texto na pasta `evidencias` na raiz do projeto. O nome do arquivo seguirá o padrão:

```bash
evidencias - <nome_do_projeto> - MM-YYYY.txt
```
Onde `MM-YYYY` representa o mês e o ano da data de início do período selecionado.

### 8. Finalização
No final da execução, o script retornará para a branch original em que estava antes de começar a processar o relatório. Uma mensagem final indicará a localização do arquivo gerado.

## Exemplo de Uso

```bash
./gerador_relatorio_commits.sh
```

## Exemplo de Saída

Ao seguir os passos, você pode gerar um relatório similar ao exemplo abaixo:

```bash
Relatório de Commits - Projeto: nome_do_projeto
Período: 01-08-2023 a 31-08-2023
Data de Geração: 21/08/2024
Autor: Marcio Freitas
E-mail: msfreitas@tre-ba.jus.br
Usuário selecionado: Todos os Usuários

Branch: main
=====================
21/08/2023 - d9b8fd3 : Adiciona função para validação de datas
22/08/2023 - 67c4adf : Corrige bug na seleção de usuários

---------------------

Branch: feature/novafuncionalidade
=====================
24/08/2023 - a23fbc4 : Implementa nova funcionalidade de geração de relatórios
```

## Considerações Finais

Este script é uma ferramenta útil para gerar relatórios de commits de maneira organizada e automatizada. Certifique-se de sempre rodar o script em um repositório Git com histórico válido e use-o para gerar evidências de trabalho realizadas em um determinado período.

Sinta-se à vontade para ajustar ou expandir este README conforme necessário para melhor atender às necessidades do seu projeto.
