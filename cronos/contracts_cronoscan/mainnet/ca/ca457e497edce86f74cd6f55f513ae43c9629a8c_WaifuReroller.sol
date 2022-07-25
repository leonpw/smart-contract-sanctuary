/**
 *Submitted for verification at cronoscan.com on 2022-06-08
*/

// Keep Personality, reroll into Legendary

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None
pragma solidity 0.8.14;
interface IShoujoStats {struct Shoujo {uint16 nameIndex;uint16 surnameIndex;uint8 rarity;uint8 personality;uint8 cuteness;uint8 lewd;uint8 intelligence;uint8 aggressiveness;uint8 talkative;uint8 depression;uint8 genki;uint8 raburabu; uint8 boyish;}function tokenStatsByIndex(uint256 index) external view returns (Shoujo memory);function reroll(uint256 waifu, bool lock, bool rarity) external;}
interface HibikiInterface {function approveMax(address spender) external returns (bool);function transfer(address recipient, uint256 amount) external returns (bool);function balanceOf(address account) external returns (uint256);}
interface WaifuInterface{function safeTransferFrom(address from, address to, uint256 tokenId) external; function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);function balanceOf(address account) external returns (uint256);function transferFrom(address from, address to, uint256 tokenId) external;}
interface WaifusOwnerInterface{function getAllIdsOwnedBy(address owner) external view returns(uint256[] memory);}
contract WaifuReroller {
    HibikiInterface public hibiki = HibikiInterface(0x6B66fCB66Dba37F99876a15303b759c73fc54ed0);
    WaifuInterface public waifu = WaifuInterface(0x632e9915a9BEe6cD8bd9ad1fBDf5396048d4De56);
    address _shoujoStats = 0x7c4f9A98B295160B7cc9775aF6d15fCEd071366C;
    IShoujoStats ss = IShoujoStats(_shoujoStats);
    address owner;
    uint256 waifuID;
    bool areWeDone = false;
    modifier onlyOwner() {if(msg.sender != owner) return; _;}
    constructor() {hibiki.approveMax(0x7c4f9A98B295160B7cc9775aF6d15fCEd071366C);owner = msg.sender;}
    function sendHibikiBack() external onlyOwner{hibiki.transfer(owner, hibiki.balanceOf(address(this)));}
    function sendWaifuBAck(uint256 waifuIDsend) external onlyOwner{waifu.safeTransferFrom(address(this), owner, waifuIDsend);}
    function sendWaifusToThisContract(uint256 waifuToSendID) external onlyOwner{waifu.transferFrom(msg.sender, address(this), waifuToSendID); areWeDone=false;}
    function reroll() external onlyOwner{
        if(areWeDone) return;
        waifuID = waifu.tokenOfOwnerByIndex(address(this),0);
        IShoujoStats(_shoujoStats).reroll(waifuID,false,true);
        IShoujoStats.Shoujo memory waifuToCheck = ss.tokenStatsByIndex(waifuID);
        bool isLegend;
        if(waifuToCheck.rarity == 4) isLegend = true;
        string memory rarity = uint2str(waifuToCheck.rarity);
        require(isLegend, rarity);
        waifu.safeTransferFrom(address(this), owner, waifuID);
        areWeDone = waifu.balanceOf(address(this)) == 0;
        if(!areWeDone) waifuID = waifu.tokenOfOwnerByIndex(address(this),0);
    }
    function uint2str(uint256 _i) internal pure returns (string memory str)
    {
      if (_i == 0) return "0";
      uint256 j = _i;
      uint256 length;
      while (j != 0)
      {
        length++;
        j /= 10;
      }
      bytes memory bstr = new bytes(length);
      uint256 k = length;
      j = _i;
      while (j != 0)
      {
        bstr[--k] = bytes1(uint8(48 + j % 10));
        j /= 10;
      }
      str = string(bstr);
    }
}