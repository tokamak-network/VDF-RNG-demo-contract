// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./CommitRevealRecoverRNG/CommitRevealRecoverRNG.sol";

contract RandomAirdrop is CommitRevealRecoverRNG {
    using BigNumbers for *;
    mapping(address participantAddress => uint256[] rounds) private participatedRounds;
    mapping(address participantAddress => mapping(uint256 round => uint256 registerIndex))
        private registerIndexPlusOneAtRound;
    mapping(uint256 round => address[] participants) private participantsAtRound;
    uint256 public randomAirdropRound;

    error RoundNotCompleted();
    error AlreadyRegistered();

    event RandomAirdropRegisteredAtRound(address indexed _entrant, uint256 _timestamp);

    function setUp(
        uint256 _commitDuration,
        uint256 _commitRevealDuration,
        BigNumber calldata _n,
        VDFClaim[] calldata _proofs
    ) external override returns (uint256) {
        checkStage(randomAirdropRound);
        if (valuesAtRound[randomAirdropRound].stage != Stages.Finished) revert StageNotFinished();
        uint256 _round = _setUp(_commitDuration, _commitRevealDuration, _n, _proofs);
        randomAirdropRound = _round;
        return _round;
    }

    function registerNextRound() external {
        uint256 _round = nextRound;
        if (registerIndexPlusOneAtRound[msg.sender][_round] != 0) revert AlreadyRegistered();
        registerIndexPlusOneAtRound[msg.sender][_round] = participantsAtRound[_round].length + 1;
        participantsAtRound[_round].push(msg.sender);
        participatedRounds[msg.sender].push(_round);
    }

    function getRankPointOfEachParticipants(
        uint256 _round
    ) external view returns (address[] memory addresses, bytes[] memory rankPoints) {
        if (!valuesAtRound[_round].isCompleted) revert RoundNotCompleted();
        BigNumber memory a = abi.encodePacked(keccak256(valuesAtRound[_round].omega.val)).init();
        uint256 numOfParticipants = participantsAtRound[_round].length;
        addresses = new address[](numOfParticipants);
        rankPoints = new bytes[](numOfParticipants);
        for (uint256 i; i < numOfParticipants; i++) {
            address _address = participantsAtRound[_round][i];
            addresses[i] = _address;
            bytes memory b = abi.encodePacked(keccak256(abi.encodePacked(_address)));
            rankPoints[i] = a.sub(b.init()).val;
        }
    }

    function getParticipatedRounds() external view returns (uint256[] memory) {
        return participatedRounds[msg.sender];
    }

    function getParticipantsAtRound(uint256 _round) external view returns (address[] memory) {
        return participantsAtRound[_round];
    }

    function getParticipantsLengthAtRound(uint256 _round) external view returns (uint256) {
        return participantsAtRound[_round].length;
    }
}
