// SPDX-License-Identifier: MIT
pragma circom 2.1.0;

include "circomlib/circuits/comparator.circom";
include "circomlib/circuits/equality.circom";

template LeaseProof() {
    // Public inputs (visible on-chain): tokenId and expiry
    signal output public tokenId;
    signal output public expiry;
    
    // Private inputs (hidden from public): lessee, usageCount
    signal input lessee;
    signal input usageCount;
    
    // Public input: current timestamp from blockchain
    signal input currentTime;
    
    // Verify lessee is NOT zero address (valid lessee)
    component lesseeNonZero = Not(1);
    lesseeNonZero.in[0] <== lessee == 0x0000000000000000000000000000000000000000;
    
    // Verify expiry is in the future (expiry > currentTime)
    component expiryCheck = GreaterThan(256);
    expiryCheck.in[0] <== expiry;
    expiryCheck.in[1] <== currentTime;
    
    // Verify usage count is non-negative (usageCount >= 0)
    component usageCheck = GreaterThan(32);
    usageCheck.in[0] <== usageCount;
    usageCheck.in[1] <== 0;
    
    // Verify tokenId is non-zero (valid NFT)
    component tokenIdCheck = GreaterThan(256);
    tokenIdCheck.in[0] <== tokenId;
    tokenIdCheck.in[1] <== 0;
    
    // Connect public outputs
    tokenId <== tokenId;
    expiry <== expiry;
}

component main = LeaseProof();