const fs = require('fs');
const dotenv = require('dotenv')
const ethers = require('ethers');
const sprintf = require('sprintf-js').sprintf;

dotenv.config({ quiet: true });

const JSON_RPC_URL = process.env.JSON_RPC_URL || 'http://localhost:8545';
const NODES_JSON_LAB = process.env.NODES_JSON_LAB || 'nodes_lab.json';
const NODES_JSON_PILOTO = process.env.NODES_JSON_PILOTO || 'nodes_piloto.json';

function readJson(file) {
    try {
        const data = fs.readFileSync(file, 'utf8');
        return JSON.parse(data);
    }
    catch (err) {
        console.error(`Erro ao ler o arquivo ${file}:`);
        return null;
    }
}

function mapNodes(orgs, idMap) {
    if(orgs) {
        for (let i = 0; i < orgs.length; i++){
            for (let j = 0; j < orgs[i].nodes.length; j++){
                const node = Object.assign({}, orgs[i].nodes[j]);
                if(node.id) {
                    // Só validators
                    node.organization = orgs[i].organization;
                    idMap.set(node.id, node);
                }
            }
        }
    }
}

async function main() {
    //obtendo parametros
    if(process.argv.length < 3 || process.argv.length > 4){
        console.error('Parâmetros incorretos.\nInsira conforme o exemplo: node qbft-votes.js <bloco-inicial> [bloco-final]\n');
        return;
    }
    
    let initialBlock = parseInt(process.argv[2], 10);

    console.log('Dados dos nós do LAB / TESTNET: %s', NODES_JSON_LAB)
    console.log('Dados dos nós do PILOTO / MAINNET: %s', NODES_JSON_PILOTO)
    console.log('Consultando rede via %s', JSON_RPC_URL)
    provider = new ethers.JsonRpcProvider(JSON_RPC_URL);

    const nodesByIdMap = new Map();
    const nodesLab = readJson(NODES_JSON_LAB);
    const nodesPiloto = readJson(NODES_JSON_PILOTO);
    mapNodes(nodesLab, nodesByIdMap);
    mapNodes(nodesPiloto, nodesByIdMap);

    let finalBlock = process.argv[3];
    if(finalBlock) {
        finalBlock = parseInt(finalBlock, 10);
    }
    else {
        finalBlock = await provider.getBlockNumber();
    }

    console.log('Buscando votos de %d a %d', initialBlock, finalBlock);

    let totalVotes = 0;
    for(let b = initialBlock; b <= finalBlock; ++b) {
        let block = await provider.getBlock(b);
        let extraData = ethers.decodeRlp(block.extraData);
        if(!extraData) {
            console.error('Erro ao obter extra data para bloco %d', b);
        }
        if(extraData.length != 5) {
            console.error('Extra data inválido para bloco %d: %d', b, extraData.length);
        }
        let vote = extraData[2];
        if(vote.length) {
            ++totalVotes;
            let voteValue = vote[1] > 0 ? true : false;
            let voterNode = nodesByIdMap.get(String(block.miner).toLowerCase());
            let voterOrg = voterNode ? voterNode.organization : block.miner;
            let candidate = vote[0];
            let candidateNode = nodesByIdMap.get(candidate.toLowerCase());
            let candidateOrg = candidateNode ? ' (' + candidateNode.organization + ')' : '';
            let timestamp = new Date(block.timestamp*1000);
            console.log(sprintf('%-10s votou %-5s para %s%-12s - Bloco %10d em %s', voterOrg, voteValue, candidate, candidateOrg, b, timestamp.toISOString()));
        }
    }
    console.log('%d votos encontrados', totalVotes);

}

main();