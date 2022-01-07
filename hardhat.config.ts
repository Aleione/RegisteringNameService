require("dotenv").config();

import { HardhatUserConfig } from "hardhat/config";

import "@nomiclabs/hardhat-etherscan";
import "solidity-coverage";
import "hardhat-deploy";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: { enabled: true, runs: 200 },
    },
  },
  namedAccounts: {
    deployer: 0,
    owner: 1,
  },
  networks: {
    hardhat: {
      accounts: { mnemonic: process.env.DEPLOY_MNEMONIC },
      live: false,
      saveDeployments: false,
      tags: ["hardhat"],
    },
    kovan: {
      chainId: 42,
      url: "https://kovan.infura.io/v3/" + process.env.INFURA_TOKEN,
      // @ts-ignore
      accounts: { mnemonic: process.env.DEPLOY_MNEMONIC },
      live: true,
      saveDeployments: true,
      tags: ["kovan"],
    },
    kovan_fork: {
      chainId: 42,
      url: "http://127.0.0.1:8545",
      live: true,
      saveDeployments: true,
      tags: ["kovan_fork"],
    },
    ropsten: {
      chainId: 3,
      url: "https://ropsten.infura.io/v3/" + process.env.INFURA_TOKEN,
      // @ts-ignore
      accounts: { mnemonic: process.env.DEPLOY_MNEMONIC },
      live: true,
      saveDeployments: true,
      tags: ["ropsten"],
    },
    ropsten_fork: {
      chainId: 3,
      url: "http://127.0.0.1:8545",
      live: true,
      saveDeployments: true,
      tags: ["ropsten_fork"],
    },
    mainnet: {
      chainId: 1,
      url: "https://mainnet.infura.io/v3/" + process.env.INFURA_TOKEN,
      // @ts-ignore
      accounts: { mnemonic: process.env.DEPLOY_MNEMONIC },
      live: true,
      saveDeployments: true,
      tags: ["mainnet"],
    },
    mainnet_fork: {
      chainId: 1,
      url: "http://127.0.0.1:8545",
      live: true,
      saveDeployments: true,
      tags: ["mainnet_fork"],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_KEY,
  },
};

export default config;
