/*
    Copyright 2020 Freq Set Dollar <freqsetdollar@gmail.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Market.sol";
import "./Regulator.sol";
import "./Bonding.sol";
import "./Govern.sol";
import "../oracle/Oracle.sol";
import "../Constants.sol";

contract Implementation is State, Bonding, Market, Regulator, Govern {
    using SafeMath for uint256;

    event Advance(uint256 indexed epoch, uint256 block, uint256 timestamp, string res);
    event Incentivization(address indexed account, uint256 amount);
    
    function initialize() initializer public {
         _state.provider.oracle = IOracle(0xF841bC7E3e43774Db8dE9d32dBBeF933613Ab2F6);   
    }

    function advance() external incentivized {
        Bonding.step();
        Regulator.step();
        Market.step();
        emit Advance(epoch(), block.number, block.timestamp, "market done");
    }

    modifier incentivized {
        // Mint advance reward to sender
        uint256 incentive = Constants.getAdvanceIncentive();
        mintToAccount(msg.sender, incentive);
        emit Incentivization(msg.sender, incentive);
        _;
    }
}
