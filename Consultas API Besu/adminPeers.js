const { 
  storeIntoArrays, 
  readLocalNodesAccessPointsFromFile, 
  mapEnodeToInstituicao, 
  groupNodesByType 
} = require('./core.js');

async function main() {
  let instituicao = [];
  let enode = [];
  let account = [];

  await storeIntoArrays(instituicao, enode, account);
  const enodeToInstituicao = await mapEnodeToInstituicao(enode, instituicao);
  const accessPoints = await readLocalNodesAccessPointsFromFile('localnodes.conf');
  const rpcMethod = 'admin_peers';  // Pode ser alterado para outro método RPC
  const nodesByType = await groupNodesByType(accessPoints, enodeToInstituicao, rpcMethod);


  const columns = [];
  for (const [type, nodes] of Object.entries(nodesByType)) {
    let column = [type, '===========', ...nodes];
    columns.push(column);
  }

  const maxColumnLength = Math.max(...columns.map(column => column.length));
  for (const column of columns) {
    while (column.length < maxColumnLength) {
      column.push('');
    }
  }
const asciiArt = `
            _           _       _____                   
           | |         (_)     |  __ \\                  
   __ _  __| |_ __ ___  _ _ __ | |__) |__  ___ _ __ ___ 
  / _\` |/ _\` | '_ \` _ \\| | '_ \\|  ___/ _ \\/ _ \\ '__/ __|
 | (_| | (_| | | | | | | | | | | |  |  __/  __/ |  \\__ \\
  \\__,_|\\__,_|_| |_| |_|_|_| |_|_|   \\___|\\___|_|  |___/
`;

console.log(asciiArt);
  // Reordena as colunas, trocando a primeira com a do meio
  if (columns.length >= 2) {
    [columns[0], columns[1]] = [columns[1], columns[0]];
  }

  // Imprima as colunas
  for (let i = 0; i < maxColumnLength; i++) {
    const row = columns.map(column => column[i].padEnd(30)).join(' ');
    console.log(row);
  }
}

main();
