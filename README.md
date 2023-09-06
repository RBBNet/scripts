# Roteiro para rodar os scripts

Este roteiro tem como objetivo explicar como rodar cada script disponível, este roteiro assume que serão rodados em ambiente Windows.

## 1 - Preparação

### 1.1 - Pré-requisitos

- Yarn
- Node.js

### 1.2 - Baixar o repositório `scripts`

#### Via Windows
- Execute o seguinte comando:

```bash
 curl -L -O https://github.com/RBBNet/scripts/archive/refs/tags/v1.0.2.zip

 ```

- Agora você deve descompactar e acessar a pasta que contém os scripts desejado

#### Via Linux
- Execute o seguinte comando:

```bash
curl -#SL https://github.com/RBBNet/scripts/archive/refs/tags/v1.0.2.tar.gz | tar xz

 ```

- Agora você deve acessar a pasta que contém os scripts desejado

## 2 - Consultas API Besu

- Execute o comando abaixo para acessar o diretório consultas_api_besu: 

```bash
cd consultas_api_besu

```

-  ⚠️ **Atenção!** Antes de executar qualquer script, baixe o `enodes.md` e adicione dentro desta pasta.

Daqui para frente, considere que todos os comandos deverão ser executados dentro do diretório Consultas API Besu.

- Execute o seguinte comando para instalar as dependências:

##### **Via Yarn**

```bash
yarn install

```

##### **Via Node**

```bash
npm install

```

 ⚠️ **Atenção!** Verifique se o tunelamento dos nós estão abertos antes de exercutar qualquer script!!!

 ⚠️ **Atenção!** Neste capítulo 2, rode todos os comandos em ambiente Windows(CMD)!!!

### 2.3 `Dashboard`

Um Dashboard que contém os script `adminPeers` e `getSignerMetrics` em conjunto.

-  Execute o seguinte comando para rodar o Dashboard:

```bash
auto.bat

```

ou caso preferir, rode cada script separado a seguir:

### 2.2 `adminPeers`

- Execute o seguinte comando para rodar o script `adminPeers`:

```bash
node adminPeers.js

```

### 2.1 `SignerMetrics`

- Execute o seguinte comando para rodar o script `SignerMetrics`:

```bash
node getSignerMetrics.js

```

## 3 - Rede Toy [EM CONSTRUÇÃO]

⚠️ **Atenção!** Verifique se está usando o Node v16+ para qualquer sript!!!

⚠️ **Atenção!** Neste capítulo 3, rode todos os comandos em ambiente Linux!!!

- Execute o comando abaixo para acessar o diretório rede_toy: 

```bash
cd rede_toy

```

- Edite o script que deseja alterando as seguintes variáveis:

```bash
projectname="NomeDoProjeto"
branch="-b NomeDaBranch"

PortaBoot="10071"
PortaValidator="10072"
PortaWriter="10073"
```
- projectname -> Nome da pasta que deseja.
- branch -> Selecione a Branch que deseja usar.
- Portas -> altere para não dar conflito com outras que já estão levantadas e ocasionar um erro.

Caso queria mover o arquivo para uma pasta de sua escolha que deseja executar o script, use o comando `mv`, por exemplo:

```bash
mv <script.sh> /caminho_da_pasta/pasta

```

### 3.1 - `Script sem permissionamento (1 validator)`

Script para subir uma Rede Toy com 1 Validator e sem Permissionamento.

- Execute os seguintes comandos:

```bash
chmod +x 01_Script_sem_permissionamento_1_validator.sh
./01_Script_sem_permissionamento_1_validator.sh

```

### 3.2 - `Script com permissionamento (1 validator)`

Script para subir uma Rede Toy com 1 Validator e com Permissionamento.

- Execute os seguintes comandos:

```bash
chmod +x 02_Script_com_permissionamento_1_validator.sh
./02_Script_com_permissionamento_1_validator.sh

```

### 3.3 - `Script com permissionamento (2 validators)`

Script para subir uma Rede Toy com 2 Validators e com Permissionamento.

- Execute os seguintes comandos:

```bash
chmod +x 03_Script_com_permissionamento_2_validators.sh
./03_Script_com_permissionamento_2_validators.sh

```

### 3.4 - `Script com permissionamento (4 validators)`

Script para subir uma Rede Toy com 3 Validators e com Permissionamento.

- Execute os seguintes comandos:

```bash
chmod +x 04_Script_com_permissionamento_4_validators.sh
./04_Script_com_permissionamento_4_validators.sh

```
