# Hands-on: Variables

**Neste hands-on, vamos reforçar o uso de variáveis no Ansible — um recurso essencial para automação e padronização de ambientes.**

Já trabalhamos com variáveis no arquivo de inventário (`hosts`), mas agora o foco é entender como aplicá-las de forma mais estratégica dentro dos nossos playbooks.

Vamos colocar a mão na massa usando a nossa EC2 (IDE) e o módulo `debug` para inspecionar valores em tempo de execução. 

---

## Passo 01 - Revisando Variáveis do Arquivo Hosts

```
host01 **ansible_host**=172.31.92.25 **ansible_user**=ec2-user
host02 **ansible_host**=172.31.81.164 **ansible_user**=ec2-user

[all:**vars**]
**ansible_ssh_private_key_file**=tcb-ansible-key.pem

[webservers]
host01
```

## Passo 02 - Uso de  Variáveis em Arquivo YAML | Playbook

📝 variables-example.yml

```bash
touch variables-example.yml
```

```yaml
- name: Example Playbook
  hosts: localhost        # Executa localmente na máquina onde o Ansible está rodando

  vars:                   # Declaração de variáveis 'key: value'
    http_port: 80         
    https_port: 443       

    packages:             # Declaração de variáveis formato de 'Lista'
      - git
      - mysql-client
      - curl
      - wget

    appserver:            # Declaração de variáveis formato de 'Dicionário'
      hostname: webapp01
      ipaddress: 192.168.1.202
      os: Windows Server 2019

  tasks:                  
    - name: Displaying Key-Value Variables Values
      debug:              
        var: http_port, https_port

    - name: Displaying Package List Variables Values
      debug:              
        var: packages

    - name: Display 'appserver' Dictionary Variable Values
      debug:              
        var: appserver
```

- Executando Playbook
    
    ```bash
    **ansible-playbook** variables-example.yml
    ```
    

## Passo 03 - Usando `msg` com Interpolação

```yaml
    - name: Display HTTP and HTTPS ports
      debug:
        msg: "HTTP: {{ http_port }}, HTTPS: {{ https_port }}"

```

## Passo 04 - Outro Exemplo de Uso de  Variáveis em Arquivo YAML | Playbook

📝 another-variables-example.yml

```yaml
- name: Demonstrando variáveis com Ansible (Localhost)
  hosts: localhost
  connection: local  # Forçar conexão Local e não 'SSH'
  gather_facts: no   # Não coleta informações do sistema

  vars:
    nome_app: "MeuApp"
    versao: "1.0.2"
    desenvolvedores:
      - Ana
      - Bruno
      - Carla

    ambiente:
      tipo: "Desenvolvimento"
      sistema: "Ubuntu 22.04"
      ip: "127.0.0.1"

  tasks:

    - name: Exibir nome da aplicação e versão
      debug:
        msg: "Aplicação: {{ nome_app }} | Versão: {{ versao }}"

    - name: Listar desenvolvedores do projeto
      debug:
        var: desenvolvedores

    - name: Exibir informações do ambiente
      debug:
        msg: >
          Ambiente: {{ ambiente.tipo }},
          Sistema: {{ ambiente.sistema }},
          IP: {{ ambiente.ip }}

    - name: Criar arquivo de log com dados da aplicação
      copy:
        dest: ./log_app.txt
        content: |
          Aplicação: {{ nome_app }}
          Versão: {{ versao }}
          Ambiente: {{ ambiente.tipo }}
          Sistema: {{ ambiente.sistema }}
          Desenvolvedores: {{ desenvolvedores | join(', ') }}
```

- Tarefa ‘Gathering Facts’ não foi executada!
- Valide as informações do arquivo ‘log_app.txt’

🔒 ***Close Remote Connection***

**⛔ Stop Your IDE/EC2 Instance!**

***TCB*** 🚀

---

# Going Further 🚀

No Ansible, variáveis são fundamentais para tornar os playbooks dinâmicos e reutilizáveis. 

Elas permitem a personalização do comportamento de tarefas e o controle da configuração de forma flexível. 

## **O que são Variáveis no Ansible?**

Variáveis no Ansible armazenam valores que podem ser reutilizados em tarefas, templates, handlers e outros componentes. 

Elas seguem a sintaxe YAML e podem ser acessadas com `{{ nome_variavel }}`.

## **Tipos de Variáveis**

### 1. **Variáveis definidas em `vars`**

Diretamente no playbook:

```yaml
- hosts: servidores
  vars:
    pacote: nginx
  tasks:
    - name: Instala pacote
      apt:
        name: "{{ pacote }}"
        state: present
```

### 2. **Variáveis de Inventário**

Podem ser definidas em arquivos INI/YAML:

```
[webservers]
192.168.1.10 app_env=prod
```

Ou em `group_vars/` ou `host_vars/` em estrutura de diretório.

### 3. **Variáveis de Fato (Facts)**

São coletadas automaticamente com o módulo `setup`:

```yaml
- debug:
    msg: "Sistema operacional: {{ ansible_distribution }}"
```

### 4. **Variáveis em linha de comando**

Passadas com `--extra-vars` ou `-e`:

```bash
ansible-playbook site.yml -e "pacote=nginx"

```

### 5. **Variáveis em Templates (Jinja2)**

Utilizadas em arquivos `.j2`:

```
Servidor: {{ ansible_hostname }}

```

### 6. **Variáveis com `set_fact`**

Criadas dinamicamente durante a execução:

```yaml
- set_fact:
    caminho_log: "/var/log/{{ pacote }}.log"

```

### 7. **Variáveis de Registro (`register`)**

Armazenam saída de tarefas:

```yaml
- name: Checar se serviço está ativo
  shell: systemctl is-active nginx
  register: status_nginx

- debug:
    msg: "Status: {{ status_nginx.stdout }}"

```

## ⚠️ **Precedência das Variáveis (de menor para maior)**

1. `defaults/main.yml` de roles
2. Variáveis de inventário (grupos, hosts)
3. `vars/main.yml` de roles
4. Variáveis definidas no playbook
5. `set_fact`
6. `register`
7. Linha de comando (`e`) – tem a **maior precedência**

## ✅ **Boas Práticas**

- Use nomes descritivos para variáveis.
- Agrupe variáveis por contexto (host, grupo, role).
- Use `group_vars` e `host_vars` para manter organização.
- Evite sobrescrever variáveis entre camadas diferentes.
- Utilize o comando `ansible -m setup <host>` para explorar facts.