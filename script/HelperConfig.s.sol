// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkingConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkingConfig {
        address priceFeed; // ETH/USD price address
    }

    constructor() {
        if (block.chainid == 11155111) {
            //checking if we on sepolia chain
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig()
        public
        pure
        returns (NetworkingConfig memory)
    {
        //price feed address
        NetworkingConfig memory sepoliaConfig = NetworkingConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig()
        public
        pure
        returns (NetworkingConfig memory)
    {
        //price feed address
        NetworkingConfig memory ethConfig = NetworkingConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig()
        public
        returns (NetworkingConfig memory)
    {
        // 1. Deploy the mocks (fake contract)
        // 2. Return the mock address
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        NetworkingConfig memory anvilConfig = NetworkingConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}

// 1. Deploy Mocks when we are on a local anvil chain
// 2. Keep track of contract address across different chains
// Sepolia ETH/USD
// Mainnet ETH/USD
