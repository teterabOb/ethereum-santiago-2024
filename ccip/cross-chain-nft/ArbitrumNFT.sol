
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArbitrumNFT is ERC721, ERC721URIStorage, Ownable {    
    string constant TOKEN_URI = "ipfs://Qmd5Mwt2ZhCfcYbXMt8M7VDyLvsfebDjKoqfSCxpMYhTZc";    
    //https://ipfs.io/ipfs/QmT3nSKpJrEUWgeqGNiQPNEWcP2cousZNfQ72qX8qnBtWk?filename=mainnet-chainlink-elf.json
    uint256 private _nextTokenId;
    
    constructor()
        ERC721("Avalanche x Chainlink NFT", "ACN")
        Ownable(msg.sender)
    {}

    function safeMint(address to) public  {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, TOKEN_URI);
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}