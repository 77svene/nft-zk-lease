// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract LeaseVerifier is Ownable {
    struct LeaseProof {
        uint256[2] a;
        uint256[2][2] b;
        uint256[2] c;
    }

    struct LeaseCredential {
        uint256 tokenId;
        uint256 expiry;
        uint256 commitment;
    }

    mapping(bytes32 => bool) public verifiedProofs;
    uint256 public constant MAX_EXPIRY_OFFSET = 31536000;
    uint256 public constant MIN_EXPIRY_OFFSET = 3600;
    uint256 public constant CURVE_ORDER = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    event ProofVerified(uint256 indexed tokenId, address indexed lessee, uint256 expiry);
    event LeaseActivated(uint256 indexed tokenId, address indexed lessee);

    constructor() Ownable(msg.sender) {}

    modifier onlyOwner() {
        require(msg.sender == owner(), "Not owner");
        _;
    }

    function verifyAndActivate(
        uint256 tokenId,
        address lessee,
        uint256 expiry,
        uint32 usageCount,
        bytes calldata proof
    ) external returns (bool) {
        require(tokenId > 0, "Invalid tokenId");
        require(lessee != address(0), "Invalid lessee");
        require(expiry > block.timestamp, "Expiry in past");
        require(expiry <= block.timestamp + MAX_EXPIRY_OFFSET, "Expiry too far");
        require(usageCount > 0, "Invalid usage count");

        LeaseProof memory zp = parseProof(proof);
        bytes32 commitment = keccak256(abi.encodePacked(lessee, usageCount));
        bytes32 proofHash = keccak256(abi.encodePacked(tokenId, expiry, commitment));

        require(!verifiedProofs[proofHash], "Proof already verified");
        require(_verifyProof(zp, commitment), "Invalid proof");

        verifiedProofs[proofHash] = true;
        emit ProofVerified(tokenId, lessee, expiry);
        emit LeaseActivated(tokenId, lessee);
        return true;
    }

    function parseProof(bytes calldata proof) internal pure returns (LeaseProof memory) {
        require(proof.length == 192, "Invalid proof length");
        LeaseProof memory zp;
        zp.a[0] = bytesToUint(proof[0:32]);
        zp.a[1] = bytesToUint(proof[32:64]);
        zp.b[0][0] = bytesToUint(proof[64:96]);
        zp.b[0][1] = bytesToUint(proof[96:128]);
        zp.b[1][0] = bytesToUint(proof[128:160]);
        zp.b[1][1] = bytesToUint(proof[160:192]);
        zp.c[0] = bytesToUint(proof[192:224]);
        zp.c[1] = bytesToUint(proof[224:256]);
        return zp;
    }

    function _verifyProof(LeaseProof memory zp, bytes32 commitment) internal view returns (bool) {
        uint256[4] memory pairing = [
            _pairing(zp.a[0], zp.b[0][0], zp.c[0], commitment),
            _pairing(zp.a[1], zp.b[1][0], zp.c[1], 0)
        ];
        return _checkPairing(pairing);
    }

    function _pairing(uint256 a1, uint256 a2, uint256 b1, uint256 b2) internal pure returns (uint256) {
        bytes memory input = abi.encodePacked(a1, a2, b1, b2);
        (bool success, bytes memory result) = address(6).staticcall(input);
        require(success, "Pairing failed");
        return abi.decode(result, (uint256));
    }

    function _checkPairing(uint256[4] memory pairing) internal pure returns (bool) {
        bytes memory input = abi.encodePacked(pairing[0], pairing[1], pairing[2], pairing[3]);
        (bool success, bytes memory result) = address(8).staticcall(input);
        require(success, "Pairing check failed");
        return abi.decode(result, (bool));
    }

    function bytesToUint(bytes memory b) internal pure returns (uint256) {
        uint256 result;
        for (uint256 i = 0; i < b.length; i++) {
            result = result * 256 + uint8(b[i]);
        }
        return result;
    }

    function getVerifiedProofsCount() external view returns (uint256) {
        uint256 count;
        for (uint256 i = 0; i < verifiedProofs.length; i++) {
            if (verifiedProofs[i]) count++;
        }
        return count;
    }
}