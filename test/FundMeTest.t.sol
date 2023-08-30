// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
// import {PriceConverter} from "../src/PriceConverter.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant SEND_VALUE = 0.1 ether;
    address USER = makeAddr("user");
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        //once we update DeployFundMe we are updating at the same time FundMeTest
        DeployFundMe deployFundMe = new DeployFundMe();
        //run() returns a fundMe
        fundMe = deployFundMe.run();

        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedIsAcurate() public {
        uint256 price = fundMe.getVersion();
        console.log(price);
        assertEq(price, 4);

        //we must simulate the SEPOLIA_URL because the default test chain will be anvil
        //forge test --match-test testPriceFeedIsAcurate -vvvv --fork-url $SEPOLIA_RPC_URL
    }

    function testFundFailsWithouthenoughEth() public {
        vm.expectRevert();
        //no cast/value
        fundMe.fund();
    }

    function testUpdateDataSctruture() public {
        //fake user
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAdressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFundsToArrayOfFunders() public {
        //fake user
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        //address(0), generate a new address, address(1), address(2)..(more addresses)
        address funder = fundMe.getFunders(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testModifierOnlyOwnerInWithdraw() public funded {
        vm.prank(USER); //user its not owner, next line expectRevert because ignore the vm
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        //check balance before wwithdraw
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        //check the balance of the fundMe contract
        uint256 startingFundMeBalance = address(fundMe).balance; //funded balance

        //withdraw (onlyOwner)
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //after the withdraw, owner shouuld have 0 balance
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public {
        //uint160 has the same bytes as an address
        // uint160 numberOfFunders = 10;
        // uint160 startingIndexFunders = 1;
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            //several funds
            //hoax -> set prank address wtih ether

            //send value to the address (starts at position 1(i)) until position 10
            hoax(address(i), STARTING_USER_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //calculate the gas price
        uint256 gasStart = gasleft(); //1000

        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 gasEnd = gasleft(); //800
        //1000 - 800 = 200 gasUsed; tx.gasprice is the the current gas price
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

    function testWithdrawFromMultipleFundersCheaper() public {
        //uint160 has the same bytes as an address
        // uint160 numberOfFunders = 10;
        // uint160 startingIndexFunders = 1;
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            //several funds
            //hoax -> set prank address wtih ether

            //send value to the address (starts at position 1(i)) until position 10
            hoax(address(i), STARTING_USER_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //calculate the gas price
        uint256 gasStart = gasleft(); //1000

        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        uint256 gasEnd = gasleft(); //800
        //1000 - 800 = 200 gasUsed; tx.gasprice is the the current gas price
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }
}
