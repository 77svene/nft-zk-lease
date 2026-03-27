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

    event LeaseGranted(uint256 indexed tokenId, address indexed lessee, uint256 expiry);
    event LeaseExpired(uint256 indexed tokenId, address indexed lessee);
    event LeaseTerminated(uint256 indexed tokenId, address indexed lessee);
    event UsageRecorded(uint256 indexed tokenId, uint32 count);

    constructor() ERC721("LeaseNFT", "LNFT") Ownable(msg.sender) {}

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

    function recordUsage(uint256 tokenId) public {
        require(leases[tokenId].active, "No active lease");
        require(msg.sender == leases[tokenId].lessee, "Not lessee");
        require(block.timestamp <= leases[tokenId].expiry, "Lease expired");

        uint32 currentCount = leases[tokenId].usageCount;
        leases[tokenId].usageCount = currentCount + 1;
        totalUsage[tokenId] = totalUsage[tokenId] + 1;

        emit UsageRecorded(tokenId, currentCount + 1);
    }

    function isLeaseActive(uint256 tokenId) public view returns (bool) {
        Lease storage lease = leases[tokenId];
        return lease.active && block.timestamp <= lease.expiry;
    }

    function getLeaseInfo(uint256 tokenId) public view returns (Lease memory) {
        return leases[tokenId];
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(!isLeaseActive(tokenId), "Cannot transfer active lease");
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        require(!isLeaseActive(tokenId), "Cannot transfer active lease");
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) public override {
        require(!isLeaseActive(tokenId), "Cannot transfer active lease");
        super.safeTransferFrom(from, to, tokenId, data);
    }
}