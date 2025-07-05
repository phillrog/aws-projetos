# Hands-on: Conditionals

Chegou o momento de colocarmos as mãos na massa! 

Vamos explorar não só as estruturas condicionais no Ansible, mas também os Ansible Facts — uma poderosa funcionalidade que permite adaptar a execução de playbooks com base nas características reais dos hosts gerenciados.

## Pré-requisito:

### Provisionar 03 Instâncias e Atualizar Arquivo de Inventário

- Adicionando ‘Recurso’ e ‘Output’ para ‘host03 (Debian Linux)’ no arquivo ‘main.tf’:

```hcl
resource "aws_instance" "host03" {
  ami           = "ami-0779caf41f9ba54f0"     # Debian 12
  instance_type = "t2.micro"
	key_name = "tcb-ansible-key"
  vpc_security_group_ids = [aws_security_group.secgroup.id]

	provisioner "local-exec" {
	  command = "sleep 30; ssh-keyscan ${self.private_ip} >> ~/.ssh/known_hosts"
	}

}

---
output "host03_private_ip" {
  value = aws_instance.host03.private_ip
}
```

- ***Executando Terraform***

```bash
cd ansible-tasks
**terraform apply** -auto-approve
```

- ***Atualizando Arquivo Inventário***
    
    ```bash
    host01 ansible_host=x.x.x.x ansible_user=ec2-user
    host02 ansible_host=x.x.x.x ansible_user=ec2-user
    host03 ansible_host=x.x.x.x ansible_user=admin
    
    # Testando Comunicação
    ansible all 
    ```
    
    <aside>
    💡
    
    > O inventário automático no Ansible permite integrar ambientes em nuvem de forma dinâmica, obtendo dados em tempo real sobre os hosts. Isso simplifica o gerenciamento de infraestrutura escalável e garante playbooks mais precisos e automatizados em ambientes DevOps.
    > 
    </aside>
    

---

## Passo 01 - Explorando ‘Ansible Facts’

<aside>
💡

> Ansible Facts são dados coletados automaticamente sobre os hosts, permitindo que os playbooks se adaptem dinamicamente ao ambiente. Isso torna a automação mais inteligente e eficiente em cenários DevOps.
> 
</aside>

```bash
# O nome 'gather_facts' é apenas um alias para o módulo 'setup'
ansible host01 -m gather_facts
ansible host01 -m setup

# OS Name
ansible host01 -m setup -a "filter=ansible_distribution"
ansible host02 -m setup -a "filter=ansible_distribution"
ansible host03 -m setup -a "filter=ansible_distribution"

# OS Version
ansible host01 -m setup -a "filter=ansible_distribution_version"

# IP Address
ansible host01 -m setup -a "filter=ansible_default_ipv4"

# Phyton Version
ansible host01 -m setup -a "filter=ansible_python_version"
ansible host03 -m setup -a "filter=ansible_python_version"

# Gattering 'facts' of all hosts
ansible all -m setup | grep -e 'ansible_hostname\|ansible_os_family\|ansible_python_version\|ansible_pkg_mgr'

```

<aside>
💡

### Exemplos de ‘facts’ | ‘ansible variables’:

```
ansible_eth0
ansible_fqdn
ansible_pkg_mgr
ansible_nodename
ansible_hostname
ansible_os_family
ansible_memtotal_mb
ansible_architecture
ansible_processor_count
discovered_interpreter_python
```

</aside>

## Passo 02 - Trabalhando com ‘Ansible Conditionals’

- ***Criar uma nova playbook*** `install-webserver-conditional.yml`

```yaml
- name: Installing Apache
  hosts: all
  become: yes
  tasks:
    - name: Setup Apache - Debian
      apt:
        update_cache: yes
        name: apache2
        state: present
      when: ansible_distribution == 'Debian'

    - name: Setup Apache - RHEL
      yum:
        name: httpd
        state: present
      when: ansible_distribution == 'RedHat'
```

<aside>
💡

### Você pode usar o operador "in" para incluir mais valores:

```bash
ansible_distribution in ["Debian", "Ubuntu"]
```

</aside>

- ***Execute o Ansible Playbook:***

```bash
**ansible-playbook** install-webserver-conditional.yml
```

- ***Checking Apache Service Status:***
    
    ```bash
    # Checking 'Apache' Status
    ansible host01 -m shell -a "systemctl status httpd"   # Not Running
    ansible host02 -m shell -a "systemctl status httpd"   # Not Running
    ansible host03 -m shell -a "systemctl status apache2" # Running
    
    # Starting 'Apache' service
    ansible host01 -m shell -a "systemctl start httpd" -b
      host01 | CHANGED | rc=0 >>  # The execution modified the state of the system.
    ansible host02 -m shell -a "systemctl start httpd" -b
      host02 | CHANGED | rc=0 >>  # The execution modified the state of the system.
    
    # Checking 'Apache' Status
    ansible host01 -m shell -a "systemctl status httpd"
    ansible host02 -m shell -a "systemctl status httpd"
    
    # Try starting the 'Apache' service again — the shell does not ensure idempotence.
    ansible host01 -m shell -a "systemctl start httpd" -b
      host01 | CHANGED | rc=0 >>  # The execution modified the state of the system.
    ansible host02 -m shell -a "systemctl start httpd" -b
      host02 | CHANGED | rc=0 >>  # The execution modified the state of the system.
    ```
       

## Passo 03 - Criar e Copiar Pagina HTML para Host02

- **Acesse o IP Público / DNS do Host02 e valide que o Apache esteja funcionando!**
    

- **Criar uma página html de exemplo `index.html` e copiar para `host02`**

```html
<!DOCTYPE html>
<html>
<head>
    <style>
        body {
            background-color: #000000;
            color: #ffffff;
            font-family: Arial, sans-serif;
        }

        .container {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            flex-direction: column;
            text-align: center;
        }

        img {
            max-width: 300px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <img src="image.png" alt="Your Image">
        <h1>Parabéns mano! Muito BOM!!!</h1>
    </div>
</body>
</html>
```

- ***Copiando Arquivo*** `index.html` ***para*** `host02`

```bash
**ansible** host02 -m **copy** -a "src=index.html dest=/var/www/html" -b
```

- Acesse novamente IP Público do Host02!

### Passo 04 - Destruindo Recursos

```bash
**terraform destroy** -auto-approve
```

🔒 ***Close Remote Connection***