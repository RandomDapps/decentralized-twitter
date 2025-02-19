import { ethers } from "hardhat";

async function main() {
    const TweetRegistry = await ethers.deployContract("TweetRegistry");
    console.log("Deploying TweetRegistry...");
    await TweetRegistry.waitForDeployment();
    const contractAddress = await TweetRegistry.getAddress();
    console.log(`TweetRegistry deployed at: ${contractAddress}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
