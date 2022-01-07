#!/bin/bash
dotenv() {
  set -a
  [ -f .env ] && . .env
  set +a
}
dotenv
network=$1
mnemonic="$DEPLOY_MNEMONIC"
echo "Starting local fork of $network blockchain..."
if [ $network = "kovan" ]; then
  networkId=42
elif [ $network = "ropsten" ]; then
  networkId=3
elif [ $network = "mainnet" ]; then
  networkId=1
else
  echo "Error: Network does not exist"
  exit 1
fi
endpoint="https://$network.infura.io/v3/$INFURA_TOKEN"
ganache-cli -a 10 -b 2 -p 8545 -i $networkId --chainId $networkId -m "$mnemonic" -f $endpoint --keepAliveTimeout 6000
