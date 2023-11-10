// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {CommitRecover} from "./Bicorn-RX/CommitRecover.sol";

contract Raffle is CommitRecover {
    uint256 public entranceFee;
    mapping(uint256 round => address winnerAddress) public winnerAddresses;
    mapping(uint256 round => uint256 balance) public balancesAtRound;

    event RaffleEntered(address indexed _entrant, uint256 _amount);
    event RaffleWinner(address indexed _winner, uint256 _round);

    constructor(uint256 _entranceFee) {
        entranceFee = _entranceFee;
    }

    function enterRafByCommit(uint256 _c) public payable {
        require(msg.value >= entranceFee, "not enough eth");
        _commit(_c);
        balancesAtRound[round] += msg.value;
        emit RaffleEntered(msg.sender, msg.value);
    }

    //
    function getWinnerAddress(uint256 _round) public {
        require(valuesAtRound[_round].isCompleted, "round not completed");
        // get the winner address by getting smallest | participantAddress % valuesAtRound[round].n - omega |
        int256 smallest = type(int256).max;
        uint256 winnderIndex = 0;
        uint256 _n = valuesAtRound[_round].n;
        uint256 _omega = valuesAtRound[_round].omega;
        for (uint256 i = 0; i < valuesAtRound[_round].numOfParticipants; i++) {
            // get the smallest
            int256 _value = abs(
                (int256((uint256((uint160(commitRevealValues[_round][i].participantAddress))))) %
                    int256(_n)) - int256(_omega)
            );
            if (_value < smallest) {
                smallest = _value;
                winnderIndex = i;
            }
        }
        address _winnerAddress = commitRevealValues[_round][winnderIndex].participantAddress;
        winnerAddresses[_round] = _winnerAddress;
        emit RaffleWinner(_winnerAddress, _round);
    }

    function withdraw(uint256 _round) public {
        require(winnerAddresses[_round] == msg.sender, "not winner");
        payable(msg.sender).transfer(balancesAtRound[_round]);
    }

    function abs(int x) private pure returns (int) {
        return x >= 0 ? x : -x;
    }
}
