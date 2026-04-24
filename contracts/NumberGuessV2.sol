// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract NumberGuessV2 {
    uint256 public constant MAX_NUMBER = 100;
    address public owner;
    uint256 public totalGuesses;
    uint256 public totalWins;
    bool public gamePaused;

    struct UserStats {
        uint256 guesses;
        uint256 wins;
        uint256 lastGuess;
        uint256 lastTarget;
    }

    mapping(address => UserStats) public userStats;

    event GuessResult(address indexed player, uint256 guess, uint256 target, bool win);

    modifier onlyOwner() { require(msg.sender == owner, "Not authorized"); _; }
    modifier whenNotPaused() { require(!gamePaused, "Game paused"); _; }

    constructor() { owner = msg.sender; }

    function guess(uint256 number) external whenNotPaused returns (uint256 target, bool win) {
        require(number >= 1 && number <= MAX_NUMBER, "Invalid number");

        target = _generateTarget();
        win = (number == target);

        totalGuesses++;
        if (win) totalWins++;

        UserStats storage stats = userStats[msg.sender];
        stats.guesses++;
        if (win) stats.wins++;
        stats.lastGuess = number;
        stats.lastTarget = target;

        emit GuessResult(msg.sender, number, target, win);
    }

    function getUserStats(address user) external view returns (uint256 guesses, uint256 wins, uint256 lastGuess, uint256 lastTarget) {
        UserStats memory s = userStats[user];
        return (s.guesses, s.wins, s.lastGuess, s.lastTarget);
    }

    function setGamePaused(bool _paused) external onlyOwner { gamePaused = _paused; }

    function _generateTarget() private view returns (uint256) {
        uint256 hash = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender, totalGuesses, block.timestamp)));
        return (hash % MAX_NUMBER) + 1;
    }
}
