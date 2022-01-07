#!/bin/bash
dotenv() {
    set -a
    [ -f .env ] && . .env
    set +a
}
dotenv
network=$1
endpoint="$ETHERSCAN_API_KEY"
echo "Starting etherscan verification on $network blockchain..."
hardhat --network $network etherscan-verify --solc-input --api-key $endpoint --license "AMIT" --force-license
