pragma solidity >=0.5.0 <0.6.0;
pragma experimental ABIEncoderV2;
contract BlindAuction{

    
    event OwnerSet(address oldOwner, address newOwner);
    event WinnerSet (address winner, uint value);
    //delete it
    event hashSet(bytes32 theHash);

    
    // the auctionManager is the owner
    address public auctionManager;
    uint deposit = 100 wei;
    bool isAuctionEnded = false;
    address private owner;
     
    mapping(address => bytes32) public biddings;
    mapping(address => uint) public validBiddings;
    mapping(address => bool) public refunds;


    uint highestBid;
    uint secondHighestBid;
    address highestBidder;

    constructor(uint _biddingTime, uint _revealingTime) public{
        auctionManager = msg.sender;  
        owner = msg.sender; 
        
    }

    function sealBid(uint _value, uint _nonce)private returns (bytes32){
        return keccak256(abi.encode(_value, _nonce));
    }
    
    
    function bid(uint _value, uint _nonce) public payable{
        // Participant pays bid once
        require(refunds[msg.sender] == false );
        require(msg.value == deposit,'deposit shall be equal to the inital deposit');
        bytes32 sealedBid = sealBid(_value, _nonce);
        biddings[msg.sender] = sealedBid;
        refunds[msg.sender] = true;
    
    }
    
    function reveal(uint _value, uint _nonce) public{
        // checks for the validity of bids
        //require(biddings[msg.sender] == sealBid( _value, _nonce));
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
    
    function finalizeAuction()public{
        isAuctionEnded = true;
        // delete it from the map he won't get the deposit back
        delete validBiddings[highestBidder];
        emit WinnerSet(highestBidder, secondHighestBid);
        
    }
   
   function withdraw() public{
       // check if he is not a cheater nor a winner
       require(validBiddings[msg.sender]!=  uint(0x0));
       msg.sender.transfer(deposit);
   }
   
   function claim() public payable{
       //set the winner as the song owner
       // winner has the write to transfer ownership to anyone
       require(msg.value == secondHighestBid);
       require(msg.sender == highestBidder);
       owner = highestBidder;
       emit OwnerSet(auctionManager, highestBidder);
             
   }
   

}