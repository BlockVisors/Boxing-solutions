pragma solidity ^0.4.24;

contract BoxingMatch {
    
    address table;
    address public boxer1;
    address public boxer2;
    
    bool public boxer1Fought;
    bool public boxer2Fought;
    
    uint public boxer1Deposit;
    uint public boxer2Deposit;
    
    bool public matchCompleted;
    address public winningBoxer;
    uint public earnings;
    
    event MatchStart(address boxer1, address boxer2);
    event EndofMatch(address winner, uint earnings);
    event EndofRound(uint boxer1Deposit, uint boxer2Deposit);
    
    constructor() public payable {
        table = msg.sender;
    }
    
    function registerAsOpponent1(uint _boxer1Deposit) public {
        require(msg.sender != table && msg.sender != boxer2);
        
        boxer1 = msg.sender;
        boxer1Deposit = _boxer1Deposit;
    }
    
    function registerAsOpponent2(uint _boxer2Deposit) public {
        require(msg.sender != table && msg.sender != boxer1);
        
        boxer2 = msg.sender;
        boxer2Deposit = _boxer2Deposit;
    }
    
    function startBox() public payable {
        require (!matchCompleted && (msg.sender == boxer1 || msg.sender == boxer2));
        if (msg.sender == boxer1 && boxer1Fought == false){
            boxer1Fought = true;
            boxer1Deposit = boxer1Deposit + msg.value;
        } else if (msg.sender == boxer2 && boxer2Fought == false){
            boxer2Fought = true;
            boxer2Deposit = boxer2Deposit + msg.value;
        }
        
        if(boxer1Deposit >= boxer2Deposit * 2){
            matchCompleted = true;
            winningBoxer = boxer1;
            eventEndofMatch();
        } else if (boxer2Deposit >= boxer1Deposit * 2) {
            matchCompleted = true;
            winningBoxer = boxer2;
            eventEndofMatch();
        } else eventEndOfRound();
    }
    
    function eventEndOfRound() public {
        matchCompleted = false;
        emit EndofRound(boxer1Deposit, boxer2Deposit);
    }
    
    function eventEndofMatch() public {
        matchCompleted = true;
        
        earnings = boxer2Deposit + boxer1Deposit;
        emit EndofMatch(winningBoxer, earnings);
    }
    
    function withdraw() public payable {
        require(matchCompleted && winningBoxer == msg.sender);
        uint amount = earnings;
        
        //earnings = 0;
        msg.sender.transfer(amount);
    }
}