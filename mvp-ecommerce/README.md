## Deploy de um E-commerce MVP na AWS: Terraform para Infraestrutura e Ansible para Configuração

Olá, devs e entusiastas da nuvem! Sejam muito bem-vindos a mais um tutorial que vai turbinar suas habilidades em automação e infraestrutura como código. Prepare-se para embarcar em um projeto prático onde vamos desmistificar o deploy de um e-commerce mínimo viável (MVP) na Amazon Web Services (AWS).

Neste guia completo, você vai aprender a orquestrar sua infraestrutura de forma automatizada com o poder do **Terraform**, e em seguida, a configurar sua aplicação Magento 2 nas instâncias EC2 de maneira eficiente usando o **Ansible**. Chega de configurações manuais! Vamos juntos construir um ambiente robusto e escalável do zero. Pronto para o desafio? Então, vamos começar!

### Parte 1: Deploy da Infraestrutura com Terraform

Nesta etapa, configuraremos o ambiente AWS e usaremos o Terraform para provisionar uma instância EC2 que servirá de base para nosso e-commerce.

#### 1.1 Criar uma Conta Gratuita no Magento Marketplace

Para obter as credenciais necessárias para o Ansible, você precisará de uma conta no Magento Marketplace.

1.  Acesse o [https://commercemarketplace.adobe.com/](https://commercemarketplace.adobe.com/).
2.  Crie uma conta gratuita.
3.  Após o login, navegue até `Your User | My Profile | Marketplace | Access Key | Magento 2`.
4.  Crie e **salve suas chaves Pública (Public Key) e Privada (Private Key)**.
    * Exemplo:
        * Public Key: `b2041f02509880fbbb96312b29995cb6`
        * Private Key: `7be7c69e79bd798a2a8a6b00988a5b72`
    * **_Observação_**: Estas chaves serão usadas posteriormente no Ansible Playbook para fazer o download do Magento.

<br/>

![image](https://github.com/user-attachments/assets/02754ce9-cb61-4721-a6b4-56a54ffd9ebb)

<br/>

#### 1.2 Instalando Terraform no AWS Cloud Shell

Utilizaremos o AWS Cloud Shell para executar o Terraform, pois ele já vem com o AWS CLI configurado e é um ambiente Linux conveniente.

1.  Acesse o **AWS Cloud Shell** no console da AWS.
2.  Execute os seguintes comandos para instalar o Terraform:
    ```bash
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    sudo yum -y install terraform
    ```
    * **_Observação_**: Estes comandos configuram o repositório da HashiCorp e instalam o Terraform no Cloud Shell.

<br/>

![image](https://github.com/user-attachments/assets/bc36163e-516c-4ae5-a1aa-5d7082442bb0)

<br />

#### 1.3 Download e Configuração dos Arquivos do Terraform

Baixaremos e ajustaremos os arquivos de configuração do Terraform para o nosso projeto.

1.  Crie um diretório para o projeto e navegue até ele:
    ```bash
    mkdir projeto_final
    cd projeto_final
    ```
2.  Baixe e descompacte os arquivos do Terraform:
    ```bash
    wget https://raw.githubusercontent.com/phillrog/aws-projetos/refs/heads/main/mvp-ecommerce/files/projeto-final-terraform.zip
    unzip projeto-final-terraform.zip
    cd terraform
    ```
3.  Edite o arquivo de variáveis `main.tf`:
    ```bash
    vi main.tf
    ```
    * Localize e atualize as seguintes variáveis:
        * `VPC-id`: Utilize o ID da sua **VPC Default**.
        * `SSH Key`: Utilize o nome da sua chave SSH (ex: `sshkey1`).
        * `instance_type`: Altere para `"t3a.large"`.
    * **_Observação_**: O tipo de instância `t3a.large` pode gerar custos. Consulte a página de preços do EC2 ([https://aws.amazon.com/ec2/pricing/on-demand/](https://aws.amazon.com/ec2/pricing/on-demand/)) para informações sobre custos.
    * Salve as alterações no `vi` pressionando `Esc`, digitando `:x` e Enter.

<br/>

![image](https://github.com/user-attachments/assets/6fb9d2d9-7063-4360-8527-da93169f7a61)

<br/>

![image](https://github.com/user-attachments/assets/4f35251a-7716-4a2a-8499-557bca03724a)

<br/>

![image](https://github.com/user-attachments/assets/72b8f583-ac24-496d-a35f-c4a483c7d57c)

<br/>

#### 1.4 Executando o Terraform

Agora, vamos inicializar, planejar e aplicar a configuração do Terraform para provisionar a instância EC2.

1.  **Inicializar o Terraform:**
    ```bash
    terraform init
    ```
    * **_Observação_**: Este comando baixa os provedores necessários e inicializa o diretório de trabalho.

<br/>

![image](https://github.com/user-attachments/assets/cb85ce34-ffa4-4238-9811-d63029d2175e)

<br/>

2.  **Planejar a Execução:**
    ```bash
    terraform plan
    ```
    * **_Observação_**: Este comando mostra o que o Terraform fará (quais recursos serão criados, modificados ou destruídos) antes de realmente aplicar as mudanças. Revise a saída cuidadosamente.

<br/>

![image](https://github.com/user-attachments/assets/835f1673-9287-4a27-8888-753deb1b3c96)

<br/>

3.  **Aplicar a Configuração:**
    ```bash
    terraform apply
    ```
    * Será solicitado que você digite `yes` para confirmar a aplicação das mudanças.
    * **_Observação_**: Após a execução, um novo arquivo chamado `terraform.tfstate` será criado no seu diretório.

<br/>

![image](https://github.com/user-attachments/assets/939f54c7-4d84-47ef-85a6-6e561a11f02b)

<br/>

![image](https://github.com/user-attachments/assets/6ff0f396-08c9-4225-8950-3c76ad8a555c)

<br/>

#### 1.5 Entendendo o `terraform.tfstate`

* Execute `ls` para ver o arquivo `terraform.tfstate`.
* **`terraform.tfstate`** é um arquivo crucial gerado pelo Terraform. Ele armazena o estado atual da sua infraestrutura provisionada, incluindo detalhes sobre os recursos criados e suas configurações.
* **_Atenção_**: **Nunca modifique este arquivo manualmente**, pois isso pode levar a inconsistências, corrupção do estado e problemas graves na gestão da sua infraestrutura pelo Terraform.

<br/>

![image](https://github.com/user-attachments/assets/0cf8896d-75e3-43ec-9998-dfb561cc6ee3)

<br/>

### Parte 2: Instalando e Configurando o E-commerce com Ansible

Com a infraestrutura provisionada pelo Terraform, vamos agora usar o Ansible para instalar e configurar o Magento 2 na sua instância EC2.

#### 2.1 Conectando na Instância EC2 via SSH

Precisamos acessar a instância EC2 para instalar o Ansible e executar o playbook.

1.  No console da AWS, vá para **EC2** e copie o **IP Público** da instância recém-criada pelo Terraform.
2.  Conecte-se à instância via SSH:
    ```bash
    ssh -i sshkey1.pem ec2-user@<ec2-public-ip>
    ```
    * Substitua `<ec2-public-ip>` pelo IP público da sua instância.
    * **_Observação_**: Certifique-se de que o arquivo `sshkey1.pem` esteja na mesma pasta de onde você está executando o comando SSH e que suas permissões estejam corretas (`chmod 400 sshkey1.pem` em Linux/macOS).

<br/>

![image](https://github.com/user-attachments/assets/3ddefc33-85a9-459c-a3fb-993a977a0027)

<br/>

![image](https://github.com/user-attachments/assets/6665143c-f6a7-4db9-9aa2-2b6bd22b3c87)

<br/>

![image](https://github.com/user-attachments/assets/76766199-c439-4501-9d21-24d244efb4b8)

<br/>

![image](https://github.com/user-attachments/assets/4845a18f-9123-4117-8029-2180f1f071a2)

<br/>

#### 2.2 Instalando Ansible na EC2

Uma vez conectado à instância EC2, instale o Ansible.

1.  Execute os seguintes comandos no terminal da sua instância EC2:
    ```bash
    sudo yum-config-manager --enable epel
    sudo yum install ansible -y
    ```
    * **_Observação_**: `epel` (Extra Packages for Enterprise Linux) é um repositório que fornece pacotes adicionais, incluindo o Ansible.

#### 2.3 Download e Configuração do Ansible Playbook

Baixaremos o playbook do Magento 2 e inseriremos suas credenciais.

1.  Baixe e descompacte o playbook do Ansible na sua instância EC2:
    ```bash
    wget https://raw.githubusercontent.com/phillrog/aws-projetos/refs/heads/main/mvp-ecommerce/files/projeto-final-ansible-magento2.zip
    unzip projeto-final-ansible-magento2.zip
    ```
<br/>

![image](https://github.com/user-attachments/assets/f5a275e5-359a-4e87-acb3-0e4751bbe58e)

<br/>

2.  Navegue até o diretório do playbook:
    ```bash
    cd ansible-magento2
    ```
3.  Edite o arquivo de variáveis `group_vars/all.yml`:
    ```bash
    vi group_vars/all.yml
    ```
    * Localize e atualize os seguintes parâmetros com o **IP Público da sua instância EC2** e suas **chaves do Magento Marketplace**:
        * `magento_domain: <ec2-public-ip>`
        * `server_hostname: <ec2-public-ip>`
        * `repo_api_key: <sua chave pública do Magento>`
        * `repo_secret_key: <sua chave privada do Magento>`
    * Salve o arquivo no `vi` (`Esc` | `:x` | Enter).

<br/>

![image](https://github.com/user-attachments/assets/09589c7e-aa64-48f2-849b-36f993973c2f)

<br/>

#### 2.4 Executando Ansible para o Deploy do E-commerce

Este comando executará o playbook do Ansible, que fará todo o trabalho de instalação e configuração do Magento 2.

1.  Execute o seguinte comando:
    ```bash
    ansible-playbook -i hosts.yml ansible-magento2.yml -k -vvv --become
    ```
    * **_Observação_**:
        * `-i hosts.yml`: Especifica o arquivo de inventário.
        * `-k`: Solicita a senha de acesso (para `sudo`).
        * `-vvv`: Aumenta o nível de verbosidade para ver mais detalhes durante a execução.
        * `--become`: Permite que o Ansible execute comandos com privilégios de `sudo` (root).
    * A execução do Ansible pode levar vários minutos (cerca de 30 minutos), pois ele instalará softwares como Nginx, PHP, MySQL e o próprio Magento. Se quiser aconpanhar as tarefas abra o arquivo ansible-magento2\roles\magento\tasks\main.yml

<br/>

![image](https://github.com/user-attachments/assets/26db3870-e626-416c-8c55-a824aac8fdf7)

<br/>

![image](https://github.com/user-attachments/assets/84e52491-874b-4569-80f1-4d696846fb3f)

<br/>

![image](https://github.com/user-attachments/assets/77d55785-6cbc-4774-a8a8-df115a054722)

<br/>

### Parte 3: Testando e Configurando o E-commerce Magento

Com o Ansible finalizado, é hora de testar seu e-commerce e realizar algumas configurações básicas.

#### 3.1 Testando o Website do E-commerce

1.  Copie o **IP Público da sua instância EC2** e cole-o em um navegador web.
2.  Você deverá ver a página inicial do Magento 2.

<br/>

![image](https://github.com/user-attachments/assets/a4d9c2f9-d952-4d4a-8421-0b8a952f2a23)

<br/>

#### 3.2 Configurando o E-commerce (Área Administrativa)

1.  No seu navegador, acesse a área administrativa do Magento:
    * `http://<EC2_PUBLIC_IP>/securelocation`
2.  Faça login com as credenciais padrão do Ansible Playbook:
    * **User:** `Admin`
    * **Password:** `Strong123Password#`
3.  **Download de Arquivos de Imagens (Opcional):**
    * Para personalizar o e-commerce, você pode baixar um pacote de imagens baixo ou utilizar as suas:
        `https://raw.githubusercontent.com/phillrog/aws-projetos/refs/heads/main/mvp-ecommerce/files/projeto-final-images.zip`

<br/>

![image](https://github.com/user-attachments/assets/77fd549f-3ee3-4b76-bd6c-c752a0ee8757)

<br/>

#### 3.3 Customização Básica do E-commerce

1.  **Alterar Título da Página e Logo:**
    * No painel administrativo do Magento, vá para `Content > Configuration`.
    * Em `Default Store View`, clique em `Edit`.
    * **'HTML Head'**: Altere `Default page title` para um título qualquer . Exemplo: `Minha loja`.
    * **'Header'**:
        * `Logo image`: Faça upload do logo.
        * `Welcome text`: Altere para `Bem a Minha Loja!`.
    * Clique em `Save Configuration!`.
    * **Se for requisitado "Refresh no Cache":**
        * Vá para `Cache Management`.
        * Marque as caixas de seleção de `INVALIDATED` tipos de cache e clique em `Flush Magento Cache`.
2.  **Adicionar um Produto:**
    * No painel administrativo, vá para `Catalog > Products`.
    * Clique em `Add product`.
    * Preencha os detalhes:
        * `Name`: `Camisa Lisa`
        * `Price`: `80`
        * `Quantity`: `100`
    * Em `Images And Videos`, clique em `Add images` e faça upload de imagens relevantes.
    * Clique em `Save`.
3.  **Exibir Produtos na Página Inicial:**
    * No painel administrativo, vá para `Content > Pages`.
    * Marque a caixa de seleção ao lado de `Home Pages` e clique em `Edit`.
    * Clique na aba `Content`. Limpe as informações existentes.
    * Clique no ícone `Insert Widget`.
    * Para `Widget type`, selecione `Catalog Products List`.
    * Clique em `Insert Widget`.
    * Clique em `Save`.
4.  **Validar as Alterações:**
    * No painel administrativo, clique em `Admin | Customer View` (no canto superior direito) para ver a loja como um cliente.
    * Você deverá ver as alterações aplicadas, incluindo o novo produto na página inicial.

**E-commerce implementado com sucesso!!! 🚀**

### Parte 4: Resultado

<br/>

![image](https://github.com/user-attachments/assets/e6b37780-736a-4643-97b3-f3390f647774)

<br/>

![image](https://github.com/user-attachments/assets/3066456f-49c6-4901-ba49-d67f630c02a5)

<br/>

![image](https://github.com/user-attachments/assets/ef52af57-aaaf-4b58-9776-e4c75cd90f26)

<br/>

![image](https://github.com/user-attachments/assets/0681acc0-a741-406f-b073-62cf87c6aa22)

<br/>

### Parte 5: Removendo Recursos

#### Removendo Recursos Implementados

É **essencial** remover todos os recursos da AWS para evitar cobranças indesejadas.

1.  **Removendo Recursos do Terraform:**
    * Volte para o **AWS Cloud Shell** onde você executou o Terraform.
    * Navegue para a pasta de onde você executou o Terraform na Parte 1:
        ```bash
        cd ~/projeto_final/terraform/
        ```
    * Execute o comando para destruir os recursos:
        ```bash
        terraform destroy
        ```
    * **_Observação_**: O Terraform listará todos os recursos que serão destruídos. Digite `yes` para confirmar. Isso removerá a instância EC2, o Security Group, etc.

2.  **Se necessário, re-instalar o Terraform (apenas se você saiu do Cloud Shell e a sessão foi reiniciada):**
    ```bash
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    sudo yum -y install terraform
    ```

3.  **Verificar e Confirmar:**
    * Após a execução do `terraform destroy`, verifique no console da AWS (serviço EC2) se a instância foi terminada. Pode levar um tempo para "sumir" completamente.
