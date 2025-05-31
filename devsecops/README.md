# Automatizando a Instalação de Agentes de Segurança na AWS com Terraform e Systems Manager

Este README detalha o processo de provisionamento de instâncias Amazon EC2 e a subsequente instalação automatizada de um agente de segurança, utilizando Terraform para a infraestrutura como código e AWS Systems Manager para o gerenciamento de configuração e execução de comandos.

## Visão Geral do Projeto

O objetivo é demonstrar uma abordagem DevSecOps para garantir que instâncias recém-provisionadas tenham agentes de segurança instalados automaticamente, com notificação do processo.

## Pré-requisitos

*   Conta AWS ativa.
*   AWS CLI configurada (opcional, pois usaremos o Cloud Shell).
*   Visual Studio Code (ou editor de sua preferência).

## Parte 1: Configuração e Provisionamento com Terraform

### 1.1. Preparação do Ambiente de Desenvolvimento 

1.  **Instale o Visual Studio Code (Opcional):**
    *   Baixe em: [https://code.visualstudio.com/download](https://code.visualstudio.com/download)
2.  **Instale Extensões Recomendadas no VSCode (Opcional):**
    *   `Terraform` (da HashiCorp)
    *   `Material Icon Theme`
    *   `Prettier - Code formatter`
3.  **Obtenha os Arquivos do Projeto Terraform:**
    *   Faça o download do arquivo ZIP contendo os arquivos base `main.tf` e `provider.tf`:
        ```
        https://github.com/phillrog/aws-projetos/blob/main/devsecops/scripts/terraform-scripts.zip
        ```
    *   Descompacte este arquivo em um diretório local.

### 1.2. Configuração dos Arquivos Terraform

1.  Abra o diretório do projeto no VSCode.
2.  Edite os arquivos `main.tf` e `provider.tf` conforme necessário com os dados dos componentes na AWS.
    *   **Observação:** Para este projeto, o uso da VPC e Subnet padrão da sua conta AWS.
        *   `main.tf`: Define os recursos AWS a serem criados (ex: instâncias EC2).
        *   `provider.tf`: Configura o provedor AWS, especificando a região e credenciais (se não estiverem configuradas no ambiente).
3. Salve as alterações

<br/>
