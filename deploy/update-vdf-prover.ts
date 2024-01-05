// Copyright 2024 justin
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
import { ethers, network } from "hardhat"
import fs from "fs"
const VDF_PROVER_ABI_FILE = __dirname + "/../../VDF-prover/contractABI.json"

export default async function updateVDFProver() {
    if (process.env.UPDATE_ABI_ADDRESS_FRONTEND_VDFPROVER) {
        console.log("Updating front end...")
        await updateAbi()
    }
}
async function updateAbi() {
    const raffle = await ethers.getContract("Raffle")
    fs.writeFileSync(VDF_PROVER_ABI_FILE, raffle.interface.formatJson())
}
