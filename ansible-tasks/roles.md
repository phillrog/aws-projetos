# Hands-on: Roles

**Ansible Roles** permitem organizar playbooks de forma modular e reutilizável, separando tarefas e recursos em estruturas padronizadas que facilitam a manutenção e a colaboração.

Com `roles`, você pode, por exemplo, criar um papel específico para configurar um servidor web, outro para gerenciar usuários e outro para aplicar hardening, reutilizando essas funções em diferentes ambientes.

**Neste hands-on, vamos instalar o serviço Apache em um grupo de hosts denominado `webservers` e configurar uma página simulando uma aplicação web.** 

**A diferença é que, desta vez, realizaremos tudo utilizando *roles* do Ansible, aplicando uma abordagem mais estruturada, modular e reutilizável.**

---

## Explorando Documentação

https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html

https://docs.ansible.com/ansible/latest/galaxy/dev_guide.html

### Ansible Galaxy

**Ansible Galaxy** é a plataforma oficial para compartilhar e buscar *roles* e *collections* criadas pela comunidade Ansible. Com ela, você pode reutilizar componentes prontos para automatizar configurações, implantar aplicações e muito mais, economizando tempo e esforço.

Usando o comando `ansible-galaxy`, é possível:

- **Instalar roles e collections** diretamente de repositórios públicos ou privados:
    
    ```bash
    **ansible-galaxy** install nome_da_role
    ```
    
- **Criar a estrutura de uma nova role** com:
    
    ```bash
    **ansible-galaxy** init nome_da_role
    ```
    

*Ansible Galaxy promove o uso de boas práticas e a padronização na automação em projetos com Ansible.*

---

## Pré-requisito:

- **Provisionar 03 Instâncias e Atualizar Arquivo de Inventário**

```bash
cd ansible-tasks
**terraform apply** -auto-approve
**ansible** all
```

- **Atualizar Grupo ‘webservers’:**

```
**[webservers]**
**host01
host02**
```

## Passo 01 - Criando ‘Ansible Role’

```bash
**ansible-galaxy** **role init** roles/webserver
ls
# check folder roles/webserver structure
```

## Passo 02 - Definição das Tarefas

- Atualize o arquivo `roles/webserver/tasks/main.yml`

```yaml
- name: Installing Apache
  yum:
    name: httpd
    state: present

- name: Starting Apache
  service:
    name: httpd
    state: started
    enabled: true

- name: Copying files
  copy: src=devops.png dest=/var/www/html/

- name: Generating Template
  template:
    src: index.html.j2
    dest: /var/www/html/index.html
  notify:
    - Restarting Apache
```

**Task: Generating Template**

- **Usa um template Jinja2** chamado `index.html.j2` (que pode conter variáveis dinâmicas) localizado no diretório `templates/` da role.
- **Gera um arquivo real** chamado `index.html` no caminho `/var/www/html/`, substituindo variáveis pelo conteúdo final.
- Após gerar o arquivo, **aciona um handler** chamado `Restarting Apache` — isso significa que, se o conteúdo do arquivo mudar, o Apache será reiniciado para aplicar a nova configuração.

<aside>
💡

Essa abordagem garante que o Apache só seja reiniciado **quando houver realmente uma alteração no conteúdo da página**.

</aside>

Próximas ações:

- Copiar arquivo devops.png
- Criar Template
- Criar Handler

## Passo 03 - Copiar Arquivo ‘devops.png’ para Pasta Files

- Atualize a imagem `devops.png` na pasta `roles/webserver/files`

## Passo 04 - Criando Template

- Crie um arquivo template `index.html.j2` em `roles/webserver/templates`

```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body {
      background-color: #000;
      color: #fff;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
      font-family: Arial, sans-serif;
    }

    .content {
      text-align: center;
    }
  </style>
</head>
<body>
  <div class="content">
    <b> Hello Bootcamper!</b>

    <h1> This is a webserver running in an EC2 Instance: {{ ansible_hostname }}</h1>
    <h4> Powered by {{ cloud_provider }}</h4>

    <img src="devops.png" alt="DevOps Image">
  </div>
</body>
</html>
```

<aside>
💡

A variável **{{ ansible_hostname }}** é default do Ansible (facts).

A variável **{{ cloud_provider }}** precisamos criar!

</aside>

## Passo 05 - Criando Variável Default

- Atualize o arquivo `roles/webserver/defaults/main.yml`

```yaml
cloud_provider: "aws"
```

## Passo 06 - Criando Handle

- Atualize o arquivo `roles/webserver/handlers/main.yml`

```yaml
- name: Restarting Apache
  service:
    name: httpd
    state: restarted
```

## Passo 07 - Criando Playbook

- Crie a playbook `setup-webserver-roles.yml`
    
    ```bash
    cd ansible-tasks
    touch setup-webserver-roles.yml
    ```
    

```yaml
- name: Setting up Apache as Webserver
  hosts: webservers
  become: true
  roles:
    - webserver
```

## Passo 08 - Executando Playbook

- Execute o ‘Ansible Playbook’

```
**ansible-playbook** setup-webserver-roles.yml
```

## Passo 09 - Acessando Aplicação

- Teste o acesso ao website usando o IP público do `host01`
    - Valide IP Privado
- Teste o acesso ao website usando o IP público do `host02`
    - Valide IP Privado

## Passo 10 - Destruindo Recursos

```bash
**terraform destroy** -auto-approve
```

🔒 ***Close Remote Connection***