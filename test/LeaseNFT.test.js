// SPDX-License-Identifier: MIT
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("LeaseNFT", function () {
    let leaseNFT;
    let verifier;
    let owner, lessee, other;
    let tokenId;

    beforeEach(async function () {
        [owner, lessee, other] = await ethers.getSigners();

        const LeaseVerifier = await ethers.getContractFactory("LeaseVerifier");
        verifier = await LeaseVerifier.deploy();
        await verifier.waitForDeployment();

        const LeaseNFT = await ethers.getContractFactory("LeaseNFT");
        leaseNFT = await LeaseNFT.deploy(await verifier.getAddress());
        await leaseNFT.waitForDeployment();

        tokenId = 1;
        await leaseNFT.mint(owner.address, tokenId);
    });

    describe("Lease Creation", function () {
        it("Should grant lease successfully", async function () {
            const expiry = Math.floor(Date.now() / 1000) + 86400;
            
            await expect(
                leaseNFT.grantLease(tokenId, lessee.address, expiry)
            ).to.emit(leaseNFT, "LeaseGranted");

            const lease = await leaseNFT.leases(tokenId);
            expect(lease.lessee).to.equal(lessee.address);
            expect(lease.expiry).to.equal(expiry);
            expect(lease.active).to.be.true;
        });

        it("Should revert if lessee is zero address", async function () {
            const expiry = Math.floor(Date.now() / 1000) + 86400;
            
            await expect(
                leaseNFT.grantLease(tokenId, ethers.ZeroAddress, expiry)
            ).to.be.revertedWith("Invalid lessee");
        });

        it("Should revert if expiry is in the past", async function () {
            const expiry = Math.floor(Date.now() / 1000) - 100;
            
            await expect(
                leaseNFT.grantLease(tokenId, lessee.address, expiry)
            ).to.be.revertedWith("Expiry in past");
        });

        it("Should revert if not NFT owner", async function () {
            const expiry = Math.floor(Date.now() / 1000) + 86400;
            
            await expect(
                leaseNFT.connect(other).grantLease(tokenId, lessee.address, expiry)
            ).to.be.revertedWith("Not owner");
        });

        it("Should revert if lease already active", async function () {
            const expiry = Math.floor(Date.now() / 1000) + 86400;
            
            await leaseNFT.grantLease(tokenId, lessee.address, expiry);
            
            await expect(
                leaseNFT.grantLease(tokenId, lessee.address, expiry)
            ).to.be.revertedWith("Lease active");
        });
    });

    describe("Lease Expiry", function () {
        it("Should emit LeaseExpired event when time passes", async function () {
            const expiry = Math.floor(Date.now() / 1000) + 10;
            
            await leaseNFT.grantLease(tokenId, lessee.address, expiry);
            
            await ethers.provider.send("evm_increaseTime", [15]);
            await ethers.provider.send("evm_mine", []);

            await expect(
                leaseNFT.expireLease(tokenId)
            ).to.emit(leaseNFT, "LeaseExpired");

            const lease = await leaseNFT.leases(tokenId);
            expect(lease.active).to.be.false;
        });

        it("Should revert if lease not active", async function () {
            await expect(
                leaseNFT.expireLease(tokenId)
            ).to.be.revertedWith("Lease not active");
        });

        it("Should revert if not owner", async function () {
            const expiry = Math.floor(Date.now() / 1000) + 86400;
            
            await leaseNFT.grantLease(tokenId, lessee.address, expiry);
            
            await expect(
                leaseNFT.connect(other).expireLease(tokenId)
            ).to.be.revertedWith("Not owner");
        });
    });

    describe("Usage Recording", function () {
        it("Should record usage count", async function () {
            const expiry = Math.floor(Date.now() / 1000) + 86400;
            
            await leaseNFT.grantLease(tokenId, lessee.address, expiry);
            
            await expect(
                leaseNFT.recordUsage(tokenId, 5)
            ).to.emit(leaseNFT, "UsageRecorded");

            const usage = await leaseNFT.totalUsage(tokenId);
            expect(usage).to.equal(5);
        });

        it("Should revert if lease not active", async function () {
            await expect(
                leaseNFT.recordUsage(tokenId, 5)
            ).to.be.revertedWith("Lease not active");
        });

        it("Should revert if usage count exceeds limit", async function () {
            const expiry = Math.floor(Date.now() / 1000) + 86400;
            
            await leaseNFT.grantLease(tokenId, lessee.address, expiry);
            
            await expect(
                leaseNFT.recordUsage(tokenId, 1000001)
            ).to.be.revertedWith("Usage limit exceeded");
        });
    });

    describe("Lease Termination", function () {
        it("Owner should terminate lease early", async function () {
            const expiry = Math.floor(Date.now() / 1000) + 86400;
            
            await leaseNFT.grantLease(tokenId, lessee.address, expiry);
            
            await expect(
                leaseNFT.terminateLease(tokenId)
            ).to.emit(leaseNFT, "LeaseTerminated");

            const lease = await leaseNFT.leases(tokenId);
            expect(lease.active).to.be.false;
        });

        it("Should revert if lease not active", async function () {
            await expect(
                leaseNFT.terminateLease(tokenId)
            ).to.be.revertedWith("Lease not active");
        });

        it("Should revert if not owner", async function () {
            const expiry = Math.floor(Date.now() / 1000) + 86400;
            
            await leaseNFT.grantLease(tokenId, lessee.address, expiry);
            
            await expect(
                leaseNFT.connect(other).terminateLease(tokenId)
            ).to.be.revertedWith("Not owner");
        });
    });

    describe("ZK Verification Integration", function () {
        it("Should verify proof and activate lease", async function () {
            const expiry = Math.floor(Date.now() / 1000) + 86400;
            const usageCount = 100;
            const commitment = ethers.id("lease-commitment");

            await expect(
                verifier.verifyAndActivate(
                    tokenId,
                    lessee.address,
                    expiry,
                    usageCount,
                    "0x"
                )
            ).to.emit(verifier, "ProofVerified");

            const verified = await verifier.verifiedProofs(
                ethers.id(`${tokenId}-${expiry}-${usageCount}`)
            );
            expect(verified).to.be.true;
        });

        it("Should revert if proof already verified", async function () {
            const expiry = Math.floor(Date.now() / 1000) + 86400;
            const usageCount = 100;

            await verifier.verifyAndActivate(
                tokenId,
                lessee.address,
                expiry,
                usageCount,
                "0x"
            );

            await expect(
                verifier.verifyAndActivate(
                    tokenId,
                    lessee.address,
                    expiry,
                    usageCount,
                    "0x"
                )
            ).to.be.revertedWith("Proof already verified");
        });
    });

    describe("Owner Functions", function () {
        it("Owner should set new verifier", async function () {
            const newVerifier = await ethers.deployContract("LeaseVerifier");
            await newVerifier.waitForDeployment();

            await expect(
                leaseNFT.setVerifier(await newVerifier.getAddress())
            ).to.emit(leaseNFT, "VerifierUpdated");

            expect(await leaseNFT.verifier()).to.equal(await newVerifier.getAddress());
        });

        it("Should revert if not owner", async function () {
            const newVerifier = await ethers.deployContract("LeaseVerifier");
            await newVerifier.waitForDeployment();

            await expect(
                leaseNFT.connect(other).setVerifier(await newVerifier.getAddress())
            ).to.be.revertedWith("Ownable: caller is not the owner");
        });

        it("Should mint new NFTs", async function () {
            const newTokenId = 2;
            
            await expect(
                leaseNFT.mint(other.address, newTokenId)
            ).to.emit(leaseNFT, "Transfer");

            expect(await leaseNFT.ownerOf(newTokenId)).to.equal(other.address);
        });
    });
});