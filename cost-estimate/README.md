## Estimando Custos de Migração SAP na AWS

Este guia passo a passo detalha como utilizar a Calculadora de Preços da AWS para estimar os custos de uma migração SAP, cobrindo todos os ambientes e serviços necessários.

ATENÇÃO: Os valores podem variar.

### 1. Preparação e Recursos

Antes de começar, prepare seu ambiente de trabalho:

1. Acesse a **[Calculadora de Preços da AWS](https://calculator.aws/#/)**.
2. Faça o download do template para a apresentação final: **[Apresentacao Executiva AWS Cost Estimate.pptx](https://raw.githubusercontent.com/phillrog/aws-projetos/refs/heads/main/cost-estimate/files/modelo.pptx)**.
3. Na calculadora, clique em **Create estimate**.

<br/>

![image](https://github.com/user-attachments/assets/e908d21d-f39d-42de-8436-d795a67884ba)

<br/>

### 2. Estimar Servidores (EC2) e Armazenamento (EBS) - Ambiente de Produção

- **Serviço:** Busque por `EC2` e adicione **Amazon EC2**.
- **Região:** `South America (São Paulo)`.
> **Ponto Forte:** A escolha da região é uma decisão de negócio, geralmente baseada na latência para os usuários finais e requisitos de soberania de dados.
- **Especificações do EC2:**
  - Operating System: **Linux**
  - Workloads: **Constant usage**
  - Number of instances: **5** (para o ambiente de produção).
- **Tipo de Instância:** `t3a.2xlarge` (8 vCPUs e 16 GB de memória).
- **Opção de Pagamento:**
  - Selecione **Compute Savings Plans** com um termo de **3 Year**.
> **Ponto Forte:** Utilizar Savings Plans de 3 anos é uma decisão estratégica para maximizar a economia de custos (até 72% em comparação com On-Demand), ideal para cargas de trabalho com uso constante como um ambiente de produção SAP.
- **Armazenamento (EBS):**
  - Storage for each EC2 instance: **General Purpose SSD (gp2)**
  - Storage amount: **400 GB**.
> **Nota:** Este valor é derivado da necessidade total de 2 TB, dividida entre as 5 instâncias (2000 GB / 5 = 400 GB por instância).
- Clique em **Save and View Summary**.

<br/>

![image](https://github.com/user-attachments/assets/4b454c78-44aa-4b85-be46-20e5bb301f5e)


<br/>

![image](https://github.com/user-attachments/assets/9f523d36-8467-4e14-9257-db6e1d6735c2)


<br/>

### 3. Estimar Load Balancer (LB) - Todos os Ambientes

- Clique em **Add Service** e busque por `Elastic Load Balancing`.
- **Descrição:** `LB - Prod/HML/Dev`.
- **Região:** `South America (São Paulo)`.
- **Tipo:** **Application Load Balancer**.
- **Quantidade:** **3** (um para cada ambiente: Produção, Homologação e Desenvolvimento).
- **Capacidade:**
  - Processed bytes: **2 GB/hour** (ajuste conforme a necessidade).
- Clique em **Save and View Summary**.

<br/>

![image](https://github.com/user-attachments/assets/34b50dc1-d81a-47c2-b1e8-7fbe6933cabe)


<br/>

### 4. Estimar NFS Storage (EFS) - Todos os Ambientes

- Clique em **Add Service** e busque por `Amazon Elastic File System (EFS)`.
- **Descrição:** `NFS - Prod/HML/Dev`.
- **Região:** `South America (São Paulo)`.
- **Classe de Armazenamento:** **Standard Storage**.
- **Capacidade:**
  - Desired Storage Capacity: **1750 GB per Month**.
> **Nota:** Valor total somando as necessidades de todos os ambientes (1 TB + 500 GB + 250 GB = 1750 GB).
- Clique em **Save and View Summary**.

<br/>

![image](https://github.com/user-attachments/assets/b556a3f2-acc5-4626-ae64-cfcd6701d515)


<br/>

### 5. Estimar Servidores (EC2) e Armazenamento (EBS) - Ambientes de Homologação e Desenvolvimento

- Clique em **Add Service** e adicione **Amazon EC2**.
- **Descrição:** `EC2 - HML/Dev`.
- **Região:** `South America (São Paulo)`.
- **Especificações do EC2:**
  - Number of instances: **5**.
> **Nota:** Somatório das instâncias de Homologação (3) e Desenvolvimento (2).
- **Tipo de Instância:** `t3a.xlarge` (4 vCPUs, 8 GB de memória).
- **Opção de Pagamento:** **Compute Savings Plans** | **3 Year**.
- **Armazenamento (EBS):**
  - Storage for each EC2 instance: **General Purpose SSD (gp2)**
  - Storage amount: **300 GB**.
> **Nota:** Custo total de 1.5 TB (1 TB HML + 500 GB Dev) dividido por 5 instâncias.
- Clique em **Save and View Summary**.

<br/>

![image](https://github.com/user-attachments/assets/bfe85f84-965d-4cb5-84d0-c0c1211c226c)


<br/>

### 6. Estimar Banco de Dados Oracle (RDS) - Produção

- Clique em **Add Service** e busque por `Amazon RDS for Oracle`.
- **Descrição:** `BD - Prod`.
- **Região:** `South America (São Paulo)`.
- **Instâncias:**
  - Number of instances: **2**.
  - Instance Type: **db.m4.10xlarge** (40 vCPU, 160 GB RAM).
  - Deployment: **Multi-AZ**.
> **Ponto Forte:** A implantação **Multi-AZ** é crucial para ambientes de produção, pois garante alta disponibilidade e failover automático para um banco de dados standby em outra Zona de Disponibilidade.
- **Storage:**
  - Storage amount: **1500 GB** por instância (total de 3 TB).
  - Backup Storage: **3000 GB**.
- Clique em **Save and View Summary**.

<br/>

![image](https://github.com/user-attachments/assets/89b41360-f53f-4c82-8565-af5b06eecff6)


<br/>

### 7. Estimar Banco de Dados Oracle (RDS) - Homologação

- Clique em **Add Service** e adicione `Amazon RDS for Oracle`.
- **Descrição:** `BD - HML`.
- **Instâncias:**
  - Number of instances: **2**.
  - Instance Type: **db.m4.4xlarge** (16 vCPU, 64 GB RAM).
  - Deployment: **Single-AZ**.
> **Ponto Forte:** Utilizar **Single-AZ** para ambientes de não-produção é uma prática de otimização de custos, já que a alta disponibilidade não é um requisito crítico.
- **Storage:**
  - Storage amount: **1500 GB** por instância (total de 3 TB).
  - Backup Storage: **3000 GB**.
- Clique em **Save and View Summary**.

<br/>

![image](https://github.com/user-attachments/assets/cf956bbe-085c-48cb-a569-7751d02bdceb)


<br/>

### 8. Estimar Banco de Dados Oracle (RDS) - Desenvolvimento

- Clique em **Add Service** e adicione `Amazon RDS for Oracle`.
- **Descrição:** `BD - Dev`.
- **Instâncias:**
  - Number of instances: **2**.
  - Instance Type: **db.m3.2xlarge** (8 vCPU, 30 GB RAM).
  - Deployment: **Single-AZ**.
- **Storage:**
  - Storage amount: **500 GB** por instância (total de 1 TB).
  - Backup Storage: **1000 GB**.
- Clique em **Save and View Summary**.


<br/>

![image](https://github.com/user-attachments/assets/77a45af1-ae07-4519-9b4a-789cbc0b1b92)


<br/>

### 9. Adicionar Plano de Suporte

- Na tela de resumo, clique em **Add Support**.
- **Descrição:** `Support`.
- **Nível de Suporte:** Selecione a opção para **Enterprise support plan**.
> **Ponto Forte:** O plano Enterprise é recomendado para cargas de trabalho críticas, oferecendo o tempo de resposta mais rápido (15 minutos) e um Technical Account Manager (TAM) dedicado.
- Clique em **Add to my estimate** e **Confirm**.

<br/>

![image](https://github.com/user-attachments/assets/9a911439-529e-4820-afe3-813cac3f3f62)


<br/>

Obs: Pergunte-se, quanto custaria isso no ambiente on premise ?

### 10. Finalização e Criação da Apresentação

1. **Exportar Dados:** Na tela de resumo, exporte o resultado para **CSV**.
2. **Preparar PowerPoint:**
  - Abra o template `Apresentacao_Executiva_AWS_Cost_Estimate.pptx`.
  - Insira **seu nome, cargo e o logo da sua empresa**.
3. **Atualizar Gráficos:**
  - Abra o arquivo CSV no Excel ou outra planilha.
  - No PowerPoint, clique com o botão direito sobre cada gráfico e selecione **Editar Dados**.
  - Copie os dados de **Serviço** e **Custo Mensal/Anual** da sua planilha para a planilha do gráfico.
  - Some os totais e **altere o valor total manualmente** nos slides.

<br/>

![image](https://github.com/user-attachments/assets/1933fb8c-6a36-44d0-8171-aa01c6f89317)

<br/>

![image](https://github.com/user-attachments/assets/3a063b8c-01c4-4dce-8394-af0b2c20ac0d)


<br/>

![image](https://github.com/user-attachments/assets/e54b7212-441a-44c1-9db0-7342c030f945)

<br/>

![image](https://github.com/user-attachments/assets/b029885e-97ef-4ca4-aded-dfea58f7b554)



<br/>

![image](https://gist.github.com/user-attachments/assets/b620ac1d-ea05-4044-8640-e28a0ae113a6)

<br/>

![image](https://gist.github.com/user-attachments/assets/346ddca2-7d94-4007-9d23-451d8a999e5f)

<br/>

![image](https://gist.github.com/user-attachments/assets/d02f841d-99ae-4cee-bf6d-3a0c06244eac)

<br/>

![image](https://gist.github.com/user-attachments/assets/ad5feffc-08d8-4326-918a-9b48565ab8ff)

<br/>


### 11. Apresente seu Projeto!

Com a apresentação pronta, você está preparado para explicar os custos, os benefícios do modelo de nuvem (OPEX vs. CAPEX) e defender a viabilidade do projeto. É hora de **vender o seu peixe!**
