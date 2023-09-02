const { 
  storeIntoArrays, 
  readLocalNodesAccessPointsFromFile, 
  mapAccountToInstituicao,
  makeRpcCall_signerMetrics 
} = require('./core.js');

async function main() {
  let instituicao = [];
  let enode = [];
  let account = [];

  await storeIntoArrays(instituicao, enode, account);
  const accountToInstituicao = await mapAccountToInstituicao(account, instituicao);
  
  // Leia apenas os nós que contêm 'Validator'
  const accessPoints = await readLocalNodesAccessPointsFromFile('localnodes.conf');
  
  // Filtrar pela primeira ocorrência do termo 'Validator'
  const validatorNode = accessPoints.find(point => point.nodeName.includes('Validator'));

  // Fazendo chamada RPC
  const rpcMethod = 'qbft_getSignerMetrics';
  const rpcData = await makeRpcCall_signerMetrics(validatorNode.host, validatorNode.port, rpcMethod);

  // Filtrar a saída pela chave 'address' e substituir pelo nome da instituição
  if (rpcData && Array.isArray(rpcData)) {
    const filteredData = rpcData.map(data => {
      const address = data.address;
      return accountToInstituicao[address] || address;
    });
  
    // Imprimindo a saída
const asciiArt = `
             _    _____ _                       __  __      _        _          
            | |  / ____(_)                     |  \\/  |    | |      (_)         
   __ _  ___| |_| (___  _  __ _ _ __   ___ _ __| \\  / | ___| |_ _ __ _  ___ ___ 
  / _\` |/ _ \\ __|\\___ \\| |/ _\` | '_ \\ / _ \\ '__| |\\/| |/ _ \\ __| '__| |/ __/ __|
 | (_| |  __/ |_ ____) | | (_| | | | |  __/ |  | |  | |  __/ |_| |  | | (__\\__ \\
  \\__, |\\___|\\__|_____/|_|\\__, |_| |_|\\___|_|  |_|  |_|\\___|\\__|_|  |_|\\___|___/
   __/ |                   __/ |                                                
  |___/                   |___/                                                 
`;




  const output = [
    asciiArt,
    '=====================================================',
    ...filteredData
  ].join('\n');

  console.log(output);
} else {
  console.log('No data received from the RPC call.');
}

}

main();
