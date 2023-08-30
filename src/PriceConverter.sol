// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {AggregatorV3Interface} from
    "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // Sepolia ETH / USD Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        //ABI (functions needed)

        (, int256 price,,,) = priceFeed.latestRoundData();
        //return ETH/USD -> 1667,05477344 (1e8), but to match msg.value of the fund, which is 1e18
        return uint256(price * 1e10); //1667054773440000000000
    }

    function getConversationRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        //Conversiont = ethPrice (2) * ethAmount (3)
        // 2000_000000000000000000 * 3000_0000000000000000000 = 600000000000000000000000000000000000000 (36 0´s)
        // sow to reduce to 18 zeros, we need to / 1e18 = 6000_000000000000000000
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }
}
