
### Parte 1: Implementando DynamoDB + Elastic Beanstalk (EC2, SG, ELB, TG, Autoscaling...)

<br/>

#### 1.1 Configurando o DynamoDB

<br/>

* Acesse o console da AWS e navegue até **DynamoDB**.
* Clique em `Create table`.
* **Table name:** `users`
* **Partition key | Primary key:** `email`
* Clique em `Create table`.

<br />

![image](https://github.com/user-attachments/assets/db1d1c31-095c-4b45-bdc1-70115d97c9b1)


<br/>

#### 1.2 Criação de Chave SSH (Opcional)

<br/>

* No console da AWS, navegue até **EC2**.
* Em `Network & Security`, clique em `Key Pairs`.
* Clique em `Create key pair`.
* **Name:** `ssh-aws-evento`
* **Private key file format:** `.pem`
* Clique em `Create key pair`.

<br/>

![image](https://github.com/user-attachments/assets/8bf0a630-9ce8-4ded-837e-67d5734bdf5e)

<br/>

#### 1.3 Verificando e Criando Roles de IAM

<br/>

* No console da AWS, navegue até **IAM**.
* Clique em `Roles` e pesquise por “elastic”.

<br/>

![image](https://github.com/user-attachments/assets/a1d7d188-f35e-4d10-860a-0b30dedc1778)

<br/>

**Criando a Role da Instância EC2 (`aws-elasticbeanstalk-ec2-role`):**

<br/>

* No IAM, clique em `Create Role`.
* **Trusted entity type:** `AWS service`
* **Common use cases:** Selecione `EC2`. Clique em `Next`.
* **Add permissions:** Anexe as seguintes políticas:
    * `AWSElasticBeanstalkWebTier`
    * `AWSElasticBeanstalkWorkerTier`
    * `AWSElasticBeanstalkMulticontainerDocker`
* Clique em `Next`.
* **Role name:** `aws-elasticbeanstalk-ec2-role`
* Verifique a `Trust relationships`:
    ```json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "sts:AssumeRole"
          ],
          "Principal": {
            "Service": [
              "ec2.amazonaws.com"
            ]
          }
        }
      ]
    }
    ```
* Clique em `Create role`.

<br />

![image](https://github.com/user-attachments/assets/e21e67db-1762-4c77-b1fa-20138ea6690c)

<br/>

#### 1.4 Provisionando a Aplicação com Elastic Beanstalk

<br/>

* No console da AWS, navegue até **Elastic Beanstalk**.
* Clique em `Create application`.

<br/>

**Step 1 - Configure environment:**

<br/>

* **Environment tier:** `Web server environment`
* **Application information:**
    * **Application Name:** `conferencia`
* **Platform:**
    * **Platform:** `Python`
    * **Platform version:** (Recommended)
* **Application code:**
    * `Upload your code`
    * **Version label:** `conferencia-versao-01`
    * **Public S3 URL:** - Crie um S3 , baixe este arquivo `https://github.com/phillrog/aws-projetos/raw/refs/heads/main/app-aws-2/files/app.zip` , em seguida coloque-o no S3 e pegue sua url. Ex: https://estudos-aws-prs.s3.us-east-1.amazonaws.com/app.zip
* **Presets:**
    * **Configuration presets:** `High availability`
* Clique em `Next`.

<br/>

**Step 2 - Configure service access:**

<br/>

* **Service access:**
    * `Create and use new service role`
    * **‘Service’ role name:** `aws-elasticbeanstalk-service-role`
* **EC2 key pair:** Selecione `ssh-aws-evento`.
* **EC2 instance profile:** Selecione `aws-elasticbeanstalk-ec2-role`.
* Clique em `Next`.

<br/>

![image](https://github.com/user-attachments/assets/802fc180-bd50-4a6f-8cf8-a4ec3c2cf56f)

<br/>

**Step 3 - Set up networking, database, and tags:**

<br/>

* **Virtual Private Cloud (VPC):** `N. Virginia - Default VPC`
* **Instance settings:**
    * **Public IP address:** Ativado
    * **Instance subnets:** Selecione todas as zonas disponíveis.
* Clique em `Next`.

<br/>

**Step 4 - Configure instance traffic and scaling:**

<br/>

* **Instances:**
    * **Root volume type:** `General Purpose (SSD)`
    * **Size:** `10 GB`
* **Capacity:**
    * **Auto scaling group:** `Load balanced`
    * **Min:** `2`
    * **Max:** `4`
    * **Instance types:** `t2.micro`
    * **Fleet composition:** `On-Demand instances`    
    * **Architecture:** `t2.micro`
    * **Scaling triggers:**
        * **Metric:** `CPUUtilization`
        * **Unit:** `Percent`
        * **Upper:** `50`
        * **Scale up:** `1`
        * **Lower:** `40`
        * **Scale down:** `-1`

<br/>

![image](https://github.com/user-attachments/assets/3654f7ea-ab4f-41ba-883c-45ecef4a7517)

<br/>

* **Load balancer network settings:**
    * **Visibility:** `Public`
    * **Load balancer subnets:** Selecione todas as zonas.
* Clique em `Next`.

<br/>

**Step 5 - Configure updates, monitoring, and logging:**

<br/>

* Role a tela até o final.
* **Environment properties:**
    * `Add environment property`
    * **Name:** `AWS_REGION`
    * **Value:** `us-east-1`
* Clique em `Next`.

Obs: Essa var é utilizada dentro do app de exemplo.

<br/>

**Step 6 - Review:**

<br/>

* Clique em `Submit`.
* Aguarde o Elastic Beanstalk lançar o ambiente.

Obs: Vai demorar um pouco para criar.

<br/>

![image](https://github.com/user-attachments/assets/4c0d4517-eaef-4b96-aeb8-7b02bcf2a478)

<br/>

### Parte 2: Validar Recursos Criados, Cadastrar E-mail e AWS CloudFront

<br/>

#### 2.1 Validação de Recursos e Teste Inicial

* **Validar as Roles IAM:** No console IAM, pesquise por “elastic”.
* **Validar Recursos Criados:** Verifique EC2, SG, ELB, TG, ASG.
* **Testar o Funcionamento da Aplicação:**
    * No console do Elastic Beanstalk, selecione o ambiente `conferencia-env`.
    * Copie o `Domain` (ex: `http://conferencia-env.eba-cwmmuapk.us-east-1.elasticbeanstalk.com/`).
    * Acesse no navegador.
    * Tente cadastrar um e-mail (ex: `abc@abc.com`).
    * Observe o erro `Internal Server Error`.

<br/>

![image](https://github.com/user-attachments/assets/8b4c2eb6-b698-40e2-983d-e632d67e3639)

<br/>

#### 2.2 Validando Logs e Adicionando Permissão

<br/>

* **Validando Logs:**
    * No console do Elastic Beanstalk, em seu ambiente, clique em `Logs`.
    * Clique em `Request logs` e selecione `Last 100 lines`.
* **Adicionando Permissão na role “aws-elasticbeanstalk-ec2-role”:**
    * No console da AWS, navegue até **IAM**.
    * Clique em `Roles` e selecione `aws-elasticbeanstalk-ec2-role`.
    * Clique em `Add permissions`, depois em `Attach policies`.
    * Anexe a política `AmazonDynamoDBFullAccess`.
    * Clique em `Add permissions`.
* **Tente novamente cadastrar um e-mail:** (ex: `abc@abc.com`).
* **Valide no DynamoDB:**
    * No console do **DynamoDB**, clique em `Tables`, selecione `users`.
    * Clique em `Explore items` para ver o e-mail cadastrado.

<br/>

#### 2.3 Configurando o CloudFront

* No console da AWS, navegue até **CloudFront**.
* Clique em `Create a CloudFront distribution`.
* **Origin domain:** Selecione o `Elastic Load Balancer` criado pelo Elastic Beanstalk.
* **Protocol:** `HTTP only` (valide que não foi alterado para HTTPS após criação).
* **Allowed HTTP methods:** `GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE`
* **Cache key and origin requests:** `Cache policy and origin request policy (recommended)`
    * **Cache policy:** `CachingOptimized`
* **Web Application Firewall (WAF):** `Do not enable security protections`
* Clique em `Create Distribution`.
* Aguarde o status `Deploying...` mudar para `Deployed` (~5 minutos).
Obs: var demorar alguns minutos para finalizar a criação.

<br />

![image](https://github.com/user-attachments/assets/404f47a3-2455-4b38-b736-9828d00869c6)

<br/>

#### 2.4 Testando o Funcionamento do CloudFront

<br/>

* Copie o `Distribution Domain Name` do CloudFront.
* Teste o acesso no navegador. Observe que o acesso é via HTTPS.
* Cadastre um novo e-mail (ex: `ola@mundo.com`).
* Valide na tabela do DynamoDB.

<br />

![image](https://github.com/user-attachments/assets/09ccc515-dbc6-4e53-9f1b-f6bd14739e28)

<br />

![image](https://github.com/user-attachments/assets/b9e3ca0c-a8ff-41e9-b9c3-51ebb9480666)

<br />

![image](https://github.com/user-attachments/assets/23f10d07-fe22-41fb-b060-4109661b8fbd)

<br/>

### Parte 3: Teste de Carga/Stress

<br/>

#### 3.1 Acessando e Instalando Ferramenta 'Stress'

<br/>

* Acesse uma instância EC2 (ex: via CloudShell ou SSH):
    `ssh -i ssh-aws-evento.pem ec2-user@<ip-publico-ec2>`
* **Instalando a Ferramenta “Stress”:**
    `sudo yum install stress -y`
* **Executando a Ferramenta “Stress”:**
    `stress -c 4`
* **Verifique o Status do Elastic Beanstalk:** Observe se o status muda para `Warning` e os `Events`.
* **Aguarde a criação de uma nova EC2 instance!**

<br/> 

![image](https://github.com/user-attachments/assets/3dd15a0c-d4b2-403b-a79f-0254c25c7c22)

<br/> 

![image](https://github.com/user-attachments/assets/16f6423f-6518-4e6c-9392-3d1c6427bc0c)

<br/>

#### 3.2 Monitorando Recursos

<br/>

* Abra uma nova conexão com a 'mesma instância' (ou outra).
* Execute:
    * `ps aux`
    * `ps aux --sort=-pcpu`
    * `top`
* Monitore os recursos (EC2, ELB, Auto Scaling Group...).

<br/> 

![image](https://github.com/user-attachments/assets/30ab26b1-8ae9-4c88-b1d5-970f9836aec8)

<br/>

![image](https://github.com/user-attachments/assets/50d9918d-0c71-4de5-9f8c-7374125d541b)

<br/>

![image](https://github.com/user-attachments/assets/d83dc8df-0f4a-4d7a-9a87-41dbc6ffbcdd)

<br/>

#### Atualizar versão:

* Para subir outra versão click em Upload and Deploy 

<br/>

![image](https://github.com/user-attachments/assets/bbc992e0-c471-450f-b80c-066bc4ed5c95)

<br/>

* Selecione o arquivo zip com a nova versão, nomeie e click em Deploy

<br/>

![image](https://github.com/user-attachments/assets/83566aba-973a-4f92-970d-e144b007d7ea)

<br/>

#### Removendo Recursos:

<br/>

* **Elastic Beanstalk:**
    * No console do Elastic Beanstalk, selecione `Application`.
    * Clique em `Action` e selecione `Delete application`.
    * Aguarde a exclusão do `Elastic Beanstalk Environment` (status `terminated`).
* **CloudFront:**
    * No console do CloudFront, `Disable` e depois `Delete` a distribuição.
* **DynamoDB:**
    * No console do DynamoDB, `Delete` a tabela `users`.
* **Instance (se utilizada):**
    * `Terminate` na instâncias.
---

<br/>

Lembre-se que o status "Terminated" significa 'deletado' e pode levar um tempo para o recurso sumir completamente do console. Não se preocupe se demorar um pouco.
