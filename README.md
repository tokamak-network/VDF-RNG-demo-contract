# RAFFLE-Bicorn-RX

Raffle App using Commit Reveal Recover<br>

## INSTALL
```shell
yarn
```

## SET .env
```shell
ALCHEMY_MAINNET_RPC_URL=<GET_URL_FROM_https://dashboard.alchemy.com/>
MAINNET_RPC_URL=<GET_URL_FROM_https://app.infura.io/dashboard>
SEPOLIA_RPC_URL=<GET_URL_FROM_https://app.infura.io/dashboard>
ALCHEMY_SEPOLIA_RPC_URL=<GET_URL_FROM_https://dashboard.alchemy.com/>
POLYGON_MAINNET_RPC_URL=<GET_URL_FROM_https://app.infura.io/dashboard>
PRIVATE_KEY=<PRIVATE_KEY>
ETHERSCAN_API_KEY=<GET_KEY_FROM_https://etherscan.io/myapikey/>
REPORT_GAS=true
COINMARKETCAP_API_KEY=<GET_KEY_FROM_https://pro.coinmarketcap.com/account/>
```

## DEPLOYMENT & VERIFICATION
- Guide(login required) : https://www.notion.so/onther/verify-contract-4b72acaa7e6c4dd0a8ee09fddfa6c539
### to localhost
```shell
npx hardhat node
#Started HTTP and WebSocket JSON-RPC server at http://127.0.0.1:8545/
npx hardhat deploy --network localhost --tags raffle
#deploying "CommitRecover" (tx: 0xec0ed0faa71c54e85ecec9347227609b69acd980e00e35a1e3839bc71409b222)...: deployed at 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 with 2821690 gas
```

### to target network
```shell
## CHANGE in hardhat.config.ts files at network :{} section
## It will deploy and verify, If verify gives an error, you can simply run the command one more time.
npx hardhat deploy --network <WRITE_YOUR_OWN_NETWORK_NAME> --tags raffle
```

## TEST

### WIP