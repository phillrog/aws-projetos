# Objetivo
Migração de Aproximadamente 100 contas de usuários on-premises para a AWS, de forma automatizada, associando as permissões necessárias e aplicando MFA nos grupos

# Premissa
Deve-se criar os respectivos grupos dos usuários, nesse projeto foram criados os seguintes grupos:

- **CloudAdmin**
- **DBA**
- **LinuxAdmin**
- **RedesAdmin**
- **Estagiarios**

## Passo 1 - Criar arquivo .csv com os usuários
Crie um arquivo usuarios.csv com separador por "," (vírgula), com os seguintes dados :

- Nome Usuário
- Grupo
- Senha Padrão, exemplo ```@2025TrocarSenha```

Grave em um diretório.

## Passo 2 - AWS Cloud Shell

### 1. Acessar **AWS Cloud Shell**

### 2. Instalar '**dos2unix**' no AWS Cloud Shell (necessário para execução do script para conversão de arquivos de texto com finais de linha no estilo DOS (CRLF) para o estilo Unix (LF))

```
sudo yum install dos2unix -y
```

### 3. Faça upload dos arquivos:
- [usuarios.csv](./scripts/usuarios.csv)
- [aws-iam-cria-usuario.sh](./scripts/aws-iam-cria-usuario.sh)  (está na pasta scripts)

Obj: Vá na seguinte opção no shell

![image](https://github.com/user-attachments/assets/b509b284-b5f6-403d-9b66-72f0e8218294)

### 4. Defina a permissão de execução do script com chmod abaixo:

```
ls -la
chmod +x aws-iam-cria-usuario.sh
ls -la
```

Agora execute :

```
./aws-iam-cria-usuario.sh usuarios.csv 
```
![image](https://github.com/user-attachments/assets/fc1099cd-4012-48e6-9d70-b4c2f057323e)

Obs: testei apenas 5 usuários e não o total de 100 na primeira execução

### 5. Adicionar permissão para os usuários resetar a senha

Selecione o usuário / Add Permission
![image](https://github.com/user-attachments/assets/61fe8a42-f62d-4605-b55a-132c7925e435)

Selecione a opção "Attach policies directly" e pesquisa por IAM 
![image](https://github.com/user-attachments/assets/f2f6df0a-b45b-48f3-8adf-abcbbef97565)

Em sequida adicione a permissão IAMUserChangePassword
![image](https://github.com/user-attachments/assets/85c1d461-23d3-4817-8a8f-04597e616ccc)

## Passo 3 - Configurar MFA com permissão customizada

Esta configuração customizada de MFA, com configurações customizadas para atender a especificações internas de um cliente.

Utilize o arquivo [force_mfa_policy.txt](./scripts/force_mfa_policy.txt) que possui o json config da política customizada.

1. Copie a configuração

2. Vá em IAM > Policies > Create policy cole o json no editor e click em Next

![image](https://github.com/user-attachments/assets/3457a67e-9e46-48e0-ab45-84b7e330abd8)

3. Nomeie a police como "EnforceMFAPolicy" e lá no fim click em Create policy

![image](https://github.com/user-attachments/assets/13461d1e-2502-4358-a5f2-e1bd40d79e7b)

Criado com sucesso

![image](https://github.com/user-attachments/assets/37f7a428-82b8-4bba-a424-b0b5aa26a3a0)

## Passo 5 - Defina a política para os usuários

1. Attach as entidades para definir a police então click em Entities attached > Botão Attach > Selecione os IAM Users em seguida click em Attach Policy

![image](https://github.com/user-attachments/assets/76e68561-b599-4b3c-92a7-5bf83b93dcea)

Obs: Faça o mesmo para os grupos

3. Pronto todos os usuários/grupos poderão utlizar MFA porém eles deverão habilitar no próximo login se não eles não estaram totalmente autenticados a utilizar a conta.

![image](https://github.com/user-attachments/assets/7e310203-5f3e-4286-8845-d1f8cbdd688e)

Aparece também no usuário

![image](https://github.com/user-attachments/assets/1ad20fad-9f5e-4e39-90f1-f7c0693b20e4)


## Passo 6 - Ativar MFA do usuário

1. Faça login com um usuário
2. Vá em Security credentials
![image](https://github.com/user-attachments/assets/839dc77a-e299-40d1-ab9a-90a3a39a2957)
3. Click em Assign MFA
![image](https://github.com/user-attachments/assets/ea16c17e-2917-4208-9dc4-62ffd22dd0cc)
4. Dê um nome para o dispositivo em seguida selecione a opção Authenticator app e click em Next
![image](https://github.com/user-attachments/assets/15d2a868-836a-4bd4-91d4-dfe9dbe6a624)
5. Click em Show QR Code e escaneie a imagem com um aplicativo Autenticador MFA (Google/Microsoft authenticator)
6. Informe o primeiro número na primeira caixa em seguida informe o próximo número na segunda caixa e clica em ADD MFA
![image](https://github.com/user-attachments/assets/eb432195-33b8-48ed-8204-c7933d0b4e83)

Pronto no próximo login será pedido o código autenticador gerado do aplicativo.

# Resultado
Login simples
![login1](https://github.com/user-attachments/assets/2932b15e-0adb-47b9-a99b-0c6b9738ecda)

Login com MFA
![login-mfa](https://github.com/user-attachments/assets/6ed16f43-d19d-40a9-8980-e7fe06fbae91)

# Bônus

Aplicar Politica de Senha | Tornar Senha mais Forte!!

Vá em IAM > Account Settings > Edit password policy e defina estas configurações para as senhas ficarem ainda mais seguras

![image](https://github.com/user-attachments/assets/78e271b4-0b88-46b4-9ddb-4246184d1141)

# Referências

- AWS Documentation

