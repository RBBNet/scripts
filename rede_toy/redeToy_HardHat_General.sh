#!/bin/bash
# Descrição:  Script implantador de uma rede toy, utilizando o HardHat com ou sem permissionamento e com número de nós dinâmicos (Usuário pode escolhar).
version="1.1"

set -e

# Definindo variáveis de estilo
bold=$(tput bold)
normal=$(tput sgr0)
blue=$(tput setaf 4)
green=$(tput setaf 2)
black=$(tput setaf 0)
yellow=$(tput setaf 3)
magenta=$(tput setaf 5)
vermelho=$(tput setaf 1)
background_yellow=$(tput setab 3)

# Auto-updater
GITHUB_URL="https://raw.githubusercontent.com/RBBNet/scripts/refs/heads/main/rede_toy/redeToy_HardHat_General.sh"

SCRIPT_PATH="$0"
latest_script=$(curl -s $GITHUB_URL)
current_script=$(cat $SCRIPT_PATH)

latest_version=$(echo "$latest_script" | grep -E '^version=' | cut -d'"' -f2)

if [[ "$latest_script" != "$current_script" ]]; then
  echo "Nova versão encontrada => Versão Atual: $version ${yellow}Versão nova $latest_version${normal}. Atualizando o script..."
  echo "$latest_script" > "$SCRIPT_PATH"
  echo "Atualização concluída: v${yellow}$latest_version${normal}."
  sleep 2
  chmod +x "$SCRIPT_PATH"
  
  exec "$SCRIPT_PATH"
fi
# ------ fim do auto-updater ------





# Lista de palavras curtas para evitar colisão no nome do projeto
random_word_list=("sky" "chill" "wave" "storm" "wind" "cloud" "sun" "moon" "star" "nova" \
                  "fire" "ice" "rain" "snow" "rock" "dust" "mist" "leaf" "tree" "bird" \
                  "fox" "wolf" "lion" "bear" "hawk" "fish" "frog" "wind" "storm" "echo" \
                  "dark" "light" "void" "flare" "peak" "crest" "rise" "fall" "swift" "calm" \
                  "blue" "red" "green" "gold" "silver" "iron" "rust" "ash" "glow" "flare" \
                  "stone" "river" "brook" "creek" "hill" "mount" "valley" "shade" "beam")

# Função para selecionar uma palavra aleatória da lista
function generate_random_word() {
  echo ${random_word_list[$RANDOM % ${#random_word_list[@]}]}
}

# Gerar um nome de projeto com a palavra aleatória
random_word=$(generate_random_word)




projectname="redeToy_${random_word}"
branch_do_Permissionamento="-b migracao-hardhat"


# Função para garantir entrada numérica
function read_number() {
  local prompt=$1
  local number
  while true; do
    read -p "$prompt" number
    if [[ "$number" =~ ^[0-9]+$ ]]; then
      echo $number
      break
    else
      echo "Por favor, insira um número válido."
    fi
  done
}

# Função para verificar se as próximas 10 portas estão em uso
function check_ports_in_use() {
  local base_port=$1
  local num_ports=$((num_boots + num_validators + num_writers))  # Soma o número total de nós
  local next_port

  # Verifica as próximas 'num_ports' portas a partir da base_port
  for i in $(seq 0 $((num_ports - 1))); do
    next_port=$((base_port + i))
    
    # Usando ss para verificar se a porta está em uso
    if ss -tuln | grep -q ":$next_port "; then
      echo "Porta $next_port está em uso. Escolha outra porta inicial."
      return 1  # Retorna 1 para indicar que a verificação falhou
    fi
  done
  
  return 0  # Todas as portas estão livres
}

# Função para solicitar uma nova base_port se as portas estiverem em uso
function get_base_port() {
  while true; do
    base_port=$(read_number "Informe a porta inicial: ")
    
    # Verifica as 'num_ports' portas a partir da base_port
    if check_ports_in_use $base_port; then
      echo "Portas a partir de $base_port estão livres."
      break  # Sai do loop se as portas estiverem livres
    else
      echo "Por favor, escolha uma outra porta base."
    fi
  done

  echo "Porta base selecionada: $base_port"
}



# Perguntas interativas
num_validators=$(read_number "${yellow}Quantos validadores deseja criar?${normal} ")
num_boots=$(read_number "${blue}Quantos nós boot deseja criar?${normal} ")
num_writers=$(read_number "${yellow}Quantos nós writer deseja criar?${normal} ")
get_base_port

while true; do
  read -p "${blue}Deseja aplicar permissionamento? (s/n):${normal} " permissionamento
  case "$permissionamento" in
    [sS]) 
      echo "Permissionamento será aplicado."
      permissionamento="s"
      break
      ;;
    [nN]) 
      echo "Permissionamento não será aplicado."
      permissionamento="n"
      break
      ;;
    *) 
      echo "Por favor, responda com 's' ou 'n'."
      ;;
  esac
done


echo
echo "${bold}Nome do projeto: ${green}$projectname${normal}"
if [[ "$permissionamento" == "s" ]]; then
echo "${bold}Branch do permissionamento a ser usada: ${bold}${magenta}$branch_do_Permissionamento${normal}"
fi
echo



echo "Instalando start-network..."
git clone https://github.com/RBBNet/start-network.git -b main
mv start-network $projectname
cd $projectname





# Criação dos nós dinamicamente
nodes=""
for i in $(seq 1 $num_validators); do
  nodes+="validator$i, "
done
for i in $(seq 1 $num_boots); do
  nodes+="boot$i, "
done
for i in $(seq 1 $num_writers); do
  nodes+="writer$i, "
done
nodes=${nodes%, }  # Remove a última vírgula

./rbb-cli node create $nodes




# Definição das portas para os nós
declare -A node_port
port_offset=0

for i in $(seq 1 $num_boots); do
  port=$((base_port + port_offset))
  ./rbb-cli config set nodes.boot$i.ports+=[\"$port:8545\"]
  node_port["boot$i"]=$port  # Armazenando a porta no array node_port
  port_offset=$((port_offset + 1))
done

for i in $(seq 1 $num_validators); do
  port=$((base_port + port_offset))
  ./rbb-cli config set nodes.validator$i.ports+=[\"$port:8545\"]
  node_port["validator$i"]=$port  # Armazenando a porta no array node_port
  port_offset=$((port_offset + 1))
done

for i in $(seq 1 $num_writers); do
  port=$((base_port + port_offset))
  ./rbb-cli config set nodes.writer$i.ports+=[\"$port:8545\"]
  node_port["writer$i"]=$port  # Armazenando a porta no array node_port
  port_offset=$((port_offset + 1))
done






# Geração do genesis com validadores
for i in $(seq 1 $num_validators); do
  validators+="validator$i,"  # Concatenando "validator{i}," na variável
done
validators=${validators%, }


./rbb-cli genesis create --validators $validators


# desabilita o discovery nos validadores e writers
for i in $(seq 1 $num_validators); do
  ./rbb-cli config set nodes.validator$i.environment.BESU_DISCOVERY_ENABLED=false
done
for i in $(seq 1 $num_writers); do
  ./rbb-cli config set nodes.writer$i.environment.BESU_DISCOVERY_ENABLED=false
done

# Inicializa arrays para armazenar as chaves dos boots, validadores e writers
bootkeys=()
validatorkeys=()
writerkeys=()

# Preenche as chaves públicas dos boots
for i in $(seq 1 $num_boots); do
  bootkey=$(cat .env.configs/nodes/boot$i/key.pub | sed 's/^0x//')  # Remove o '0x'
  bootkeys+=("$bootkey")  # Armazena a chave no array
done

# Preenche as chaves públicas dos validadores
for i in $(seq 1 $num_validators); do
  validatorkey=$(cat .env.configs/nodes/validator$i/key.pub | sed 's/^0x//')  # Remove o '0x'
  validatorkeys+=("$validatorkey")  # Armazena a chave no array
done

# Preenche as chaves públicas dos writers
for i in $(seq 1 $num_writers); do
  writerkey=$(cat .env.configs/nodes/writer$i/key.pub | sed 's/^0x//')  # Remove o '0x'
  writerkeys+=("$writerkey")  # Armazena a chave no array
done




# Função para gerar o arquivo static-nodes.json
generate_static_nodes() {
  local node_name=$1  # Nome do nó que está sendo configurado
  shift
  local enodes=("$@")  # Lista de chaves públicas dos nós a serem incluídos

  echo "[" > volumes/$node_name/static-nodes.json
  for enode in "${enodes[@]}"; do
    # Adiciona cada chave pública com o nome do nó correspondente
    echo "$enode" >> volumes/$node_name/static-nodes.json
  done
  # Remove a última vírgula e fecha o JSON
  sed -i '$ s/,$//' volumes/$node_name/static-nodes.json
  echo "]" >> volumes/$node_name/static-nodes.json
}

# Para todos os validadores: Apontam entre si e para os boots
for i in $(seq 1 $num_validators); do
  node_name="validator$i"
  
  enodes=()

  # Adiciona as chaves dos boots com o nome correto
  for j in $(seq 1 $num_boots); do
    enodes+=("\"enode://${bootkeys[$((j-1))]}@boot$j:30303\",")
  done

  # Adiciona os validadores (exceto o próprio validador) com o nome correto
  for j in $(seq 1 $num_validators); do
    if [[ $i -ne $j ]]; then
      enodes+=("\"enode://${validatorkeys[$((j-1))]}@validator$j:30303\",")
    fi
  done

  # Gera o static-nodes.json para o validador atual
  generate_static_nodes "$node_name" "${enodes[@]}"
done

# Para todos os writers: Apontam apenas para os boots
for i in $(seq 1 $num_writers); do
  node_name="writer$i"
  
  enodes=()

  # Apenas as chaves dos boots com o nome correto
  for j in $(seq 1 $num_boots); do
    enodes+=("\"enode://${bootkeys[$((j-1))]}@boot$j:30303\",")
  done

  # Gera o static-nodes.json para o writer atual
  generate_static_nodes "$node_name" "${enodes[@]}"
done







./rbb-cli config render-templates


# Inicializa a string para armazenar os nomes dos containers
nodes_to_start=""

# Adiciona os validadores à string
for i in $(seq 1 $num_validators); do
  nodes_to_start+="validator$i "
done

# Adiciona os boots à string
for i in $(seq 1 $num_boots); do
  nodes_to_start+="boot$i "
done

# Adiciona os writers à string
for i in $(seq 1 $num_writers); do
  nodes_to_start+="writer$i "
done

# Executa o comando docker-compose com a string construída
docker-compose up -d $nodes_to_start


if [[ "$permissionamento" == "s" ]]; then
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

# get boot1 ip
boot1container=$(docker ps --format "{{.Names}}" | grep -i $(echo $projectname\_boot1))
docker inspect $boot1container
boot1ip=$(docker inspect $boot1container | grep IPAddr |  sed -n '3 p' | awk '{ print $2 }' | sed "s/\"//" | sed "s/\"//" | sed "s/,//")




# Gera o conteúdo do arquivo .env dinamicamente
echo "NODE_INGRESS_CONTRACT_ADDRESS=0x0000000000000000000000000000000000009999
ACCOUNT_INGRESS_CONTRACT_ADDRESS=0x0000000000000000000000000000000000008888
BESU_NODE_PERM_ACCOUNT=627306090abaB3A6e1400e9345bC60c78a8BEf57
BESU_NODE_PERM_KEY=c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3
BESU_NODE_PERM_ENDPOINT=http://localhost:${node_port[validator1]}
CHAIN_ID=648629" > .env

# Adiciona "INITIAL_ALLOWLISTED_NODES=" sem pular linha
echo -n "INITIAL_ALLOWLISTED_NODES=" >> .env

# Adiciona os boots ao INITIAL_ALLOWLISTED_NODES
for i in $(seq 1 $num_boots); do
  echo -n "enode://${bootkeys[$((i-1))]}|0|0x000000000000|Boot|BNDES," >> .env
done

# Adiciona os validadores ao INITIAL_ALLOWLISTED_NODES
for i in $(seq 1 $num_validators); do
  echo -n "enode://${validatorkeys[$((i-1))]}|1|0x000000000000|Validator|BNDES," >> .env
done

# Adiciona os writers ao INITIAL_ALLOWLISTED_NODES
for i in $(seq 1 $num_writers); do
  echo -n "enode://${writerkeys[$((i-1))]}|2|0x000000000000|Writer|BNDES" >> .env
  if [[ $i -ne $num_writers ]]; then
    echo -n "," >> .env  # Adiciona uma vírgula entre os writers, exceto o último
  fi
done

# Finaliza o arquivo .env com uma nova linha
echo "" >> .env



# verifica se a produção de blocos já começou
timeout=300  # Limite de tempo (300 segundos = 5 minutos)
elapsed=0
interval=10

while ! docker logs ${projectname,,}_validator1_1 2>&1 | grep -q Produced; do
  if (( elapsed >= timeout )); then
    echo "${vermelho}${bold}Tempo limite atingido, continuando sem produção de blocos detectada.${normal}"
    break
  fi
  echo "Aguardando produção de blocos do validator1..."
  sleep $interval
  ((elapsed+=interval))
done


# Implantação do permissionamento
yarn deploy --network besu

fi

#-------------- Informações dos nós ---------------


# Função para obter o IP de um container Docker
get_node_ip() {
  local node_name=$1
  # Formata o nome completo do container, por exemplo: redetoy_hardhat_general_validator1_1
  container="${projectname,,}_${node_name}_1"
  # Captura o IP do container usando docker inspect
  ip_address=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container" 2>/dev/null)
  
  if [[ -z "$ip_address" ]]; then
    echo "IP não encontrado"
  else
    echo "$ip_address"
  fi
}

# Exibe as informações dos nós criados
echo -e "\n${bold}Informações dos nós criados${normal}\n"

# Exibe os Boots
for i in $(seq 1 $num_boots); do
  node_name="boot$i"
  ip_address=$(get_node_ip "$node_name")
  port=${node_port[$node_name]}
  printf "${bold}%-12s${normal} =>\tIP: ${blue}%-15s${normal}\tPorta: ${blue}%s${normal}\n" "$node_name" "$ip_address" "$port"
done

# Exibe os Validadores
for i in $(seq 1 $num_validators); do
  node_name="validator$i"
  ip_address=$(get_node_ip "$node_name")
  port=${node_port[$node_name]}
  printf "${bold}%-12s${normal} =>\tIP: ${blue}%-15s${normal}\tPorta: ${blue}%s${normal}\n" "$node_name" "$ip_address" "$port"
done

# Exibe os Writers
for i in $(seq 1 $num_writers); do
  node_name="writer$i"
  ip_address=$(get_node_ip "$node_name")
  port=${node_port[$node_name]}
  printf "${bold}%-12s${normal} =>\tIP: ${blue}%-15s${normal}\tPorta: ${blue}%s${normal}\n" "$node_name" "$ip_address" "$port"
done





#----------------------------------
#cd .. && cd $projectname

echo
echo "para ver os logs digite o comando ${yellow}docker-compose -f ./$projectname/docker-compose.yml logs -f${normal}"
echo
