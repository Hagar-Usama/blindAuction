# Blind Auction 💸
![Block-Chains][1] ![Ethereum-Solidity][2]  ![Blind-Auctions][4] ![Covid-19][3]

[1]: https://img.shields.io/:Block-Chains-whiteGreen.svg?style=round-square
[2]: https://img.shields.io/:Ethereum-Solidity-yellow.svg?style=round-square
[3]: https://img.shields.io/:Covid-19-red.svg?style=round-square
[4]: https://img.shields.io/:Blind-Auctions-blue.svg?style=round-square


---

|   Name       |    Id |
|--------------|-------|
|Hagar usama   | 4970  |


---

## Assumptions

* The Owner is the auction manager, no middlemen
* The manager has limited permissions
    - cannot bid
    - cannot put a deposit
    - cannot withdraw
    - cheaters and winner deposits' are trapped, no one has access to them to avoid any type of manupilation, `lose-lose situation`
* Bidders can bid once, cannot change their bids



---


## Code 

``` solidity

pragma solidity >=0.5.0 <0.6.0;

contract BlindAuction{

    
    event OwnerSet(address oldOwner, address newOwner);
    event WinnerSet (address winner, uint value);
    
    // the auctionManager is the seller
    address public auctionManager;
    uint deposit = 500 wei;
    // the owner is initially the auctionManager
    address public owner;
    bool isAuctionEnded = false;

     
    mapping(address => bytes32) public biddings;
    mapping(address => uint) public validBiddings;
    mapping(address => bool) public refunds;


    uint highestBid;
    uint secondHighestBid;
    address highestBidder;
    uint biddingTime;
    uint revealingTime;
    uint private song;
    
    modifier duringBidding() {
    require(now <= biddingTime, 'It is not Bidding Time');
    _;
  }
  
   modifier duringRevealing() {
    require(now > biddingTime && now <= revealingTime, 'It is not Revealing Time');
    _;
  }
  
   modifier afterRevealing() {
    require(now > revealingTime, 'Auction has not been ended yet');
    _;
  }
    constructor(uint _biddingTime, uint _revealingTime, uint _song) public{
        auctionManager = msg.sender; 
        // auctionManager is the owner, no middlemen
        owner = msg.sender; 
        biddingTime = now + _biddingTime;
        revealingTime = biddingTime + _revealingTime;
        song = _song;
        
    }

    function sealBid(uint _value, uint _nonce) private pure returns (bytes32){
        return keccak256(abi.encode(_value, _nonce));
    }
    
    
    function bid(uint _value, uint _nonce) public payable duringBidding{
        // Participant pays bid once
        require(refunds[msg.sender] == false, 'Already participated' );
        require(msg.value == deposit,'Please make sure you pay the deposit');
        require(msg.sender != auctionManager, 'Auction Manager has no rights to bid');
        bytes32 sealedBid = sealBid(_value, _nonce);
        biddings[msg.sender] = sealedBid;
        refunds[msg.sender] = true;
    
    }
    
    function reveal(uint _value, uint _nonce) public duringRevealing{
        // checks for the validity of bids
        // on reveal, each pariticapant will not pay, just reveal the values
        if (biddings[msg.sender] == sealBid(_value, _nonce)){
            if (_value > highestBid){
            secondHighestBid = highestBid;
            highestBid = _value;
            highestBidder = msg.sender;
        }
        
        validBiddings[msg.sender] = _value;

        }

    }
    
    function finalizeAuction() public afterRevealing{
        // auction ends just one time
        require(isAuctionEnded == false);
        isAuctionEnded = true;
        // delete the winner from the map he won't get the deposit back
        delete validBiddings[highestBidder];
        emit WinnerSet(highestBidder, secondHighestBid);
        
    }
   
   function withdraw() public afterRevealing{
       // check if he is not a cheater nor a winner
       require(validBiddings[msg.sender]!= uint(0x0));
       require(msg.sender != auctionManager);
       //check if already refunded
       require(!refunds[msg.sender]);
       msg.sender.transfer(deposit);
       refunds[msg.sender] = true;
   }
   
   function claim() public payable afterRevealing returns (uint){
       //set the winner as the song owner
       // winner has the write to transfer ownership to himself
       require(msg.value == secondHighestBid);
       require(msg.sender == highestBidder);
       owner = highestBidder;
       emit OwnerSet(auctionManager, highestBidder);
       return song;
             
   }
   

}

```



## Bonus Part
I assumed the song is a unit datatype, so the owner (manager) delivers it to the contract, at the deployment phase

The `song` is `private`, no one has access for it

After the auction is ended, the winner can claim the song iff (s)he pays the value of the `secondHighestBid` (the `song` is return to him)

### problems
* It is digital, the owner may has his own copy
* The winner cannot make sure the returned song is the right one til (s)he pays

### side notes
* Zero-Knowledge Proof may be a valid solution




---

## References

* [Verifiable Sealed-Bid Auction on the Ethereum
Blockchain][16]
* [cryptozombies.io, first 4 chapters][10]
* [Check if item exits in Solidity Mapping structure][11]
* [Get public key of msg.sender in a smart contract][12]
* [payable() function In solidity][13]
* [How use payable function with browser solidity?][14]
* [Solidity transfer function not work][15]





[10]: https://cryptozombies.io
[11]: https://ethereum.stackexchange.com/questions/46687/check-if-item-exits-in-solidity-mapping-structure/46688
[12]: https://ethereum.stackexchange.com/questions/15149/get-public-key-of-msg-sender-in-a-smart-contract
[13]: https://ethereum.stackexchange.com/questions/20874/payable-function-in-solidity
[14]: https://ethereum.stackexchange.com/questions/19546/how-use-payable-function-with-browser-solidity
[15]: https://ethereum.stackexchange.com/questions/55688/solidity-transfer-function-not-work
[16]: https://eprint.iacr.org/2018/704.pdf
