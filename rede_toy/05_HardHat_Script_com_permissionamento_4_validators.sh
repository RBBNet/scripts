# Script com permissionamento (4 validators) utilizando o HardHat
# baixa o diretório
{
projectname="redeToy_HardHat_Teste4Validators"
branch_do_Permissionamento="-b migracao-hardhat"

PortaBoot="10071"
PortaValidator1="10070"
PortaValidator2="10073"
PortaValidator3="10074"
PortaValidator4="10075"
PortaWriter="10072"

if [ -z "$1" ]; then
  echo "Por favor, forneça a versão do Besu como parâmetro."
  exit 1
fi

# A versão do Besu é passada como primeiro argumento ($1)
versao_do_besu="$1"
versao_alvo="23.4.1" #workaround para verificar a versão do besu




git clone https://github.com/RBBNet/start-network.git -b main
cd start-network
sed -i "s/ARG BESU_VERSION=latest/ARG BESU_VERSION=${versao_do_besu}/" "Dockerfile"
sed -i "s|image: \${IMAGE_BESU:-hyperledger/besu}|image: \${IMAGE_BESU:-hyperledger/besu:${versao_do_besu}}|" "docker-compose.yml.hbs"
echo "Versão do Besu alterada com sucesso."
cd ..

mv start-network $projectname
cd $projectname
# cria os nós especificados.
./rbb-cli node create validator1, boot, writer, validator2, validator3, validator4
# define as portas do container
./rbb-cli config set nodes.boot.ports+=[\"$PortaBoot:8545\"]
./rbb-cli config set nodes.validator1.ports+=[\"$PortaValidator1:8545\"]
./rbb-cli config set nodes.validator2.ports+=[\"$PortaValidator2:8545\"]
./rbb-cli config set nodes.validator3.ports+=[\"$PortaValidator3:8545\"]
./rbb-cli config set nodes.validator4.ports+=[\"$PortaValidator4:8545\"]
./rbb-cli config set nodes.writer.ports+=[\"$PortaWriter:8545\"]
# cria o genesis
./rbb-cli genesis create --validators validator1,validator2,validator3,validator4
# desabilita o discovery nos nós especificados 
./rbb-cli config set nodes.validator1.environment.BESU_DISCOVERY_ENABLED=false
./rbb-cli config set nodes.writer.environment.BESU_DISCOVERY_ENABLED=false
./rbb-cli config set nodes.validator2.environment.BESU_DISCOVERY_ENABLED=false
./rbb-cli config set nodes.validator3.environment.BESU_DISCOVERY_ENABLED=false
./rbb-cli config set nodes.validator4.environment.BESU_DISCOVERY_ENABLED=false

if [[ "$(echo -e "$versao_do_besu\n$versao_alvo" | sort -V | head -n 1)" == "$versao_do_besu" ]]; then
./rbb-cli config set nodes.validator1.environment.BESU_OPTS=-Dsecp256k1.randomize=false
./rbb-cli config set nodes.writer.environment.BESU_OPTS=-Dsecp256k1.randomize=false
./rbb-cli config set nodes.validator2.environment.BESU_OPTS=-Dsecp256k1.randomize=false
./rbb-cli config set nodes.validator3.environment.BESU_OPTS=-Dsecp256k1.randomize=false
./rbb-cli config set nodes.boot.environment.BESU_OPTS=-Dsecp256k1.randomize=false
else
  echo "Nao consegui fazer a mudanca no dsecp256k1."
fi

# ajusta os static nodes apontando para o boot
bootkey=$(./rbb-cli config dump | grep 0x | sed -n '2 p' |sed 's/"publicKey": "0x//' | sed 's/",//' | sed 's/ //g')
validator1key=$(./rbb-cli config dump | grep 0x | sed -n '4 p' |sed 's/"publicKey": "0x//' | sed 's/",//'| sed 's/ //g')
validator2key=$(./rbb-cli config dump | grep 0x | sed -n '6 p' |sed 's/"publicKey": "0x//' | sed 's/",//'| sed 's/ //g')
validator3key=$(./rbb-cli config dump | grep 0x | sed -n '8 p' |sed 's/"publicKey": "0x//' | sed 's/",//'| sed 's/ //g')
validator4key=$(./rbb-cli config dump | grep 0x | sed -n '10 p' |sed 's/"publicKey": "0x//' | sed 's/",//'| sed 's/ //g')
writerkey=$(./rbb-cli config dump | grep 0x | sed -n '12 p' |sed 's/"publicKey": "0x//' | sed 's/",//'| sed 's/ //g')
echo "[
\"enode://$bootkey@boot:30303\",
\"enode://$validator2key@validator2:30303\",
\"enode://$validator3key@validator3:30303\",
\"enode://$validator4key@validator4:30303\"
]" > volumes/validator1/static-nodes.json
echo "[
\"enode://$bootkey@boot:30303\",
\"enode://$validator1key@validator1:30303\",
\"enode://$validator3key@validator3:30303\",
\"enode://$validator4key@validator4:30303\"
]" > volumes/validator2/static-nodes.json
echo "[
\"enode://$bootkey@boot:30303\",
\"enode://$validator1key@validator1:30303\",
\"enode://$validator2key@validator2:30303\",
\"enode://$validator4key@validator4:30303\"
]" > volumes/validator3/static-nodes.json
echo "[
\"enode://$bootkey@boot:30303\",
\"enode://$validator1key@validator1:30303\",
\"enode://$validator2key@validator2:30303\",
\"enode://$validator3key@validator3:30303\"
]" > volumes/validator4/static-nodes.json
echo "[
\"enode://$bootkey@boot:30303\"
]" > volumes/writer/static-nodes.json

./rbb-cli config render-templates
docker-compose up -d validator1 validator2 validator3 validator4 boot writer


# ---------------------------------
# permissionamento
cd ..

# Garantia de que será usado o node 16
. $NVM_DIR/nvm.sh
nvm install 16
nvm use 16
npm i --global yarn
# ---- - - - -

git clone https://github.com/RBBNet/Permissionamento.git $branch_do_Permissionamento
cd Permissionamento
yarn install
#yarn linuxcompiler

# get validator1 ip
validator1container=$(docker ps --format "{{.Names}}" | grep validator1)
docker inspect $validator1container
validator1ip=$(docker inspect $validator1container | grep IPAddr |  sed -n '3 p' | awk '{ print $2 }' | sed "s/\"//" | sed "s/\"//" | sed "s/,//")

# get boot ip
bootcontainer=$(docker ps --format "{{.Names}}" | grep -i $(echo $projectname\_boot))
docker inspect $bootcontainer
bootip=$(docker inspect $bootcontainer | grep IPAddr |  sed -n '3 p' | awk '{ print $2 }' | sed "s/\"//" | sed "s/\"//" | sed "s/,//")

echo "NODE_INGRESS_CONTRACT_ADDRESS=0x0000000000000000000000000000000000009999
ACCOUNT_INGRESS_CONTRACT_ADDRESS=0x0000000000000000000000000000000000008888
BESU_NODE_PERM_ACCOUNT=627306090abaB3A6e1400e9345bC60c78a8BEf57
BESU_NODE_PERM_KEY=c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3
BESU_NODE_PERM_ENDPOINT=http://localhost:$PortaValidator1
CHAIN_ID=648629
INITIAL_ALLOWLISTED_NODES=enode://$bootkey|0|0x000000000000|Boot|BNDES,enode://$validator1key|1|0x000000000000|Validator|BNDES,enode://$validator2key|1|0x000000000000|Validator|BNDES,enode://$validator3key|1|0x000000000000|Validator|BNDES,enode://$validator4key|1|0x000000000000|Validator|BNDES,enode://$writerkey|2|0x000000000000|Writer|BNDES" > .env


echo;echo "Esperando a produção de blocos entre os nós, por favor aguarde. . .";echo
sleep 120

yarn deploy --network besu
cd .. && cd $projectname

docker-compose logs -f
}

