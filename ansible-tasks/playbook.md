# Hands-on: Playbooks

Nas tarefas anteriores deste módulo, criamos manualmente dois hosts (`host01` e `host02`), que foram removidos no último *hands-on*. 

Agora, precisaremos novamente de servidores de exemplo para continuar nossas práticas com **Playbooks**.

Mas por que os excluímos?

Porque este é o momento ideal para colocar em prática os conhecimentos adquiridos no módulo de **Terraform**! 

Vamos reprovisionar automaticamente dois hosts, reforçando o uso de infraestrutura como código na nossa jornada DevOps.

Este *Hands-On* será dividido em **duas partes**:

- **Parte 01** – Provisionamento das instâncias utilizando **Terraform**
- **Parte 02** – Instalação do **Nginx** via **Ansible ‘ad-hoc command’** e também com **Ansible ‘Playbook’**

---

---

# Parte 01 - Provisionamento das instâncias utilizando Terraform

## Provisionamento dos ‘host01’ & ‘host02’ usando Terraform

Vamos provisionar duas instâncias com a distribuição Linux Red Hat Enterprise Linux (RHEL).

## Passo 01 - Criando Arquivo Main.tf

```bash
cd ansible-tasks
ls
touch main.tf
```

📄 **[main.tf](http://main.tf)** 

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "host01" {
  ami           = "ami-0c15e602d3d6c6c4a"     # Red Hat Enterprise Linux version 9 
  instance_type = "t2.micro"
	key_name = "tcb-ansible-key"
  vpc_security_group_ids = [aws_security_group.secgroup.id]
}

resource "aws_instance" "host02" {
  ami           = "ami-0c15e602d3d6c6c4a"    # Red Hat Enterprise Linux version 9 
  instance_type = "t2.micro"
	key_name = "tcb-ansible-key"
  vpc_security_group_ids = [aws_security_group.secgroup.id]
}

resource "aws_security_group" "secgroup" {

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # It means "All Protocols/Ports"
    security_groups = ["<YOUR_IDE/EC2_SEC_GROUP_ID>"]   # Update this field!
  }

	egress {
	    from_port   = 0
	    to_port     = 0
	    protocol    = "-1"  # It means "All Protocols/Ports"
	    cidr_blocks = ["0.0.0.0/0"]
	  }

}

output "host01_private_ip" {
  value = aws_instance.host01.private_ip    # Update "host" inventory file
}

output "host02_private_ip" {
  value = aws_instance.host02.private_ip    # Update "host" inventory file
}
```

## Passo 02 - Executando Terraform | Testando Comunicação

```bash
**terraform fmt
terraform init
terraform validate
terraform plan 
terraform apply**

# Atualizando arquivo “hosts” | Atualize IP & Usuário (ec2-user)
****host01 ansible_host=x.x.x.x ansible_user=ec2-user # RHEL Linux
host02 ansible_host=x.x.x.x ansible_user=ec2-user # RHEL Linux

****# Testando Comunicação
**ansible all**   # yes/no for each host | It add IP and Public Key at 'kwon_hosts' file
**ctrl + C**

ls ~/.ssh
cat ~/.ssh/known_hosts
ssh-keyscan
```

<aside>
💡

O comando `ssh-keyscan` é uma ferramenta utilizada para **coletar a chave pública SSH de um ou mais hosts remotos**, sem estabelecer uma sessão SSH interativa. 
Ele é especialmente útil para **preencher ou atualizar o arquivo `known_hosts`** com as chaves dos servidores que você deseja acessar via SSH.

</aside>

## Passo 03 - Destruindo e Recriando com Provisioners

```bash
**terraform destroy**
```

## Passo 04 - Usando “Provisioner” para configurar IP Privado no Arquivo “known_hosts”

<aside>
💡

Esse comando coleta chave pública e a adiciona no arquivo `known_hosts`, evitando o prompt de verificação na primeira vez que se conecta via `ssh`.

</aside>

```hcl

resource "aws_instance" "host01" {
  ami           = "ami-026ebd4cfe2c043b2"     
  instance_type = "t2.micro"
	key_name = "tcb-ansible-key"
  vpc_security_group_ids = [aws_security_group.secgroup.id]

	provisioner "local-exec" {
	  command = "sleep 30; ssh-keyscan ${self.private_ip} >> ~/.ssh/known_hosts"
	}

}

resource "aws_instance" "host02" {
  ami           = "ami-026ebd4cfe2c043b2"    # RHEL
  instance_type = "t2.micro"
	key_name = "tcb-ansible-key"
  vpc_security_group_ids = [aws_security_group.secgroup.id]

	provisioner "local-exec" {
	  command = "sleep 30; ssh-keyscan ${self.private_ip} >> ~/.ssh/known_hosts"
	}

}
```

## Passo 05 - Recriando Recursos | Testando Comunicação

```bash
**terraform apply**
```

- Atualize o arquivo “hosts” e teste novamente a comunicação!
    
    ```bash
    # Validando atualização do arquivos 'known_host'
    cat ~/.ssh/known_hosts
    tail ~/.ssh/known_hosts
    
    # Atualizando arquivo 'hosts'
    host01 ansible_host=x.x.x.x ansible_user=ec2-user # RHEL Linux
    host02 ansible_host=x.x.x.x ansible_user=ec2-user # RHEL Linux
    
    ****# Testando Comunicação
    **ansible all** 
    ```
    

## Passo 06 - Destruindo os Recursos

```bash
# Na parte 02, vamos recriar esses recursos!
**terraform destroy**
```

🔒 ***Close Remote Connection***

**⛔ Stop Your IDE/EC2 Instance!**

---

# Parte 02 - Instalação do “nginx” via Ansible Ad-hoc & Ansible Playbook

## Instalando ‘nginx’ via “Ansible Ad-hoc”

- Recriar os Recursos:  `terraform apply`
- Atualizar Inventário: `hosts`
- Comunicação Ok: `ansbile all`

```bash
# Update and Install 'nginx':
ansible all -m yum -a "update_cache=yes name=nginx state=latest" -b

# Check 'nginx' service status | "apache" starts its service automatically
ansible all -m shell -a "systemctl status nginx"    # inactive (dead)

# Start 'nginx':
ansible all -m shell -a "systemctl start nginx" -b

# Check 'nginx' service status again
ansible all -m shell -a "systemctl status nginx"

# Validate 'nginx'
Public DNS or Public IP

# Remove 'nginx':
ansible all -m yum -a "name=nginx state=absent" -b
```

## Instalando ‘nginx’ via Playbook

### Vantagens de usar Playbook:

| Comandos Ad-hoc ⚙️ | Playbooks 📘 |
| --- | --- |
| ✅ Rápidos para tarefas pontuais | ✅ Ideal para tarefas repetitivas e complexas |
| ✅ Sem necessidade de arquivo | ✅ Mais organizados e documentados |
| ❌ Difícil de reaproveitar | ✅ Reutilizáveis e versionáveis (Git etc.) |
| ❌ Pouca legibilidade em automações | ✅ Fáceis de ler, manter e automatizar |
- Use **comandos ad-hoc** para testes ou tarefas únicas.
- Use **Playbooks** quando quiser automação **consistente**, **escalável** e **repetível**.

- **Na pasta `ansible-tasks` criar arquivo `install-webserver.yml`**

```bash
cd ansible-tasks
touch **install-webserver.yml**
```

📄 install-webserver.yml

```yaml
# Título da execução do playbook (aparece no terminal)
- name: Installing & starting ngnix

  # Define os hosts-alvo (todos os do inventário)
  hosts: all

  # Garante que os comandos sejam executados com privilégios de superusuário (sudo)
  become: yes

  # Lista de tarefas a serem executadas
  tasks:

    # 1ª tarefa: Instala o nginx usando o YUM (usado em sistemas RHEL/CentOS)
    - name: Installing nginx
      yum:
        update_cache: yes   # Atualiza a lista de pacotes antes de instalar
        name: nginx         # Nome do pacote a ser instalado
        state: latest       # Garante que será instalada a versão mais recente disponível

    # 2ª tarefa: Inicia o serviço do nginx usando o comando shell
    - name: Starting nginx
      shell: systemctl start nginx
      # OBS: Módulos `service` ou `systemd` fornece maior controle e idempotência!

    # 3ª tarefa: Habilita o nginx para iniciar automaticamente durante o boot
    - name: Enable the NGINX service during boot process
      service:
        name: nginx         # Nome do serviço
        enabled: yes        # Habilita o serviço na inicialização do sistema

```

### Executando o ‘Ansible Playbook’

```bash
**ansible-playbook** **install-webserver.yml**
```

## Destruindo Recursos

```bash
terraform destroy
```

