const fs = require('fs').promises;
const axios = require('axios');
require('dotenv').config();  // Necessário para carregar variáveis de ambiente

async function storeIntoArrays(instituicao, enode, account) {
  try {
    const data = await fs.readFile('enodes.md', 'utf8');
    const lines = data.split('\n');

    for (let i = 2; i < lines.length; i++) {
      const lineWithoutPipes = lines[i].slice(1, -1);
      const columns = lineWithoutPipes.split('|').map(column => column.trim());

      if (columns.length >= 4) {
        const instituicaoValue = columns[0] + '_' + columns[1];
        const enodesValue = columns[2].replace(/`/g, '').split('@')[0];

        instituicao.push(instituicaoValue);
        enode.push(enodesValue);
        account.push(columns[3]);
      }
    }
  } catch (err) {
    console.error('Erro ao ler o arquivo:', err);
  }
}

async function readLocalNodesAccessPointsFromFile(filePath) {
  const fileContent = await fs.readFile(filePath, 'utf8');
  const lines = fileContent.split('\n').map(line => line.trim()).filter(line => line !== '');
  const accessPoints = [];

  for (const line of lines) {
    const [nodeName, address] = line.split('@');
    const [host, port] = address.split(':');
    accessPoints.push({ nodeName, host, port });
  }

  return accessPoints;
}

async function mapEnodeToInstituicao(enode, instituicao) {
  const enodeToInstituicao = {};
  for (let i = 0; i < enode.length; i++) {
    enodeToInstituicao[enode[i]] = instituicao[i];
  }
  return enodeToInstituicao;
}

async function mapAccountToInstituicao(account, instituicao) {
  const accountToInstituicao = {};
  for (let i = 0; i < account.length; i++) {
    accountToInstituicao[account[i]] = instituicao[i];
  }
  return accountToInstituicao;
}

async function makeRpcCall(host, port, method, params = []) {
  const url = `http://${host}:${port}`;
  try {
    const response = await axios.post(url, {
      jsonrpc: '2.0',
      method: method,
      params: params,
      id: 1,
    });
    return response.data.result;
  } catch (error) {
    console.error(`Failed to fetch data from ${url} using method ${method}:`, error);
    return null;
  }
}

async function makeRpcCall_signerMetrics(host, port, method, params = []) {
  const url = `http://${host}:${port}`;
  const proxyConfig = process.env.PROXY ? {
    host: process.env.PROXY_HOST,
    port: process.env.PROXY_PORT
  } : null;

  try {
    const response = await axios.post(url, {
      jsonrpc: '2.0',
      method: method,
      params: params,
      id: 1,
    }, {
      proxy: proxyConfig
    });
    return response.data.result;
  } catch (error) {
    console.error(`Failed to fetch data from ${url} using method ${method}:`, error);
    return null;
  }
}

async function groupNodesByType(accessPoints, enodeToInstituicao, rpcMethod) {
  const nodesByType = {};

  for (const { nodeName, host, port } of accessPoints) {
    const peers = await makeRpcCall(host, port, rpcMethod);
    if (!peers) continue;

    if (!nodesByType[nodeName]) {
      nodesByType[nodeName] = [];
    }

    for (const peer of peers) {
      const enodeOfPeer = peer.enode.split('@')[0];
      nodesByType[nodeName].push(enodeToInstituicao[enodeOfPeer] || enodeOfPeer);
    }
  }
  
  return nodesByType;
}

async function groupNodesByType_signerMetrics(accessPoints, accountToInstituicao, rpcMethod) {
  const nodesByType = {};

  for (const { nodeName, host, port } of accessPoints) {
    const peers = await makeRpcCall_signerMetrics(host, port, rpcMethod);
    if (!peers) continue;

    if (!nodesByType[nodeName]) {
      nodesByType[nodeName] = [];
    }

    // for (const peer of peers) {
    //   const accountOfPeer = peer.enode.split(':')[0];
    //   nodesByType[nodeName].push(accountToInstituicao[accountOfPeer] || accountOfPeer);
    // }
  }
  
  return nodesByType;
}

module.exports = {
  storeIntoArrays,
  readLocalNodesAccessPointsFromFile,
  mapEnodeToInstituicao,
  groupNodesByType,
  groupNodesByType_signerMetrics,
  mapAccountToInstituicao,
  makeRpcCall_signerMetrics
};
