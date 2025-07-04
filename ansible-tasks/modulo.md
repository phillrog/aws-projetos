Hands-on: Ansible Modules

Neste hands-on, vamos explorar alguns dos principais módulos do Ansible, como command, apt, service, shell, copy e file. Esses módulos fazem parte do extenso ecossistema do Ansible, que oferece centenas de recursos prontos para uso, otimizando a automação de tarefas recorrentes, o provisionamento de infraestrutura e a configuração de serviços. A utilização adequada desses módulos permite implementar playbooks eficientes, reproduzíveis e alinhados às melhores práticas de DevOps.
Passo 01 - Explorando a Documentação
🔗 All modules — Ansible Documentation​
Uma lista extensiva e organizada de módulos Ansible que contempla recursos para automação em ambientes multi-cloud e híbridos, incluindo suporte a provedores como AWS, Azure e GCP, além de ferramentas e serviços como Docker, PostgreSQL e VMware.
Módulos Comuns e Essenciais (Core)
Módulo
Função Principal
command
Executa comandos diretamente no shell (sem interpretar)
shell
Executa comandos via shell, permitindo pipes, redirects, etc.
apt
Gerencia pacotes em sistemas Debian/Ubuntu
yum
Gerencia pacotes em sistemas RedHat/CentOS
dnf
Novo gerenciador de pacotes para RedHat/CentOS 8+
service
Controla serviços (start, stop, restart, enable, etc.)
copy
Copia arquivos do host local para o destino
template
Utiliza Jinja2 para gerar arquivos de configuração
file
Gerencia permissões, donos e estados de arquivos
lineinfile
Modifica linhas específicas em arquivos
cron
Gerencia tarefas agendadas
Módulo command
🔗 command – Execute commands on targets — Ansible Documentatio…​
✅ Principais Funcionalidades:
Executa comandos diretamente nos hosts gerenciados, de forma simples e segura. 
Não invoca um shell, como /bin/sh ou /bin/bash, o que significa que recursos como pipes (|), redirecionamentos (>, <) e expansões de variáveis ($VAR) não funcionam aqui.
Seguro e direto, ideal para comandos simples e diretos (ls, cat...).
- name: Listar arquivos de um diretório
  ansible.builtin.command: ls /var/log
​
Módulo apt 
🔗 apt – Manages apt-packages — Ansible Documentation​
O módulo apt é utilizado para gerenciar pacotes em sistemas baseados em Debian/Ubuntu, usando o gerenciador de pacotes apt.
✅ Principais Funcionalidades:
Instalação e remoção de pacotes.
Atualização da lista de repositórios (update_cache = apt-get update).
Atualização de pacotes para a última versão disponível.
Definição de versões específicas a serem instaladas.
Suporte à instalação de múltiplos pacotes ao mesmo tempo.
📌 Exemplos de Uso:
- name: Atualizar cache e instalar nginx
  ansible.builtin.apt:
    name: nginx
    state: present
    update_cache: yes
​
🛡️ Parâmetros úteis:
Parâmetro
Função
name
Nome do pacote a ser gerenciado
state
present, latest, absent, etc.
update_cache
Atualiza a lista de pacotes (apt update)
cache_valid_time
Tempo para cache ser considerado válido
⚠️ Requisitos:
Só funciona em distribuições com apt como gerenciador de pacotes (ex.: Ubuntu, Debian).
Requer permissões elevadas para instalar/remover pacotes (normalmente usado com become: yes).
Módulo service
🔗 service – Manage services — Ansible Documentation​
O módulo service permite gerenciar serviços do sistema operacional, como iniciar, parar, reiniciar e habilitar serviços para inicialização automática em sistemas Linux.
✅ Principais Funcionalidades:
Iniciar (started) ou parar (stopped) serviços.
Reiniciar serviços (restarted).
Habilitar ou desabilitar serviços no boot (enabled / disabled).
Verificar se o serviço está ativo ou inativo.
📌 Exemplo de Uso:
- name: Garantir que o nginx esteja ativo e habilitado
  ansible.builtin.service:
    name: nginx
    state: started
    enabled: yes
​
🛠️ Parâmetros Comuns:
Parâmetro
Descrição
name
Nome do serviço (ex.: nginx, apache2, sshd)
state
Estado desejado: started, stopped, restarted, reloaded
enabled
Define se o serviço deve iniciar automaticamente no boot (yes ou no)
💡 Observações:
Internamente usa systemctl, service ou init.d, dependendo da distribuição.
Para sistemas com systemd, considere também o módulo mais moderno: ansible.builtin.systemd.
Módulo copy 
🔗 ansible.builtin.copy module – Copy files to remote locations…​
O módulo copy permite copiar arquivos diretamente do host de controle (onde o Ansible está sendo executado) para os hosts de destino, ideal para distribuir arquivos de configuração, scripts ou qualquer outro recurso necessário em servidores remotos.
✅ Principais Funcionalidades:
Copia arquivos locais para o destino remoto.
Define permissões, dono e grupo do arquivo.
Pode criar arquivos a partir de conteúdo direto (sem depender de um arquivo local).
Garante idempotência: só atualiza o destino se o conteúdo mudar.
📌 Exemplos de Uso:
- name: Copiar um arquivo de configuração para o servidor
  ansible.builtin.copy:
    src: ./nginx.conf
    dest: /etc/nginx/nginx.conf
    owner: root
    group: root
    mode: '0644'
​
- name: Criar um arquivo com conteúdo inline
  ansible.builtin.copy:
    dest: /etc/mensagem.txt
    content: "Bem-vindo ao servidor gerenciado pelo Ansible!"
​
🛠️ Parâmetros Comuns:
Parâmetro
Descrição
src
Caminho do arquivo local a ser copiado
dest
Caminho de destino no host remoto
content
Conteúdo literal a ser escrito (alternativa ao src)
owner
Proprietário do arquivo remoto
group
Grupo do arquivo remoto
mode
Permissões do arquivo (ex.: '0644')
backup
Se yes, cria backup do arquivo remoto antes de sobrescrever
⚠️ Dicas:
Use copy para arquivos fixos e simples.
Para arquivos dinâmicos ou com variáveis, prefira o módulo template, que usa Jinja2.
Módulo file
�� ansible.builtin.file module – Manage files and file properti…​
O módulo file permite gerenciar propriedades de arquivos, diretórios e links simbólicos nos hosts de destino. 
✅ Principais Funcionalidades:
Criar ou remover arquivos e diretórios.
Alterar permissões (mode), dono (owner) e grupo (group).
Criar ou remover links simbólicos (state: link).
Garantir que um arquivo/diretório tenha um determinado estado (absent, directory, etc.).
📌 Exemplos de Uso:
- name: Criar um diretório com permissões específicas
  ansible.builtin.file:
    path: /var/www/html
    state: directory
    owner: www-data
    group: www-data
    mode: '0755'
​
- name: Remover um arquivo
  ansible.builtin.file:
    path: /tmp/arquivo_antigo.log
    state: absent
​
- name: Criar um link simbólico
  ansible.builtin.file:
    src: /etc/nginx/sites-available/site.conf
    dest: /etc/nginx/sites-enabled/site.conf
    state: link
​
🛠️ Parâmetros Comuns:
Parâmetro
Descrição
path
Caminho do arquivo, diretório ou link
state
Estado desejado: file, directory, absent, link, touch, hard
owner
Usuário proprietário
group
Grupo proprietário
mode
Permissões do sistema de arquivos (ex.: '0644')
src
Caminho de origem ao criar links
🔄 Estados Comuns:
Valor de state
Efeito
file
Garante que é um arquivo
directory
Garante que é um diretório
absent
Remove arquivo/diretório/link se existir
link
Cria link simbólico
hard
Cria link físico
touch
Cria arquivo vazio se não existir
Esse módulo é muito útil para preparar estrutura de diretórios, definir políticas de permissões e manter o estado de arquivos críticos em servidores gerenciados.
Passo 02 - Explorando o módulo: command
cd ansible-tasks
ls
cat hosts

# The private IP address of an AWS EC2 instance remains the same even when the instance is restarted or stopped and started. This is because the private IP is assigned to the network interface and remains associated with it until the instance is terminated. 


ansible all -m command -a "date"
ansible all -m command -a "df -kh"
ansible all -m command -a "cat /etc/os-release"

ansible -i hosts host01 -m command -a "date"
ansible -i hosts host01 -m command -a "df -kh"
ansible -i hosts host01 -m command -a "cat /etc/os-release"
​
Passo 03 - Explorando o módulo: apt
# Installing Apache on Debian Host: 'apt' package manager
ansible host01 -m apt -a "name=apache2 state=latest" # Error

# 'sudo apt update'
ansible host01 -m apt -a "update_cache=yes"           # Error - Permission denied!

# Giving 'ansible' user root permission (privilege elevation). 
ansible host01 -m apt -a "update_cache=yes" -become

# Installing Apache using 'become' in a short way '-b'
ansible host01 -m apt -a "name=apache2 state=latest" -b # This command can take a while.

# or
ansible host01 -m apt -a "update_cache=yes name=apache2 state=latest" -b

# Try to access 'host01' by Public IP DNS | Add port 80 into the Security Group!
# HTTP
​
Passo 04 - Explorando os módulos:  service e shell
# Checking, Stopping and Starting the Apache service

# Checking Status
ansible host01 -m shell -a "systemctl status apache2"

# Stopping Service
ansible host01 -m shell -a "systemctl stop apache2"      # Error

# Stopping Service using '-b'
ansible host01 -m shell -a "systemctl stop apache2" -b

# Checking Status
ansible host01 -m shell -a "systemctl status apache2"

# Refresh Apache Page

# Using 'service' module
ansible host01 -m service -a "name=apache2 state=started" -b

# Refresh Apache Page
​
⚙️ Por que service é mais indicado que shell para gerenciar serviços?
O módulo service é mais seguro, declarativo e idempotente do que utilizar o módulo shell para iniciar/parar/reiniciar serviços manualmente.
🔍 Comparação: service vs shell
Critério
service
shell
Idempotência
✅ Sim (executa apenas se necessário)
❌ Não (executa sempre, mesmo que o estado já esteja correto)
Leitura e clareza
✅ Declarativo: fácil entender o objetivo
❌ Imperativo: depende de comandos manuais
Segurança
✅ Controlado e restrito a ações de serviço
❌ Riscos de erro ou má interpretação do shell
Portabilidade
✅ Usa abstrações do sistema (systemd, init)
❌ Pode não funcionar em todos os sistemas
Exemplo
state: started ou enabled: yes
shell: systemctl start nginx
✅ Exemplo Correto com service:
- name: Garantir que o nginx esteja rodando e habilitado
  ansible.builtin.service:
    name: nginx
    state: started
    enabled: yes
​
⚠️ Exemplo Desaconselhado com shell:
- name: Iniciar nginx manualmente (não recomendado)
  ansible.builtin.shell: systemctl start nginx
​
O módulo service entende o estado desejado do serviço e age apenas quando necessário, o que evita execuções desnecessárias e torna seu playbook mais eficiente e confiável. Ele também torna sua automação mais fácil de manter e auditar, pois expressa o que você quer, não como fazer.
Passo 05 - Explorando os módulos: copy e file
# Create a dummy file inside ansible-tasks folder
# Let's image it's a script file to be copy to all hosts
echo "This is an example file" >> dump

# Listing
ansible all -m command -a 'ls /tmp/dump'

# Copying
ansible all -m copy -a "src=dump dest=/tmp"

# Listing
ansible all -m command -a 'ls /tmp/dump'

# Listing the content
ansible all -m command -a "cat /tmp/dump"


# Using module 'File'
# Delete the 'dump' file...
ansible all -m file -a 'path=/tmp/dump state=absent'

# Listing
ansible all -m command -a 'ls /tmp/dump'

# Terminate the EC2 instances host01 and host0

## Additional information

- **Package Management Systems:**
    
    • **apt**: Debian, Ubuntu...
    • **yum**: RHEL, Rocky, Fedora...
    • **pkg**: FreeBSD...
    
- **Update Package Lists:**
    
    • **sudo apt update**: Debian, Ubuntu...
    • **dnf check-update**: RHEL, Rocky, Fedora...
    • **sudo pkg update**: FreeBSD...2
