// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

interface IFriendlyBetCallback {
    // Callback for oracle weather data
    function onReceiveTemperature(uint256 temperature) external;
}