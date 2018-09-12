pragma solidity ^0.4.24;

contract BoxingMatch{
    
    address public boxer1;
    address public boxer2;
    
    bool public boxer1Fought;
    bool public boxer2Fought;
    
    uint public boxer1Deposit;
    uint public boxer2Deposit;
    
    bool public matchCompleted;
    address public winningBoxer;
    uint public earnings;
    uint public boxingRounds = 0;
    
    event MatchStart(address boxer1, address boxer2);
    event EndOfMatch(address winner, uint earnings);
    event EndOfRound(uint boxer1Deposit, uint boxer2Deposit);
    
    constructor() public {
        boxer1 = msg.sender;
    }
    
    function registerAsOpponent(address boxer2Input) public {
        require(boxer2Input != address(0));
        boxer2 = boxer2Input;
        
        emit MatchStart(boxer1, boxer2);
    }
    
    function startBox() public payable{
        require (!matchCompleted && (msg.sender == boxer1 || msg.sender == boxer2), "fight's over boys");
        if (msg.sender == boxer1){
            boxer1Fought = true;
            boxer1Deposit = boxer1Deposit + msg.value; 
        } else if (msg.sender == boxer2) {
            boxer2Fought = true;
            boxer2Deposit = boxer2Deposit + msg.value;
        }
        
        //makes sure both have at least thrown a punch
        if (boxer2Fought && boxer1Fought) {
            if(boxer1Deposit >= boxer2Deposit * 2){
                matchCompleted = true;
                winningBoxer = boxer1;
                eventEndOfMatch();
            }
            else if (boxer2Deposit >= boxer1Deposit * 2){
                matchCompleted = true;
                winningBoxer = boxer2;
                eventEndOfMatch();
            }
            //if no winners after 10 rounds, it will be sudden death!
            else if (boxingRounds > 10) {
                if(boxer1Deposit > boxer2Deposit){
                    matchCompleted = true;
                    winningBoxer = boxer1;
                    eventEndOfMatch();
                }
                else if (boxer2Deposit > boxer1Deposit){
                    matchCompleted = true;
                    winningBoxer = boxer2;
                    eventEndOfMatch();
                }
            }
        }

        eventEndOfRound();
    }
    
    function eventEndOfRound() public {
        //boxer2Fought = false;
        //boxer1Fought = false;
        
        boxingRounds++;
        emit EndOfRound(boxer1Deposit, boxer2Deposit);
    }
    
    function eventEndOfMatch() public {
        matchCompleted = true;
        
        earnings = boxer2Deposit + boxer1Deposit;
        emit EndOfMatch(winningBoxer, earnings);
    }
    
    function withDraw() public payable {
        require(matchCompleted && winningBoxer == msg.sender);
        uint amount = earnings;
        
        earnings = 0;
        //make sure you have at least 2300 gwei since we are using transfer
        msg.sender.transfer(amount);
    }
}