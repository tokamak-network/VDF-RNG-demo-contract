// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./CommitRevealRecoverRNG/CommitRevealRecoverRNG.sol";

contract RandomAirdrop is CommitRevealRecoverRNG {
    using BigNumbers for *;
    mapping(address participantAddress => uint256[] rounds) private participatedRounds;
    uint256 public randomAirdropRound;

    event RandomAirdropEntered(address indexed _entrant, uint256 _timestamp);

    function setUp(
        uint256 _commitDuration,
        uint256 _commitRevealDuration,
        BigNumber calldata _n,
        VDFClaim[] calldata _proofs
    ) public {
        checkStage(randomAirdropRound);
        if (valuesAtRound[randomAirdropRound].stage != Stages.Finished) revert StageNotFinished();
        uint256 _round = _setUp(_commitDuration, _commitRevealDuration, _n, _proofs);
        randomAirdropRound = _round;
    }

    function enterEventByCommit(BigNumber memory _c) public {
        uint256 _round = randomAirdropRound;
        _commit(_round, _c);
        participatedRounds[msg.sender].push(_round);
        emit RandomAirdropEntered(msg.sender, block.timestamp);
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
