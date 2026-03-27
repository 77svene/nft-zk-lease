// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LeaseNFT is ERC721, Ownable {
    struct Lease {
        address lessee;
        uint256 expiry;
        uint32 usageCount;
        bool active;
    }

    mapping(uint256 => Lease) public leases;
    mapping(uint256 => uint256) public totalUsage;
    address public verifier;

    event LeaseGranted(uint256 indexed tokenId, address indexed lessee, uint256 expiry);
    event LeaseExpired(uint256 indexed tokenId, address indexed lessee);
    event LeaseTerminated(uint256 indexed tokenId, address indexed lessee);
    event UsageRecorded(uint256 indexed tokenId, uint32 count);

    constructor(address _verifier) ERC721("LeaseNFT", "LNFT") Ownable(msg.sender) {
        require(_verifier != address(0), "Invalid verifier");
        verifier = _verifier;
    }

    function mint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    function grantLease(uint256 tokenId, address lessee, uint256 expiry) public {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        require(lessee != address(0), "Invalid lessee");
        require(expiry > block.timestamp, "Expiry in past");
        require(!leases[tokenId].active, "Lease active");

        leases[tokenId] = Lease({
            lessee: lessee,
            expiry: expiry,
            usageCount: 0,
            active: true
        });

        emit LeaseGranted(tokenId, lessee, expiry);
    }

    function terminateLease(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        require(leases[tokenId].active, "No active lease");

        address lessee = leases[tokenId].lessee;
        leases[tokenId].active = false;

        emit LeaseTerminated(tokenId, lessee);
    }

    function recordUsage(uint256 tokenId, uint32 count) public {
        require(leases[tokenId].active, "No active lease");
        require(msg.sender == leases[tokenId].lessee, "Not lessee");
        require(block.timestamp <= leases[tokenId].expiry, "Lease expired");

        leases[tokenId].usageCount += count;
        totalUsage[tokenId] += count;

        emit UsageRecorded(tokenId, count);
    }

    function getLease(uint256 tokenId) public view returns (Lease memory) {
        return leases[tokenId];
    }

    function isLeaseActive(uint256 tokenId) public view returns (bool) {
        return leases[tokenId].active && block.timestamp <= leases[tokenId].expiry;
    }
}