# Repositório de Scripts da RBB

Este repositório contém diversos scripts utilitários para uso na RBB.

## Rede Toy

O script da pasta [`redeToy`](redeToy) permite a criação de uma rede de bancada para testes conforme infraestrutra padrão da RBB.


## QBFT Votes

O script da pasta [`qbft-votes`](qbft-votes) permite a leitura e pesquisa de votos para inclusão e exclusão de validadores no protocolo QBFT quando utilizado a [seleção de validadores por cabeçalho de bloco (block header)](https://docs.besu-eth.org/private-networks/how-to/configure/consensus/qbft#add-and-remove-validators-using-block-headers).

## Validators

O script da pasta [`validators`](validators) permite a leitura de quais validadores faziam parte do consenso da rede, analisando-se o campo [*extra data*](https://docs.besu-eth.org/private-networks/how-to/configure/consensus/qbft#extra-data) de cada bloco.