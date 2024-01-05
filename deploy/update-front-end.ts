// Copyright 2023 justin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
import { ethers } from "hardhat"
import fs from "fs"
import { network } from "hardhat"
const FRONT_END_ADDRESS_FILE = __dirname + "/../../demo-front2/constants/contractAddress.json"
const FRONT_END_ABI_FILE = __dirname + "/../../demo-front2/constants/abi.json"
export default async function updateFrontEnd() {
    if (process.env.UPDATE_ABI_ADDRESS_FRONTEND_VDFPROVER) {
        console.log("Updating front end...")
        await updateContractAddress()
        await updateAbi()
    }
}
async function updateAbi() {
    const raffle = await ethers.getContract("Raffle")
    fs.writeFileSync(FRONT_END_ABI_FILE, raffle.interface.formatJson())
}

async function updateContractAddress() {
    const raffle = await ethers.getContract("Raffle")
    const chainId = network.config.chainId?.toString()!
    const currentAddress = JSON.parse(fs.readFileSync(FRONT_END_ADDRESS_FILE, "utf8"))
    if (chainId in currentAddress) {
        if (!currentAddress[chainId].includes(await raffle.getAddress())) {
            currentAddress[chainId].push(await raffle.getAddress())
        }
    }
    {
        currentAddress[chainId] = [await raffle.getAddress()]
    }
    fs.writeFileSync(FRONT_END_ADDRESS_FILE, JSON.stringify(currentAddress))
}
updateFrontEnd.tags = ["all", "frontend"]
