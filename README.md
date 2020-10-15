# Importing-VM-as-an-Image
Essa Documentação tem como foco realizar a importação de uma VM para seu ambiente de virtualização Amazon EC2. Importaremos com o padrão de Imagens Amazon (AMI), que permite que você execute instâncias baseadas.

## Overwiew 

- [ ] Exportar VM para OVF
- [ ] Importar VM na AWS
- [ ] Gerar arquivos de configuração .json
- [ ] Executar comandos AWS cli

## Exportando a VM para OVF 
O primeiro passo a se fazer é exportar sua VM para o formato aceito pela AWS, nesse caso o OVF, para isso vamo precisar do software VMware. </br>
Download: https://www.vmware.com/br/products/workstation-pro/workstation-pro-evaluation.html

#### Dentro da ferramenta, iremos executar os seguintes passos:

  - Importar a VM no VMware 
  - Selecionar a opção "File"
  - Export to OVF
  
Esse processo irá gerar três arquivos com as extensões: .mf, .ovf e .vmdk.

## Importando VM na AWS
Depois de exportar a VM do ambiente de virtualização, você pode importá-la para o Amazon EC2. O processo de importação é o mesmo, independentemente da origem da VM.

### Pré-requisitos

  - Crie um bucket do Amazon S3 para armazenar as imagens exportadas ou escolha um bucket existente. Selecione na região onde você deseja importar suas VMs. Dentro do S3 
    crie dois diretorios, um chamado "exported" e um chamado "vm". É necessário deixar o S3 público. 

  - Pegue os arquivos de exportação gerados e realize o Upload na pasta "vm". É necessário deixar esses arquivos públicos também. 

  - Crie três arquivos de configuração .json e adicione eles a um diretorio local. Seguindo os modelos abaixo: <br/>
    Obs: Os arquivos estão disponiveis no repositorio. 

      #### Arquivo: role-policy.json
      ```json
      {
          "Version":"2012-10-17",
          "Statement":[
             {
                "Effect": "Allow",
                "Action": [
                   "s3:GetBucketLocation",
                   "s3:GetObject",
                   "s3:ListBucket" 
                ],
                "Resource": [
                   "arn:aws:s3:::NOME_DO_SEU_BUCKET",
                   "arn:aws:s3:::NOME_DO_SEU_BUCKET/vm/*"
                ]
             },
             {
                "Effect": "Allow",
                "Action": [
                   "s3:GetBucketLocation",
                   "s3:GetObject",
                   "s3:ListBucket",
                   "s3:PutObject",
                   "s3:GetBucketAcl"
                ],
                "Resource": [
                   "arn:aws:s3:::NOME_DO_SEU_BUCKET/exported",
                   "arn:aws:s3:::NOME_DO_SEU_BUCKET/exported/*"
                ]
             },
             {
                "Effect": "Allow",
                "Action": [
                   "ec2:ModifySnapshotAttribute",
                   "ec2:CopySnapshot",
                   "ec2:RegisterImage",
                   "ec2:Describe*"
                ],
                "Resource": "*"
             }
          ]
      }
      ```

      #### Arquivo: trust-policy.json
      ```json
      {
         "Version": "2012-10-17",
         "Statement": [
            {
               "Effect": "Allow",
               "Principal": { "Service": "vmie.amazonaws.com" },
               "Action": "sts:AssumeRole",
               "Condition": {
                  "StringEquals":{
                     "sts:Externalid": "vmimport"
                  }
               }
            }
         ]
      }
      ```
      
      #### Arquivo: containers.json
      ```json
      [
          {
            "Description": "First disk",
            "Format": "vmdk",
            "UserBucket": {
                "S3Bucket": "NOME_DO_SEU_BUCKET",
                "S3Key": "vm/NOME_DA_VM_DENTRO_DO_S3.vmdk"
            }
          }
        ]
      ```
  - Instale o AWS cli, você usará para executar os comandos de importação. <br/>
    Download: https://docs.aws.amazon.com/pt_br/cli/latest/userguide/cli-chap-install.html <br/>
    Configuração: https://docs.aws.amazon.com/pt_br/cli/latest/userguide/cli-chap-configure.html
  
## Importar a VM
Depois de tudo configurado, vamos executar os comandos via AWS cli para geração da AMI, passando o diretorio local dos nossos arquivos de configurações.

### Exemplo:
  ```console
  aws iam create-role --role-name vmimport --assume-role-policy-document "file://C:\Users\lucas\Documents\Projects\ImportVM\trust-policy.json"
  aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document "file://C:\Users\lucas\Documents\Projects\ImportVM\role-policy.json"
  aws ec2 import-image --description "My server disk vm" --disk-containers "file://C:\Users\lucas\Documents\Projects\ImportVM\containers.json"
  ```
  
## Conclusão

- [x] Exportar VM para OVF
- [x] Importar VM na AWS
- [x] Gerar arquivos de configuração .json
- [x] Executar comandos AWS cli

É importante lembrar que o processo de geração da AMI é um pouco demorado, por tanto, aguarde algumas horas até o final desse processo.
