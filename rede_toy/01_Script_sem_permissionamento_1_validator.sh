# Script sem permissionamento
# baixa o diretório
projectname="Nome-do-projeto"

PortaBoot="10071"
PortaValidator="10072"
PortaWriter="10073"


echo "Dica:"
echo "Utilize portas que não estão em uso"
sleep 4

curl -#SL https://github.com/RBBNet/start-network/releases/download/v0.4.1%2Bpermv1/start-network.tar.gz | tar xz
mv start-network $projectname
cd $projectname
# cria os nós especificados.
./rbb-cli node create validator, boot, writer
# define as portas do container
./rbb-cli config set nodes.validator.ports+=[\"$(echo $PortaValidator):8545\"]
./rbb-cli config set nodes.boot.ports+=[\"$(echo $PortaBoot):8545\"]
./rbb-cli config set nodes.writer.ports+=[\"$(echo $PortaWriter):8545\"]
# cria o genesis
./rbb-cli genesis create --validators validator
# desabilita o discovery nos nós especificados
./rbb-cli config set nodes.validator.environment.BESU_DISCOVERY_ENABLED=false
./rbb-cli config set nodes.writer.environment.BESU_DISCOVERY_ENABLED=false
# ajusta os static nodes apontando para o boot
bootkey=$(./rbb-cli config dump | grep 0x | sed -n '2 p' |sed 's/"publicKey": "0x//' | sed 's/",//')
echo "[
\"enode://$(echo $bootkey)@boot:30303\"
]" > volumes/validator/static-nodes.json
echo "[
\"enode://$(echo $bootkey)@boot:30303\"
]" > volumes/writer/static-nodes.json
./rbb-cli config render-templates
docker-compose up -d
docker-compose logs -f
