const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  console.log("=== NFT-ZK Lease Deployment ===");
  console.log("Network: Sepolia");
  console.log("RPC: https://cloudflare-eth.com");
  console.log("");

  // Get deployer account
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  // Check balance
  const balance = await hre.ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", hre.ethers.formatEther(balance), "ETH");

  if (balance < hre.ethers.parseEther("0.01")) {
    throw new Error("Insufficient balance for deployment");
  }

  // Deploy LeaseVerifier first (LeaseNFT depends on it)
  console.log("\n--- Deploying LeaseVerifier ---");
  const LeaseVerifier = await hre.ethers.getContractFactory("LeaseVerifier");
  const verifier = await LeaseVerifier.deploy();
  await verifier.waitForDeployment();
  const verifierAddress = await verifier.getAddress();
  console.log("LeaseVerifier deployed at:", verifierAddress);

  // Deploy LeaseNFT with verifier address dependency
  console.log("\n--- Deploying LeaseNFT ---");
  const LeaseNFT = await hre.ethers.getContractFactory("LeaseNFT");
  const leaseNft = await LeaseNFT.deploy(verifierAddress);
  await leaseNft.waitForDeployment();
  const leaseNftAddress = await leaseNft.getAddress();
  console.log("LeaseNFT deployed at:", leaseNftAddress);

  // Save addresses to .env
  const envPath = path.join(process.cwd(), ".env");
  const envContent = `
LEASE_VERIFIER_ADDRESS=${verifierAddress}
LEASE_NFT_ADDRESS=${leaseNftAddress}
DEPLOYER_ADDRESS=${deployer.address}
DEPLOY_TIMESTAMP=${Math.floor(Date.now() / 1000)}
`;

  fs.writeFileSync(envPath, envContent.trim());
  console.log("\n--- Addresses saved to .env ---");

  // Verify contracts are deployed
  console.log("\n--- Verification ---");
  const deployedVerifier = await hre.ethers.getContractAt("LeaseVerifier", verifierAddress);
  const deployedNft = await hre.ethers.getContractAt("LeaseNFT", leaseNftAddress);

  console.log("Verifier owner:", await deployedVerifier.owner());
  console.log("NFT verifier:", await deployedNft.verifier());
  console.log("NFT name:", await deployedNft.name());
  console.log("NFT symbol:", await deployedNft.symbol());

  console.log("\n=== DEPLOYMENT COMPLETE ===");
  console.log("LeaseVerifier:", verifierAddress);
  console.log("LeaseNFT:", leaseNftAddress);
  console.log("Deployer:", deployer.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Deployment failed:", error);
    process.exit(1);
  });