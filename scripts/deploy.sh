#!/bin/bash
network=$1

echo "Starting deployment on $network blockchain..."
hardhat --network $network deploy
if [[ $network = "kovan" || $network = "ropsten" || $network = "mainnet" ]]; then
    echo "Exporting contracts of $network blockchain..."
    hardhat --network $network export --export ./networks/$network.json
fi
