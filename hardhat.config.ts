import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: {
        enabled: true,
        runs: 50, // Adjust the runs value if needed (e.g., 50 for smaller contract size)
      },
    },
  },
};

export default config;
