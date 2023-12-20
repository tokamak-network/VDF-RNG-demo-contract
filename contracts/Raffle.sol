// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {CommitRecover} from "./Bicorn-RX/CommitRecover.sol";
import "./Bicorn-RX/libraries/Pietrzak_VDF.sol";
import "./Bicorn-RX/libraries/BigNumbers.sol";

contract Raffle is CommitRecover {
    using BigNumbers for *;
    mapping(address participantAddress => uint256[] rounds) private participatedRounds;
    uint256 public raffleRound;

    event RaffleEntered(address indexed _entrant, uint256 _timestamp);

    function setUp(
        uint256 _commitDuration,
        uint256 _commitRevealDuration,
        BigNumber calldata _n,
        Pietrzak_VDF.VDFClaim[] calldata _proofs
    ) public {
        checkStage(raffleRound);
        if (valuesAtRound[raffleRound].stage != Stages.Finished) revert StageNotFinished();
        uint256 _round = _setUp(_commitDuration, _commitRevealDuration, _n, _proofs);
        raffleRound = _round;
    }

    function enterRafByCommit(BigNumber memory _c) public {
        uint256 _round = raffleRound;
        _commit(_round, _c);
        participatedRounds[msg.sender].push(_round);
        emit RaffleEntered(msg.sender, block.timestamp);
    }

    function getRankPointOfEachParticipants(
        uint256 _round
    ) public view returns (address[] memory addresses, bytes[] memory rankPoints) {
        require(valuesAtRound[_round].isCompleted, "round not completed");
        BigNumber memory a = abi.encodePacked(keccak256(valuesAtRound[_round].omega.val)).init();
        addresses = new address[](valuesAtRound[_round].numOfParticipants);
        rankPoints = new bytes[](valuesAtRound[_round].numOfParticipants);
        for (uint256 i = 0; i < valuesAtRound[_round].numOfParticipants; i++) {
            address _address = commitRevealValues[_round][i].participantAddress;
            addresses[i] = _address;
            bytes memory b = abi.encodePacked(keccak256(abi.encodePacked(_address)));
            rankPoints[i] = a.sub(b.init()).val;
        }
    }

    function getParticipatedRounds() public view returns (uint256[] memory) {
        return participatedRounds[msg.sender];
    }
}
