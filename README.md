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

Execute o comando abaixo para acessar o diretório Consultas API Besu: 

```bash
cd Consultas API Besu

```

Daqui para frente, considere que todos os comandos deverão ser executados dentro do diretório Consultas API Besu.

## 3 - Scripts

- Execute o seguinte comando para instalar as dependências:

#### **Via Yarn**

```bash
yarn install

```

#### **Via Node**

```bash
npm install

```

 ⚠️ **Atenção!** Verifique se o tunelamento dos nós estão abertos!!!


### 3.1 `admin_peers` (atualmente como `conexoes`)

- Execute o seguinte comando para rodar o script `admin_peers`:

```bash
node conexoes.js

```
