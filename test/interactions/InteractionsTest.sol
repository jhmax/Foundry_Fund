// // SPDX-License-Identifier: MIT

// pragma solidity ^0.8.19;

// import {Test, console} from "../../lib/forge-std/src/Test.sol";
// import {FundMe} from "../../src/FundMe.sol";
// // import {PriceConverter} from "../src/PriceConverter.sol";
// import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
// import {FundFundMe} from "../../script/Interactions.s.sol";

// contract FundMeTestInteractions is Test {
//     FundMe fundMe;

//     uint256 public constant STARTING_USER_BALANCE = 10 ether;
//     uint256 public constant SEND_VALUE = 0.1 ether;
//     address USER = makeAddr("user");
//     uint256 constant GAS_PRICE = 1;

//     function setUp() external {
//         DeployFundMe deployFundMe = new DeployFundMe();

//         fundMe = deployFundMe.run();
//         vm.deal(USER, STARTING_USER_BALANCE);
//     }

//     function testUserCanFundInteractions() public {
//         //fetch th address in fundFunMe
//         FundFundMe fundFund = new FundFundMe();
//         vm.prank(USER);
//         vm.deal(USER, 1e18);
//         fundFund.fundFundMe(address(fundMe));

//         // generate a new address, address(1), address(2)..(more addresses)
//         address funder = fundMe.getFunders(0);
//         assertEq(funder, USER);
//     }
// }
