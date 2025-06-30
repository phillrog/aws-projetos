## Pré-requisitos

- **Excluir instâncias EC2 | Exceto a IDE/EC2**
- **Excluir Security Groups que não estejam em uso!**
    - **Valide a Security Group associada à sua IDE/EC2**

- **Criar 02 AWS EC2 Instances**
    - `host01`: Debian (Debian Linux Distribution) - User: `admin` user | Package manager: `apt`
        
        No momento da gravação, está é a versão mais atualizada:
        
        ![image.png](attachment:5a4832ca-5ed2-4011-9e4b-5685fe1f3a41:image.png)
        
    - `host02`: RHEL (Red Hat Enterprise Linux Distribution) - User: `ec2-user` | Package manager: `yum`
        
        No momento da gravação, está é a versão mais atualizada:
        
        ![image.png](attachment:5b5ed2dc-196e-47ef-a156-17771ad80aa6:image.png)
        
    
    ---
    
    - Instance Type: `t2.micro`
    - SSH Key (.pem): `tcb-ansible-key` | *Use a mesma SSH Key para as duas EC2!*
    - VPC: `Default`
    - Security Group: `launch-wizard-X` (SSH/22) | *Use a mesma SG para as duas EC2!*

## **Passo 01 - Instalando Ansible na IDE/EC2**

https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

<aside>
💡

**O Ansible foi desenvolvido em Python! 🐍**

Seu núcleo e módulos são escritos em Python, e tanto o nó de controle quanto os hosts gerenciados geralmente precisam ter Python instalado. No entanto, os playbooks são escritos em YAML, então não é necessário saber Python para usar o Ansible.

</aside>

# Check Python and PIP installed version
python3 --version
pip3 --version
ansible --version

# Update the OS and install Python and PIP if needed
sudo yum update -y
sudo yum install python
sudo yum install pip

# Install Ansible
python3 -m pip install --user ansible

ansible --version
ansible

## **Passo 03 - Adicionando Regra na Security Group `launch-wizard-x`**

- Permita que todo o tráfego de entrada proveniente da SG associada à instância EC2  (IDE).
    
    ![image.png](attachment:f2584400-6e8f-4a5a-968a-5c4237d7b1fc:image.png)
    
    ***Esta ação permite que nó de controle (EC2-IDE) e os Hosts Gerenciados (host01 e host02) possam se comunicar!***
    
    Teste novamente: 
    
    ```bash
    ping PRIVATE-IP_host01 -c3
    ping PRIVATE-IP_host02 -c3
    ```

Passo 04 - Teste de Conexão SSH
Faça upload da chave SSH Key .pem tcb-ansible-key  para EC2 (IDE).
Na console da EC2 é possível identificar qual usuário devemos usar (depende do tipo de SO da EC2).
EC2 Console | Selecione a EC2 | Connect | EC2 Instance Connect
# Upload the private key to EC2/IDE under /home/ec2-user
# Test the SSH connection with host01 and host02 private IP addresses
ssh -i tcb-ansible-key.pem admin@PRIVATE-IP_host01

# Notice there will be an error as the permission is wrong. This is a common issue you need to be aware of.
# Change the permission and try again
ls -l tcb-ansible-key.pem
chmod 400 tcb-ansible-key.pem
ls -l tcb-ansible-key.pem

ssh -i tcb-ansible-key.pem admin@PRIVATE-IP_host01
cat /etc/*rel*

ssh -i tcb-ansible-key.pem ec2-user@PRIVATE-IP_host02
cat /etc/*rel*    

# Inventário & Ad-hoc

✅ Executar comandos ad-hoc do Ansible
✅ Criar um arquivo de inventário com os dois hosts provisionados anteriormente
✅ Testar a comunicação utilizando o módulo ping
✅ Explorar e entender o arquivo de configuração do Ansible (ansible.cfg)

Passo 01 - Criando Arquivo de Inventário
Criar uma pasta: ansible-tasks
mkdir ansible-tasks && cd ansible-tasks
​
Dentro da pasta criada, criar arquivo: hosts
touch hosts
​
Inserir os IPs Privados dos Hosts (host01 e host02) 
Passo 02 - Teste de Comunicação Usando o Módulo 'ping' através de Comandos 'ad-hoc’ do Ansible
A execução ad-hoc no Ansible é feita usando diretamente o comando ansible (sem o -playbook), para realizar tarefas pontuais e simples, geralmente sem necessidade de um arquivo YAML (.yml).
# Let's test the connectivity to the managed hosts using Ansible module ping
ansible -i hosts all -m ping

# You will see an error because we did not specify the username nor the SSH key. Let's fix it now.
# Ansible Ping do also SSH Connect
$ ERROR: Permission denied

# Moving the ssh file
mv ../tcb-ansible-key.pem .
ls

# Let's inform the SSH Key:
ansible -i hosts all -m ping -e "ansible_ssh_private_key_file=tcb-ansible-key.pem"

# For 'ec2-user' user it will work (RHEL Linux)

# Let's inform the user names
ansible -i hosts all -u admin -m ping      # Good for Debian
ansible -i hosts all -u ec2-user -m ping   # Good for RHEL

And now?!
​
Passo 03 - Adicionando Variáveis  ‘user’, ‘alias’ e ‘group’ no 'Inventory File'
host01 ansible_host=172.31.83.150 ansible_user=admin
host02 ansible_host=172.31.85.179 ansible_user=ec2-user

ansible -i hosts host01 -m ping -e "ansible_ssh_private_key_file=tcb-ansible-key.pem"
ansible -i hosts all -m ping -e "ansible_ssh_private_key_file=tcb-ansible-key.pem"


# Variables Group
[all:vars]
ansible_ssh_private_key_file=tcb-ansible-key.pem

ansible -i hosts all -m ping 


[webservers]
host01

ansible -i hosts webservers all -m ping 

​
Passo 04 - Ansible Configuration File
# Exploring the Ansible config
ansible-config    # No Config File
ansible --version [ config file = None ]

# Generating a sample ansible.cfg file
# https://github.com/ansible/ansible/blob/stable-2.9/examples/ansible.cfg
touch ansible.cfg # Paste the content of the Github ansible.cfg example
ansible --version [ config file = ansible.cfg ]

# Disabling 'deprecation_warnings' to keep logs clean for study purposes
deprecation_warnings = False

ansible -i hosts all -m ping 

---

# Setting up 'ping' module as default module:
# Search for "default module name" or "module_name"
[defaults]
module_name=ping

ansible -i hosts all 

---
# Setting up 'host' inventory file path:
# Search for "inventory" or "/etc/ansible/hosts"
[defaults]
inventory=/etc/ansible/hosts,/home/ec2-user/ansible-tasks/hosts

ansible all 
ansible webservers 

---
# Exploring a little more Ansible commands
ansible-inventory --graph
ansible-config
ansible-config dump # In yellow: indicates values modified from the default.
ansible-config dump --only-changed

# Creating an empty ansible.cfg with all option disabled
# ansible-config init --disabled > ansible.cfg

## Documentação

[Ansible Configuration (latest)](https://docs.ansible.com/ansible/latest/reference_appendices/config.html)

[Ansible Configuration (2.9)](https://docs.ansible.com/ansible/2.9/reference_appendices/config.html)

[Ansible Configuration Example on Github](https://github.com/ansible/ansible/blob/stable-2.9/examples/ansible.cfg)