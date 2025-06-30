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