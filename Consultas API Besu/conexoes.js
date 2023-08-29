const axios = require('axios');
const fs = require('fs');

function readTableFromFile(filePath) {
  const fileContent = fs.readFileSync(filePath, 'utf8');
  const lines = fileContent.split('\n').map(line => line.trim()).filter(line => line !== '');
  const keys = lines[0].split('|').map(key => key.trim()).filter(key => key !== '');
  const structures = [];

  for (let i = 2; i < lines.length; i++) {
    const values = lines[i].split('|').map(value => value.trim().replace(/`/g, '')).filter(value => value !== '');
    const structure = {};

    for (let j = 0; j < keys.length; j++) {
      if (keys[j].toLowerCase() === 'enode') {
        structure[keys[j]] = values[j].split('@')[0];
      } else {
        structure[keys[j]] = values[j];
      }
    }

    structures.push(structure);
  }

  return structures;
}

function readLocalNodesAccessPointsFromFile(filePath) {
  const fileContent = fs.readFileSync(filePath, 'utf8');
  const lines = fileContent.split('\n').map(line => line.trim()).filter(line => line !== '');
  const accessPoints = [];

  for (let i = 0; i < lines.length; i++) {
    const nodeEntries = lines[i].split(' ');
    for (let j = 0; j < nodeEntries.length; j++) {
      const [nodeName, address] = nodeEntries[j].split('@');
      const [host, port] = address.split(':');
      accessPoints.push({ nodeName, host, port });
    }
  }

  return accessPoints;
}

async function getAdminPeers(host, port) {
  const url = `http://${host}:${port}`;
  //if (debug) console.log(`URL: ${url}`);
  const response = await axios.post(url, {
    jsonrpc: '2.0',
    method: 'admin_peers',
    params: [],
    id: 1,
  });

  return response.data;
}

async function getAdminPeersForLocalNodes(LocalNodesAccessPoints) {
  const enodesList = [];

  for (let i = 0; i < LocalNodesAccessPoints.length; i++) {
    const { nodeName, host, port } = LocalNodesAccessPoints[i];
    const adminPeers = await getAdminPeers(host, port);
    //console.log(`Admin peers for port ${port}:`, adminPeers);

    const enodes = adminPeers.result.map(peer => peer.enode.split('@')[0]);
    enodesList.push({ nodeName, enodes });
  }

  return enodesList;
}

function printConnectionMap(enodesList, RBBNodes) {
  for (let i = 0; i < enodesList.length; i++) {
    const { nodeName, enodes } = enodesList[i];
    console.log(`\n${nodeName}:`);
    console.log('================');

    for (let j = 0; j < enodes.length; j++) {
      const enode = enodes[j];
      const rbbNode = RBBNodes.find(node => node.Enode === enode);

      if (rbbNode) {
        console.log(`${rbbNode.Membro.padEnd(10)} - ${rbbNode['Tipo de Nó']}`);
      } else {
        console.log(`No RBBNode found for enode ${enode}`);
      }
    }
  }
}

async function main() {
  // Trata a opção -debug
  const args = process.argv.slice(2);
  const debug = args.includes('-debug');

  // Lê o arquivo enodes.md
  const fileRBBNodesPath = 'enodes.md';
  const RBBNodes = readTableFromFile(fileRBBNodesPath);
  if (debug) console.log(RBBNodes);

  // Lê o arquivo local-nodes-access-points.txt que contém os pontos de acesso dos nós locais
  const fileBNDESPortsPath = 'local-nodes-access-points.txt';
  const LocalNodesAccessPoints = readLocalNodesAccessPointsFromFile(fileBNDESPortsPath);
  if (debug) console.log(LocalNodesAccessPoints);

  // Obter os admin_peers para cada nó local
  const enodesList = await getAdminPeersForLocalNodes(LocalNodesAccessPoints);
  if (debug) console.log(enodesList);

  // Para cada nó BNDES, imprime os enodes e seus nós conectados
  printConnectionMap(enodesList, RBBNodes);
  console.log("\n\n");
}

main();