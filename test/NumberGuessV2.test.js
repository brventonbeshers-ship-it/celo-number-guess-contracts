const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NumberGuessV2", function () {
  let ng, owner, player;

  beforeEach(async function () {
    [owner, player] = await ethers.getSigners();
    const NG = await ethers.getContractFactory("NumberGuessV2");
    ng = await NG.deploy();
  });

  it("should start with zero guesses", async function () {
    expect(await ng.totalGuesses()).to.equal(0);
  });

  it("should allow a valid guess", async function () {
    await ng.connect(player).guess(42);
    expect(await ng.totalGuesses()).to.equal(1);
  });

  it("should reject guess below 1", async function () {
    await expect(ng.connect(player).guess(0)).to.be.revertedWith("Invalid number");
  });

  it("should reject guess above 100", async function () {
    await expect(ng.connect(player).guess(101)).to.be.revertedWith("Invalid number");
  });

  it("should track user stats", async function () {
    await ng.connect(player).guess(10);
    await ng.connect(player).guess(50);
    const stats = await ng.getUserStats(player.address);
    expect(stats.guesses).to.equal(2);
  });

  it("should emit GuessResult event", async function () {
    await expect(ng.connect(player).guess(25)).to.emit(ng, "GuessResult");
  });

  it("should allow owner to pause", async function () {
    await ng.setGamePaused(true);
    await expect(ng.connect(player).guess(1)).to.be.revertedWith("Game paused");
  });
});
