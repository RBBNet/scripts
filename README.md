# Roteiro para script Geral (Hardhat General)

Este roteiro tem como objetivo explicar como rodar o script para subir uma rede de bancada com *x* validadores, sendo *x* um número qualquer desejado pelo usuário.

> [!CAUTION]
>O script deve **sempre** ser executado em ambiente Linux. O comportamento do script em ambiente Windows é imprevisível.

## Como executar

📌 Primeiro, dê permissão para o script. Depois, execute-o. Os comandos seguem abaixo:

```
chmod +x redeToy_HardHat_General.sh
./redeToy_HardHat_General.sh
```

📌Caso o script encontre problemas na execução, faça no terminal:

```
sed -i 's/\r//' redeToy_HardHat_General.sh
```

e execute normalmente em seguida. O script irá perguntar primeiro qual é a versão do Besu. Aperte enter para a *latest* ou insira uma versão válida. Depois, ele irá perguntar sobre desativar a opção *secp256k1.randomize*, cuja resposta pode ser Sim/Não.

📌 O randomize como False é o contorno ao fato de, a partir de uma determinada versão do Besu, essa biblioteca demorar tempo de grandeza indefinida para terminar de carregar, o que tornou o script de rede de bancada inviável. 

>[!NOTE]
> A partir da versão 23.4.1 do Besu, a solução para evitar que os contêineres fiquem *unhealthy* não funciona mais. Se quiser usufruir dessa solução, utilize essa versão ou uma anterior.


## Versionamento
Mais informações [aqui](https://github.com/RBBNet/rbb/blob/master/Versionamento.md). O versionamento semântico é uma boa prática que adotamos, seguindo o guia disponível em https://semver.org/. O Permissionamento já segue essa prática.

No caso dos scripts, a API pública são os próprios scripts.

⚠️ **IMPORTANTE**: ler sessão [_Dinâmica_](https://github.com/RBBNet/rbb/blob/master/Versionamento.md#din%C3%A2mica), que dita o comportamento para a implementação de novas funcionalidades.