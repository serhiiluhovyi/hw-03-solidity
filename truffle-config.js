const path = require('path');
const envPath = path.join(__dirname, './.env');
require('dotenv').config({ path: envPath });

const HDWalletProvider = require("@truffle/hdwallet-provider");
const infuraKey = process.env.INFURA_KEY;

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
      gas: 6021975,
    },
    rinkeby: {
      provider: () => new HDWalletProvider([process.env.PRIVATE_KEY_TESTNET], "wss://rinkeby.infura.io/ws/v3/" + infuraKey),
      network_id: 4,
      gas: 10000000,
      timeoutBlocks: 200,
      gasPrice: 20000000000,
      networkCheckTimeout: 1000000,
      skipDryRun: true,
      websockets: true
    }
  },
  contracts_directory: './contracts/',
  contracts_build_directory: './truffle_abis/',
  mocha: {
    // timeout: 100000
  },
  compilers: {
    solc: {
      version: "0.8.10",
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 200
        }
        //  evmVersion: "byzantium"
      }
    }
  },
  plugins: ["truffle-plugin-verify"],
  api_keys: {
    etherscan: process.env.ETHERSCAN_API_KEY
  }
}


