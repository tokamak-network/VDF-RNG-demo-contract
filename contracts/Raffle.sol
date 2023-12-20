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
    mapping(address participantAddress => uint256[] rounds) private participatedRounds;
    uint256 public raffleRound;

    event RaffleEntered(address indexed _entrant, uint256 _amount);
    event RaffleWinner(address indexed _winner, uint256 _round);
    error EntranceFeeZero();

    function setUp(
        uint256 _entranceFee,
        uint256 _commitDuration,
        uint256 _commitRevealDuration,
        BigNumber calldata _n,
        Pietrzak_VDF.VDFClaim[] calldata _proofs
    ) public {
        checkStage(raffleRound);
        if (valuesAtRound[raffleRound].stage != Stages.Finished) revert StageNotFinished();
        if (_entranceFee == 0) revert EntranceFeeZero();
        uint256 _round = _setUp(_commitDuration, _commitRevealDuration, _n, _proofs);
        entranceFeesAtRound[_round] = _entranceFee;
        raffleRound = _round;
    }

    function enterRafByCommit(BigNumber memory _c) public payable {
        uint256 _round = raffleRound;
        require(msg.value == entranceFeesAtRound[_round], "wrong entrance fee");
        _commit(_round, _c);
        balancesAtRound[_round] += msg.value;
        participatedRounds[msg.sender].push(_round);
        emit RaffleEntered(msg.sender, msg.value);
    }

    function getRankPointOfEachParticipants(
        uint256 _round
    ) public view returns (address[] memory addresses, bytes[] memory rankPoints) {
        require(valuesAtRound[_round].isCompleted, "round not completed");
        addresses = new address[](valuesAtRound[_round].numOfParticipants);
        rankPoints = new bytes[](valuesAtRound[_round].numOfParticipants);
        for (uint256 i = 0; i < valuesAtRound[_round].numOfParticipants; i++) {
            address _address = commitRevealValues[_round][i].participantAddress;
            addresses[i] = _address;
            bytes memory a = abi.encodePacked(keccak256(commitRevealValues[_round][i].c.val));
            bytes memory b = abi.encodePacked(keccak256(abi.encodePacked(_address)));
            rankPoints[i] = a.init().sub(b.init()).val;
        }
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
        require(winnerAddresses[_round] == address(0), "winner already withdrawn");
        require(_winnerAddress == msg.sender, "not winner");
        winnerAddresses[_round] = _winnerAddress;
        payable(msg.sender).transfer(balancesAtRound[_round]);
    }

    function getParticipatedRounds() public view returns (uint256[] memory) {
        return participatedRounds[msg.sender];
    }
}
