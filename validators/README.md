# Leitura de Validadores por Bloco via Extra Data

O script [`validators.js`](validators.js) permite a leitura dos validadores pertencentes ao consenso da rede no momento da proposição de cada bloco, através do [*extra data*](https://docs.besu-eth.org/private-networks/how-to/configure/consensus/qbft#extra-data).

Para executar o script:

1. Em uma primeira oportunidade, instale as dependências do projeto:

```Shell
npm install
```

2. Para rodar o script:

```Shell
node validators.js <bloco-inicial> [bloco-final]
```

Caso o parâmetro `bloco-final` não seja informado, o script realizará a leitura até o maior bloco produzido no momento do início do script.

Também podem ser configurados como parâmetros através de variáveis de ambiente:

- `JSON_RPC_URL`: URL para acesso ao nó Besu para consulta de dados. Valor padrão: `http://localhost:8545`.
- `NODES_JSON_LAB`: Localização de arquivo `nodes.json` com documentação dos nós da rede LAB / TESTNET para mapeamento do nome de nós e organizações. Valor padrão `nodes_lab.json`.
- `NODES_JSON_PILOTO` = Localização de arquivo `nodes.json` com documentação dos nós da rede PILOTO / MAINNET para mapeamento do nome de nós e organizações. Valor padrão `nodes_piloto.json`.
