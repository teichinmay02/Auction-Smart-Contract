// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Auction {
    address payable public auctioneer;
    address payable public highestBidder;
    uint256 public highestBidInEther; // Highest bid in Ether
    uint256 public reservePriceInEther; // Reserve price in Ether
    uint256 public auctionEndTime;
    uint256 public minimumBidIncrementInEther; // Minimum increment for bids in Ether
    bool public ended;
    
    event HighestBidIncreased(address bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);
    
    constructor(
        uint256 biddingTime,
        uint256 minimumPriceInEther,
        uint256 minBidIncrementInEther
    )  {
        auctioneer = payable(msg.sender);
        auctionEndTime = block.timestamp + biddingTime;
        reservePriceInEther = minimumPriceInEther;
        minimumBidIncrementInEther = minBidIncrementInEther;
    }
    
    function bid() public payable {
        require(block.timestamp <= auctionEndTime, "Auction has ended");
        uint256 newBidInEther = msg.value / 1 ether; // Convert Wei to Ether
        
        // Ensure bid meets minimum increment over highest bid
        if (highestBidInEther != 0) {
            require(newBidInEther >= highestBidInEther + minimumBidIncrementInEther, "Bid must be at least minimum increment higher");
        } else {
            // First bid must be at least reserve price
            require(newBidInEther >= reservePriceInEther, "Bid must be at least reserve price");
        }
        
        if (highestBidInEther != 0) {
            highestBidder.transfer(highestBidInEther * 1 ether); // Convert Ether to Wei for transfer
        }
        
        highestBidder = payable(msg.sender);
        highestBidInEther = newBidInEther;
        emit HighestBidIncreased(msg.sender, newBidInEther);
    }
    
    function endAuction() public {
        require(msg.sender == auctioneer, "Only auctioneer can end the auction");
        // require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(!ended, "Auction already ended");
        
        ended = true;
        
        if (highestBidInEther < reservePriceInEther) {
            // Auction failed to meet reserve, handle refunds (implement logic)
        } else {
            emit AuctionEnded(highestBidder, highestBidInEther);
            auctioneer.transfer(address(this).balance);
        }
    }
}
