// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

//blockchian are deterministics (they can not interact with the world outsite, if differente nodes give different data, they would never get consensos. p.e ETH value; RandomNUmbers; etc)
//oracles -> connenct blockchain to outside world, to get the information

import {AggregatorV3Interface} from
    "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    //LIBRARY PriceConverter
    using PriceConverter for uint256;

    //////////////////
    // ERRORS       //
    //////////////////
    error FundMe__NotENough();
    error FundMe__TransferFailed();
    error FundMe__NotOwner();

    //////////////////
    // VARIABLES    //
    //////////////////
    uint256 public constant MINIMUM_USD = 5e18; //because getConversionRate returns 1e18
    //keep track of the funders
    address[] private s_funders;
    mapping(address funder => uint256 amountFounded) private s_addressToAmountFunded;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    //////////////////
    // MODIFIERS    //
    //////////////////
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    //////////////////
    // CONSTRUCTOR  //
    //////////////////
    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    //////////////////
    // FUNCTIONS    //
    //////////////////
    function fund() public payable {
        //require(msg.value > 1) it will reset the number to 1 if the revert happens
        if (msg.value.getConversationRate(s_priceFeed) < MINIMUM_USD) {
            revert FundMe__NotENough();
        }
        //keep track of the funders
        s_funders.push(msg.sender);

        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            //zero element -> funders[fundersIndex], which is an address
            address funder = s_funders[funderIndex];
            //reset mapping
            s_addressToAmountFunded[funder] = 0;
        }
        //reset funders with zero elememts;
        s_funders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function cheaperWithdraw() public onlyOwner {
        //now we are reading from memory instead of storage
        uint256 fundersLength = s_funders.length;

        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            //zero element -> funders[fundersIndex], which is an address
            address funder = s_funders[funderIndex];
            //reset mapping
            s_addressToAmountFunded[funder] = 0;
        }
        //reset funders with zero elememts;
        s_funders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    //////////////////////////
    // VIEW/PURE FUNCTIONS  //
    //////////////////////////
    function getFunders(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getAdressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
