// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {CommitRecover} from "./Bicorn-RX/CommitRecover.sol";
import "./Bicorn-RX/libraries/Pietrzak_VDF.sol";
import "./Bicorn-RX/libraries/BigNumbers.sol";

contract Raffle is CommitRecover {
    using BigNumbers for *;
    mapping(uint256 round => address winnerAddress) public winnerAddresses;
    mapping(uint256 round => uint256 balance) public balancesAtRound;
    mapping(uint256 round => uint256 entranceFee) public entranceFeesAtRound;

    event RaffleEntered(address indexed _entrant, uint256 _amount);
    event RaffleWinner(address indexed _winner, uint256 _round);

    function setUp(
        uint256 _entranceFee,
        uint256 _commitDuration,
        uint256 _commitRevealDuration,
        BigNumber calldata _n,
        Pietrzak_VDF.VDFClaim[] calldata _proofs
    ) public {
        uint256 _round = _setUp(_commitDuration, _commitRevealDuration, _n, _proofs);
        entranceFeesAtRound[_round] = _entranceFee;
    }

    function enterRafByCommit(uint256 _round, BigNumber memory _c) public payable {
        require(msg.value == entranceFeesAtRound[_round], "wrong entrance fee");
        _commit(_round, _c);
        balancesAtRound[_round] += msg.value;
        emit RaffleEntered(msg.sender, msg.value);
    }

    function getWinnerAddress(uint256 _round) public view returns (address) {
        require(valuesAtRound[_round].isCompleted, "round not completed");
        // get the winner address by getting smallest | participantAddress % valuesAtRound[round].n - omega |
        uint256 winnderIndex = 0;
        BigNumber memory _n = setUpValuesAtRound[_round].n;
        BigNumber memory smallest = _n.add(BigNumbers.one());
        BigNumber memory _omega = valuesAtRound[_round].omega;
        for (uint256 i = 0; i < valuesAtRound[_round].numOfParticipants; i++) {
            BigNumber memory _value = abi
                .encodePacked(commitRevealValues[_round][i].participantAddress)
                .init()
                .mod(_n)
                .sub(_omega);
            // returns -1 on a<b, 0 on a==b, 1 on a>b.
            if (_value.cmp(smallest) == -1) {
                smallest = _value;
                winnderIndex = i;
            }
        }
        // address _winnerAddress = commitRevealValues[_round][winnderIndex].participantAddress;
        // emit RaffleWinner(_winnerAddress, _round);
        return commitRevealValues[_round][winnderIndex].participantAddress;
        //winnerAddresses[_round] = _winnerAddress;
    }

    function withdraw(uint256 _round) public {
        address _winnerAddress = getWinnerAddress(_round);
        require(_winnerAddress == msg.sender, "not winner");
        payable(msg.sender).transfer(balancesAtRound[_round]);
    }
}
