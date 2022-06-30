//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable{
    string _baseTokenURI;

    IWhitelist whitelist;

    uint256 public tokenIds;
    uint256 public maxTokenIds=20;
    uint256 public _price = 0.01 ether;

    bool public preSaleStarted;
    uint256 public preSaleEnded;

    bool public _paused;

    modifier onlyWhenNotPaused {
        require(!_paused, "Contract currently paused");
        _;
    }
    

    constructor(string memory baseURI, address whitelistContract) ERC721("Crypto Devs", "CD"){
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    function startPreSale() public onlyOwner {
        preSaleStarted = true;
        preSaleEnded = block.timestamp + 5 minutes;
    }

    function preSaleMint() public payable onlyWhenNotPaused{
        require(preSaleStarted && block.timestamp < preSaleEnded, "Presale Ended");
        require(whitelist.whitelistedAddresses(msg.sender),"You are not in whitelist");
        require(tokenIds < maxTokenIds, "Exceeded the limit");
        require(msg.value >= _price,"Insufficient Funds");

        tokenIds += 1;
        _safeMint(msg.sender,tokenIds);
    }

    function mint() public payable onlyWhenNotPaused{
        require(preSaleStarted && block.timestamp > preSaleEnded, "Presale not ended yet");
        require(tokenIds < maxTokenIds, "Exceeded the limit");
        require(msg.value >= _price,"Insufficient Funds");

        tokenIds += 1;
        _safeMint(msg.sender,tokenIds);
    }

    function _baseURI() internal view override returns (string memory){
        return _baseTokenURI;
    }

    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 _amount = address(this).balance;
        (bool sent,) = _owner.call{value : _amount}("");
        require(sent,"Failed to send ether");
    }

    receive() external payable{}
    fallback() external payable{}

}