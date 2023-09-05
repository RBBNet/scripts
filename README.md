# Roteiro para rodar os scripts

Este roteiro tem como objetivo explicar como rodar cada script disponível, este roteiro assume que serão rodados em ambiente Windows.

## 1 - Preparação

### 1.1 - Pré-requisitos

- Yarn
- Node.js

### 1.2 - Baixar o repositório `scripts`

- Execute os seguintes comandos:

  ```bash
  git clone https://github.com/RBBNet/Scripts.git
  cd scripts
  
  ```

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

- Execute o comando abaixo para acessar o diretório rede_toy: 

```bash
cd rede_toy

```

### 3.1 - `Script sem permissionamento (1 validator)`

Script para subir uma Rede Toy com 1 Validator e sem Permissionamento.


### 3.2 - `Script com permissionamento (1 validator)`

Script para subir uma Rede Toy com 1 Validator e com Permissionamento.


### 3.3 - `Script com permissionamento (2 validators)`

Script para subir uma Rede Toy com 2 Validators e com Permissionamento.


### 3.4 - `Script com permissionamento (4 validators)`

Script para subir uma Rede Toy com 3 Validators e com Permissionamento.
