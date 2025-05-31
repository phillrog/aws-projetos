# Automatizando a Instalação de Agentes de Segurança na AWS com Terraform e Systems Manager

Este README detalha o processo de provisionamento de instâncias Amazon EC2 e a subsequente instalação automatizada de um agente de segurança, utilizando Terraform para a infraestrutura como código e AWS Systems Manager para o gerenciamento de configuração e execução de comandos.

## Visão Geral do Projeto

O objetivo é demonstrar uma abordagem DevSecOps para garantir que instâncias recém-provisionadas tenham agentes de segurança instalados automaticamente, com notificação do processo.

## Pré-requisitos

<br/>

*   Conta AWS ativa.
*   AWS CLI configurada (opcional, pois usaremos o Cloud Shell).
*   Visual Studio Code (ou editor de sua preferência).

<br/>

## Parte 1: Configuração e Provisionamento com Terraform

<br/>

### 1.1. Preparação do Ambiente de Desenvolvimento 

<br/>

1.  **Instale o Visual Studio Code (Opcional):**
    *   Baixe em: [https://code.visualstudio.com/download](https://code.visualstudio.com/download)

<br/>

2.  **Instale Extensões Recomendadas no VSCode (Opcional):**
    *   `Terraform` (da HashiCorp)
    *   `Material Icon Theme`
    *   `Prettier - Code formatter`

<br/>

3.  **Obtenha os Arquivos do Projeto Terraform:**
    *   Faça o download do arquivo ZIP contendo os arquivos base `main.tf` e `provider.tf`:
        ```
        https://github.com/phillrog/aws-projetos/blob/main/devsecops/scripts/terraform-scripts.zip
        ```
    *   Descompacte este arquivo em um diretório local.

<br/>

### 1.2. Configuração dos Arquivos Terraform

<br/>


1.  Abra o diretório do projeto no VSCode.
2.  Edite os arquivos `main.tf` e `provider.tf` conforme necessário com os dados dos componentes na AWS.
    *   **Observação:** Para este projeto, o uso da VPC e Subnet padrão da sua conta AWS.
        *   `main.tf`: Define os recursos AWS a serem criados (ex: instâncias EC2).
        *   `provider.tf`: Configura o provedor AWS, especificando a região e credenciais (se não estiverem configuradas no ambiente).
3. Salve as alterações

<br/>

## Entendendo os Componentes do `main.tf` no Terraform

No arquivo `main.tf` do nosso projeto Terraform, encontramos diferentes blocos de código que definem como nossa infraestrutura será construída. Vamos entender objetivamente o papel de cada um, com base no contexto do projeto:

### `data`

*   **Para que serve?** O bloco `data` é usado para buscar informações sobre recursos existentes na AWS (ou em outros provedores) que não são gerenciados diretamente por este código Terraform, mas que são necessários para configurar os recursos que *estamos* criando.
*   **No nosso contexto:**
    *   **`data "aws_ami" "amazon_linux_2"`:** Este bloco busca o ID da Amazon Machine Image (AMI) mais recente do Amazon Linux 2 na região especificada. Em vez de codificarmos um ID de AMI fixo (que pode se tornar desatualizado), o Terraform dinamicamente encontra o mais recente no momento da execução. Isso garante que nossas instâncias EC2 sejam sempre lançadas com a versão mais atualizada do Amazon Linux 2.
    *   **Observação:** Dentro deste bloco, filtros como `most_recent = true`, `name_regex`, e `owners` são usados para refinar a busca pela AMI correta.

### `variable`

*   **Para que serve?** O bloco `variable` é usado para definir variáveis de entrada para o nosso código Terraform. Isso torna o código mais flexível e reutilizável, permitindo que valores sejam passados durante a execução (`terraform apply`) ou definidos em arquivos de variáveis separados (ex: `terraform.tfvars`), em vez de serem codificados diretamente no `main.tf`.
*   **No nosso contexto:**
    *   **`variable "instance_type"`:** Define uma variável para o tipo de instância EC2 (ex: `t2.micro`, `t3.small`). Podemos especificar um valor padrão (`default`) e uma descrição (`description`). Isso permite que, se quisermos usar um tipo de instância diferente, possamos fazê-lo sem alterar o código principal do `main.tf`.
    *   **`variable "key_name"`:** Define uma variável para o nome do par de chaves EC2 (`sshkey1` no nosso caso) que será associado às instâncias. Isso permite que o nome da chave seja facilmente alterado se necessário.
    *   **Observação:** As variáveis aumentam a modularidade e facilitam a personalização da infraestrutura sem modificar a lógica principal do código.

### `resource`

*   **Para que serve?** O bloco `resource` é o coração do Terraform. Ele define um componente da infraestrutura que o Terraform irá criar, gerenciar e, eventualmente, destruir. Cada bloco `resource` especifica o tipo de recurso (ex: `aws_instance` para uma instância EC2, `aws_vpc` para uma VPC) e um nome local para esse recurso dentro do código Terraform.
*   **No nosso contexto:**
    *   **`resource "aws_instance" "web_server"` (ou similar):** Este bloco define a criação de uma ou mais instâncias Amazon EC2.
        *   **`ami = data.aws_ami.amazon_linux_2.id`**: Aqui, usamos a informação obtida pelo bloco `data` (o ID da AMI do Amazon Linux 2) para especificar qual imagem será usada para lançar a instância.
        *   **`instance_type = var.instance_type`**: O tipo da instância é definido pelo valor da variável `instance_type`.
        *   **`key_name = var.key_name`**: O nome do par de chaves a ser associado à instância é definido pela variável `key_name`.
        *   **Outras configurações:** Dentro deste bloco, também podemos definir `subnet_id` (para especificar em qual sub-rede a instância será lançada, no nosso caso, a sub-rede padrão da VPC padrão), `security_groups` (para associar grupos de segurança), `tags` (para organizar e identificar os recursos), entre outras propriedades específicas do recurso `aws_instance`.
    *   **Observação:** Cada bloco `resource` representa um objeto que o Terraform irá gerenciar ao longo do seu ciclo de vida (criação, atualização, destruição). As configurações dentro do bloco determinam as características exatas do recurso na AWS.

Em resumo, no `main.tf`:
*   `data` busca informações existentes.
*   `variable` permite parametrizar o código.
*   `resource` define os componentes da infraestrutura a serem criados e gerenciados.

Juntos, esses blocos permitem que o Terraform descreva e provisione a infraestrutura desejada de forma declarativa e automatizada.

<br/>

#### VPC default

![image](https://github.com/user-attachments/assets/c88087a8-f9c1-4c9b-bfd0-ff8a495ddb26)

<br/>

#### Subnet default

![image](https://github.com/user-attachments/assets/ae151ad1-54e8-488b-bc02-de60a6ce4fc1)

<br/>

### 1.3. Criação do Par de Chaves EC2

1.  Acesse o console da AWS > EC2 > Key Pairs.
2.  Clique em "Create key pair".
3.  **Nome:** `sshkey1`
4.  **Formato do arquivo da chave privada:** `.pem`
5.  Clique em "Create key pair".

*   **Importante:** Faça o download do arquivo `.pem` e guarde-o em um local seguro. Ele será usado para acessar as instâncias EC2.

<br/>

![image](https://github.com/user-attachments/assets/83ee5838-9eb8-45b1-bae3-10f4dcc0e1a5)

<br/>


### 1.4. Preparação dos Arquivos para Upload no Cloud Shell

<br/>

1.  Certifique-se de que todas as alterações nos arquivos `main.tf` e `provider.tf` foram salvas.
2.  Crie um arquivo `.zip` contendo **apenas** os arquivos `main.tf` e `provider.tf`.

<br/>

### 1.5. Configuração e Execução no AWS Cloud Shell

<br/>

1.  Abra o AWS Cloud Shell no console da AWS.
2.  **Upload e Descompactação:**

    *   Faça o upload do arquivo `.zip` (criado no passo 1.4) para o Cloud Shell.
    *   Descompacte o arquivo:
        ```bash
        unzip nome_do_seu_arquivo.zip
        rm -rf nome_do_seu_arquivo.zip
        ls
        ```
<br/>

#### Upload do .zip

![image](https://github.com/user-attachments/assets/b876712e-1cd6-4d66-932e-aa634fd06287)

<br/>

#### Arquivos

![image](https://github.com/user-attachments/assets/aeb4fe0e-a6f6-4d81-9049-ddb4ce2aa361)

<br/>

3.  **Instalação do Terraform no Cloud Shell:**
    ```bash
    # Adiciona o repositório HashiCorp
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    # Instala o Terraform
    sudo yum -y install terraform
    # Verifica a instalação
    terraform -v
    ```

    *   **Observação:** Estes comandos são específicos para o Amazon Linux 2, o ambiente padrão do AWS Cloud Shell.

#### Copia e cola os comandos no cloud shell 

<br/>

![image](https://github.com/user-attachments/assets/577abe3b-0bf8-4979-b9ed-4252a3f0f6b4)

<br/>

![image](https://github.com/user-attachments/assets/7636827e-f659-40ae-9848-61446b34062d)

<br/>


4.  **Execução do Terraform:**
    *   Navegue até o diretório onde você descompactou os arquivos `main.tf` e `provider.tf`.
    *   Execute os seguintes comandos Terraform em sequência:
        ```bash
        # Inicializa o diretório de trabalho do Terraform, baixando plugins de provedores.
        terraform init
        ```
<br/>

![image](https://github.com/user-attachments/assets/12d1a252-84a5-410c-bbd1-c2790411cdfc)

<br/>

        ``` bash
        # Cria um plano de execução, mostrando os recursos que o Terraform irá criar/modificar.
        # Revise este plano antes de aplicar.
        terraform plan
        ```
<br />

![image](https://github.com/user-attachments/assets/37a51f81-17f3-451f-8df3-f1fde998db50)


<br />
        ```bash
        # Aplica as configurações, provisionando a infraestrutura na AWS.
        # Você precisará digitar 'yes' para confirmar.
        terraform apply
        ```
<br/>

![image](https://github.com/user-attachments/assets/019ace39-269c-47ba-91c4-472e6af7676e)


<br/>

![image](https://github.com/user-attachments/assets/b8f113ca-8d07-444f-a439-ede23e8ff628)


<br/>

*   **Observação:** A partir daqui as intâncias e o SG já estão sendo criadas.

<br />

![image](https://github.com/user-attachments/assets/ad1c4213-ff52-40d7-bbf9-f7fcd376756f)


<br/>

### 1.6. Verificações Pós-Provisionamento

*   **IAM Role das EC2:** No console da AWS, verifique as instâncias EC2 criadas. Neste ponto, elas não devem ter uma IAM Role específica associada pelo Terraform (a menos que definida no `main.tf`).

<br/>

![image](https://github.com/user-attachments/assets/dcaf09b4-ba1c-42cf-8a76-4ff428837fe2)


<br/>

*   **Arquivo `terraform.tfstate`:** No diretório do Cloud Shell, você encontrará um arquivo `terraform.tfstate`.
    *   **Importante:** Este arquivo armazena o estado atual da sua infraestrutura gerenciada pelo Terraform. Não o modifique manualmente.

<br/>

![image](https://github.com/user-attachments/assets/d3c9396e-0ba0-42db-94b1-c635962a813a)


<br/>

## Parte 2: Gerenciamento e Automação com AWS Systems Manager

### 2.1. Criação da IAM Role (`SystemsManagerToSNS`)

1.  Acesse o serviço **IAM** no console da AWS.
2.  Vá em **Roles** -> **Create role**.
3.  **Trusted entity type:** `AWS service`.
4.  **Use case:** Selecione `Systems Manager` na lista e escolha o caso de uso `Allows SSM to call AWS services on your behalf`.

<br/>

![image](https://github.com/user-attachments/assets/73194cca-c978-4793-8b2d-0559cf7666a9)


<br/>

5.  **Permissions policies:** Anexe a política `AmazonSNSFullAccess`.
6.  **Role details:**
    *   **Role name:** `SystemsManagerToSNS`
7.  Clique em **Create role**.
    *   **Observação:** Esta role concede ao Systems Manager as permissões necessárias para publicar mensagens em um tópico SNS.

<br/>

![image](https://github.com/user-attachments/assets/18be1720-0190-4806-8853-f9f256bb4edf)


<br/>

### 2.2. Criação do Tópico SNS (`DevOpsNotification`)

1.  Acesse o serviço **Amazon SNS** no console da AWS.
2.  Vá em **Topics** -> **Create topic**.
3.  **Type:** `Standard`.
4.  **Name:** `DevOpsNotification`.
5.  Clique em **Create topic**.
6.  Após a criação, **copie o ARN (Amazon Resource Name) do tópico**. Você precisará dele mais tarde.
    *   Exemplo de ARN: `arn:aws:sns:us-east-1:123456789012:DevOpsNotification`

<br />

![image](https://github.com/user-attachments/assets/54a4a23a-4bc7-4e27-9535-6b3002ab767f)

<br />

### 2.3. Criação da Assinatura (Subscription) no Tópico SNS

1.  Com o tópico `DevOpsNotification` selecionado, vá para a aba **Subscriptions** e clique em **Create subscription**.
2.  **Protocol:** `Email`.
3.  **Endpoint:** Insira seu endereço de e-mail onde deseja receber as notificações.
4.  Clique em **Create subscription**.
5.  **Confirmação:** Você receberá um e-mail da AWS. Abra o e-mail e clique no link "**Confirm subscription**".

<br />

#### E-mail
![image](https://github.com/user-attachments/assets/ad42ca98-9d1c-4a04-8786-f14e3655e15f)

#### Confirmação
![image](https://github.com/user-attachments/assets/3351adce-0ef1-4d9d-a303-207c7fb0f2a6)

<br />

### 2.4. Configuração do AWS Systems Manager - Quick Setup

1.  Acesse o serviço **AWS Systems Manager**.
2.  No menu lateral, clique em **Quick Setup**. (Se for a primeira vez, pode ser necessário clicar em "Get Started").
    *   **Importante:** Confirme se você está na região correta (ex: `us-east-1`).
3.  Em "Choose a configuration type", selecione **Host Management** e clique em **Create**.

<br/>

![image](https://github.com/user-attachments/assets/f3f44a07-5445-49e0-a0e2-d25fe43d2878)


<br/>

4.  **Configuration options:** Mantenha os padrões ou ajuste conforme necessidade.
5.  **Targets:**
    *   Selecione "Choose how you want to target instances".
    *   Escolha **Manual**.
    *   Selecione as instâncias EC2 que foram criadas pelo Terraform na Parte 1.
<br/>

![image](https://github.com/user-attachments/assets/53a5ff6a-af9a-4a26-a846-26d4335a0708)


<br />

6.  Clique em **Create**.
    *   **Observação:** A conclusão deste processo pode levar aproximadamente 15 minutos. O Quick Setup configura o SSM Agent nas instâncias e as associações necessárias.

<br/>

![image](https://github.com/user-attachments/assets/d015d58f-9e4e-4975-b08f-d0a0ac877dd0)


<br/>

### 2.5. Validação da Configuração do Systems Manager

1.  Após o Quick Setup indicar "Success", valide o "Configuration deployment status" e "Configuration association status".
2.  **Teste o Acesso com Session Manager:**
    *   No Systems Manager, vá em **Node Management** -> **Session Manager**.
    *   Clique em **Start session**.
<br/>

* **Obs: Pode demorar alguns minutos para aparecer as instâncias após confirmação da incrição*

<br/>

![image](https://github.com/user-attachments/assets/3e5d589e-274c-445f-85a3-ea23aee9431c)


<br/>

    *   Selecione uma das suas instâncias EC2, Next, Next e clique em **Start session**.
    *   Na sessão do terminal aberta, execute:
        ```bash
        # Verifica a distribuição do sistema operacional.
        cat /etc/*release*

        # Tenta listar o agente de segurança (ainda não deve existir).
        # Saída esperada: ls: cannot access /usr/bin/security_agent: No such file or directory
        ls -ltr /usr/bin/security_agent
        ```
<br/>

![image](https://github.com/user-attachments/assets/d83651b4-033b-4524-940b-139d4043c528)


<br/>

    *   Feche a sessão.


### 2.6. Instalação do Agente de Segurança via Run Command

1.  No Systems Manager, vá em **Node Management** -> **Run Command**.
2.  Clique em **Run command**.
3.  **Command document:** Procure e selecione o documento `AWS-RunShellScript`.
4.  **Command parameters:** Cole o seguinte script:
    ```bash
    # Baixa o script de instalação do agente de segurança para o diretório /tmp
    sudo wget -q https://raw.githubusercontent.com/phillrog/aws-projetos/refs/heads/main/devsecops/scripts/install_security_agent.sh -P /tmp
    # Concede permissão de execução ao script
    sudo chmod +x /tmp/install_security_agent.sh
    # Executa o script de instalação
    sudo /tmp/install_security_agent.sh
    # Lista o diretório para verificar se o agente foi instalado
    ls -ltr /usr/bin/security_agent
    ```
    *   **Observação:** Este script faz o download de um `install_security_agent.sh`, torna-o executável e o executa. A última linha verifica a instalação.

<br/>

![image](https://github.com/user-attachments/assets/efb8368e-1aa2-4d4b-8d40-c0d26cc85435)


<br/>

5.  **Targets:**
    *   Selecione "Choose instances manually".
    *   Selecione as mesmas instâncias EC2 de antes.

<br/>

![image](https://github.com/user-attachments/assets/9de67bea-5bd0-4b97-886e-6f6851c73b2d)


<br/>

6.  **Output options:**
    *   Desmarque "Enable writing to an S3 bucket".
7.  **SNS notifications:**
    *   Marque "Enable SNS notifications".
    *   **IAM role:** Selecione a role `SystemsManagerToSNS` criada anteriormente.
    *   **SNS topic:** Cole o ARN do tópico `DevOpsNotification` (copiado no passo 2.2).
    *   **Event notifications:** Selecione `All events`.
    *   **Change notifications:** Selecione `Command status on each instance changes`.
8.  Clique em **Run**.

<br/>

![image](https://github.com/user-attachments/assets/abcd1692-1f63-420c-b8e8-e4861808528b)


<br/>

9.  **Monitoramento e Verificação:**
    *   Monitore o status da execução do comando no console.
    *   **Verifique seu e-mail:** Você deve receber notificações do SNS sobre o progresso.
    *   Após a conclusão (status "Success"), clique no ID do comando, selecione uma instância e verifique a aba "Output". A saída do comando `ls -ltr /usr/bin/security_agent` deve agora listar o arquivo do agente.

<br/>

![image](https://github.com/user-attachments/assets/63c7625d-98e6-41f6-8a92-88fce5642f45)


<br/>

![image](https://github.com/user-attachments/assets/622ae2b0-99ae-4d32-98d7-b212fe2cb720)


<br/>

![image](https://github.com/user-attachments/assets/cfd1750d-63bd-477c-b1a9-27c670dde2e6)


<br/>

## Limpeza de Recursos

É crucial remover os recursos criados para evitar custos inesperados.

### 1. Destruir a Infraestrutura Terraform

1.  Retorne ao **AWS Cloud Shell**, no diretório do seu projeto Terraform.
2.  **Se a sessão do Cloud Shell expirou, pode ser necessário reinstalar o Terraform:**
    ```bash
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    sudo yum -y install terraform
    ```
3.  Verifique se o arquivo `terraform.tfstate` está presente (`ls`).
4.  Execute o comando de destruição:
    ```bash
    # Remove todos os recursos gerenciados por este estado do Terraform.
    # Digite 'yes' para confirmar.
    terraform destroy
    ```
<br/>

![image](https://github.com/user-attachments/assets/1166184c-2359-49bc-be49-9c3587b438ad)


<br/>

![image](https://github.com/user-attachments/assets/99f48173-1bf0-423f-84a6-130fd5c65d1c)


<br/>

### 2. Remover a Configuração do Systems Manager Quick Setup

1.  No **AWS Systems Manager**, vá para **Quick Setup**.
2.  Selecione a configuração **Host Management** que você criou.
3.  No menu **Actions**, selecione **Delete configuration**.
4.  Siga as instruções na tela para confirmar a exclusão (pode ser necessário marcar "Remove All OUs and Regions" e digitar "delete").

### 3. (Opcional) Remover Tópico SNS e Role IAM

*   Se não forem mais necessários, você pode excluir o tópico `DevOpsNotification` no console do SNS e a role `SystemsManagerToSNS` no console do IAM.
