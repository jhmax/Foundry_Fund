// // SPDX-License-Identifier: MIT

// pragma solidity ^0.8.19;

// import {Script, console} from "../lib/forge-std/src/Script.sol";
// import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
// import {FundMe} from "../src/FundMe.sol";

// contract FundFundMe is Script {
//     uint256 constant SEND_VALUE = 0.01 ether;

//     function fundFundMe(address mostRecentDeploy) public {
//         FundMe(payable(mostRecentDeploy)).fund{value: SEND_VALUE}();
//         console.log("funded FundMe with %s", SEND_VALUE);
//     }

//     function run() external {
//         //run tbe lattest deployed
//         address mostRecentDeploy = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

//         vm.startBroadcast();
//         fundFundMe(mostRecentDeploy);
//         vm.stopBroadcast();
//     }
// }

// contract WIthdrawFundMe is Script {
//     function withdrayFundMe(address mostRecentDeploy) public {
//         FundMe(payable(mostRecentDeploy)).withdraw();
//         console.log("funded FundMe with %s");
//     }

//     function run() external {
//         //run tbe lattest deployed
//         address mostRecentDeploy = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

//         vm.startBroadcast();
//         withdrayFundMe(mostRecentDeploy);
//         vm.stopBroadcast();
//     }
// }
