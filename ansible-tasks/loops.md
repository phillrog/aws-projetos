# Hands-on: Loops

Neste hands-on, vamos aprender a usar loops no Ansible para repetir tarefas de forma prática e eficiente, aplicando ações como instalação de pacotes, criação de usuários e configuração de diretórios sem duplicar código.

<aside>
💡

A estrutura básica de loop utiliza o parâmetro `loop`, que substitui versões mais antigas como `with_items`.

</aside>

## Pré-requisito:

### Provisionar 03 Instâncias e Atualizar Arquivo de Inventário

```bash
cd ansible-tasks
**terraform apply** -auto-approve
**ansible** all
```

---

## Passo 01 - Criando Arquivos e Diretórios SEM usar Diretivas de ‘Loop’

`create-files-folders.yml`

```yaml
- hosts: all
  tasks:
    - name: Creating Folder
      file:
        path: /home/{{ ansible_user }}/folder01
        state: directory

    - name: Creating File
      file:
        path: /home/{{ ansible_user }}/folder01/file01
        state: touch
```

- Executando ‘Ansible Playbook’

```bash
**ansible-playbook** create-files-folders.yml

ansible host01 -m command -a "ls /home/ec2-user"
ansible host01 -m command -a "ls /home/ec2-user/folder01"
```

## Passo 02 - Criando Múltiplos Diretórios com a Diretiva "with_items"

```yaml
- hosts: all
  tasks:
    - name: Creating Folder
      file:
        path: /home/{{ ansible_user }}/{{ item }}
        state: directory
      with_items:
        - folder01
        - folder02
        - folder03
```

- Executando ‘Ansible Playbook’

```bash
**ansible-playbook** create-files-folders.yml

ansible host01 -m command -a "ls /home/ec2-user"
```

## Passo 03 - Removendo Diretórios:

- 'state: absent'

```yaml
- hosts: localhost
  tasks:
    - name: Creating Folder
      file:
        path: /home/{{ ansible_user }}/{{ item }}
        **state: absent**
      with_items:
        - folder01
        - folder02
        - folder03
```

- Executando ‘Ansible Playbook’

```bash
**ansible-playbook** create-files-folders.yml

ansible host01 -m command -a "ls /home/ec2-user"
```

## Passo 04 - Criando Múltiplos Diretórios com a Diretiva "loop"

```yaml
- hosts: localhost
  tasks:
    - name: Creating Folder
      file:
        path: /home/{{ ansible_user }}/{{ item }}
        state: directory
      loop:
        - folder01
        - folder02
        - folder03
```

- Executando ‘Ansible Playbook’

```bash
**ansible-playbook** create-files-folders.yml

ansible host01 -m command -a "ls /home/ec2-user"
```

## Passo 05 - Removendo Diretórios:

- 'state: absent'

```yaml
- hosts: localhost
  tasks:
    - name: Creating Folder
      file:
        path: /home/{{ ansible_user }}/{{ item }}
        **state: absent**
      loop:
        - folder01
        - folder02
        - folder03
```

- Executando ‘Ansible Playbook’

```bash
**ansible-playbook** create-files-folders.yml

ansible host01 -m command -a "ls /home/ec2-user"
```

## Passo 06 - Criando Arquivos nos Diretórios

```yaml
- hosts: all
  tasks:
    - name: Creating Folder
      file:
        path: /home/{{ ansible_user }}/{{ item }}
        state: directory
      loop:
        - folder01
        - folder02
        - folder03

    - name: Creating files
      file:
        path: /home/{{ ansible_user }}/{{ item.dir }}/{{ item.file }}
        state: touch
      loop:
        - { dir: "folder01", file: "file01"}
        - { dir: "folder02", file: "file02"}
        - { dir: "folder03", file: "file03"}
```

- Executando ‘Ansible Playbook’

```bash
**ansible-playbook** create-files-folders.yml

ansible host01 -m command -a "ls /home/ec2-user"
ansible host01 -m command -a "ls /home/ec2-user/folder03"
```

## Passo 07 - Removendo Arquivos e Diretórios

- 'state: absent'

```yaml
- hosts: localhost
  tasks:
    - name: Creating Folder
      file:
        path: /home/{{ ansible_user }}/{{ item }}
        state: **absent**
      loop:
        - folder01
        - folder02
        - folder03

    - name: Creating files
      file:
        path: /home/{{ ansible_user }}/{{ item.dir }}/{{ item.file }}
        state: **absent**
      with_items:
        - { dir: "folder01", file: "file01"}
        - { dir: "folder02", file: "file02"}
        - { dir: "folder03", file: "file03"}
```

- Executando ‘Ansible Playbook’

```bash
**ansible-playbook** create-files-folders.yml

ansible host01 -m command -a "ls /home/ec2-user"
```

## Passo 08 - Destruindo Recursos

```bash
**terraform destroy** -auto-approve
```

🔒 ***Close Remote Connection***