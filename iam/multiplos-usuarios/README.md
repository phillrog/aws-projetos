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

1. Acessar **AWS Cloud Shell**

2. Instalar '**dos2unix**' no AWS Cloud Shell (necessário para execução do script para conversão de arquivos de texto com finais de linha no estilo DOS (CRLF) para o estilo Unix (LF))

```
sudo yum install dos2unix -y
```

3. Faça upload dos arquivos:
- [usuarios.csv](./scripts/usuarios.csv)
- [aws-iam-cria-usuario.sh](./scripts/aws-iam-cria-usuario.sh)  (está na pasta scripts)

Obj: Vá na seguinte opção no shell

![image](https://github.com/user-attachments/assets/b509b284-b5f6-403d-9b66-72f0e8218294)

​

