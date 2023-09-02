# Roteiro para rodar os scripts

Este roteiro tem como objetivo explicar como rodar cada script disponível, este roteiro assume que serão rodados em ambiente Windows.

## 1 - Preparação

### 1.1 - Pré-requisitos

- Yarn
- Node.js

### 1.2 - Baixar o repositório `Scripts`

- Execute os seguintes comandos:

  ```bash
  git clone https://github.com/RBBNet/Scripts.git
  cd Scripts
  
  ```

## 2 - Consultas API Besu

- Execute o comando abaixo para acessar o diretório Consultas API Besu: 

```bash
cd Consultas API Besu

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


### 2.1 `admin_peers` (atualmente como `conexoes`)

- Execute o seguinte comando para rodar o script `admin_peers`:

```bash
node conexoes.js

```

## 3 - Rede Toy

- Execute o comando abaixo para acessar o diretório Rede Toy: 

```bash
cd Rede Toy

```

### 3.1 - `Script sem permissionamento (1 validator)`

Script para subir uma Rede Toy com 1 Validator e sem Permissionamento.


### 3.2 - `Script com permissionamento (1 validator)`

Script para subir uma Rede Toy com 1 Validator e com Permissionamento.


### 3.3 - `Script com permissionamento (2 validators)`

Script para subir uma Rede Toy com 2 Validators e com Permissionamento.


### 3.4 - `Script com permissionamento (4 validators)`

Script para subir uma Rede Toy com 3 Validators e com Permissionamento.
