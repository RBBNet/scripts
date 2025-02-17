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



# A versão do Besu é passada como primeiro argumento ($1)
versao_do_besu="$1"
randomize="$2"

if [ -z "$1" ]; then
  versao_do_besu="latest"
fi


git clone https://github.com/RBBNet/start-network.git -b main
cd start-network
sed -i "s/ARG BESU_VERSION=latest/ARG BESU_VERSION=${versao_do_besu}/" "Dockerfile"
sed -i "s|image: \${IMAGE_BESU:-hyperledger/besu}|image: \${IMAGE_BESU:-hyperledger/besu:${versao_do_besu}}|" "docker-compose.yml.hbs"
echo "Versão do Besu alterada com sucesso."
FILE="docker-compose.yml.hbs"

# Verificar se a variável já existe no arquivo
if [ "$randomize" = "True" ]; then
    # Verificar se a variável BESU_OPTS já existe no arquivo
    if ! grep -q "BESU_OPTS" "$FILE"; then
        # Se não existir, adicionar a variável BESU_OPTS ao ambiente
        sed -i '/<< : \*localization-default/a \ \ \ \ \ \ BESU_OPTS: "-Dsecp256k1.randomize=false"' "$FILE"
        echo "Variável BESU_OPTS adicionada com sucesso."
    else
        echo "Variável BESU_OPTS já existe no arquivo."
    fi
else
    echo "A variável BESU_OPTS não será adicionada."
fi

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

#mais um parâmetro


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

}
