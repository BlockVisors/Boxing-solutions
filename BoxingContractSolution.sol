pragma solidity ^0.4.24;


contract BoxingMatch {

    // global var
    address public boxer1;
    address public boxer2;
    
    bool public boxer1Fought;
    bool public boxer2Fought;
    
    uint public boxer1Deposit;
    uint public boxer2Deposit;
    
    bool public matchCompleted;
    address public winningboxer;
    uint public earnings;
    
    event eventMatchStart(address boxer1, address boxer2);
    event eventEndOfMatch(address winner, uint earnings);
    event eventEndOfRound(uint boxer1Deposit, uint boxer2Deposit);
    event Hello(string message);
    constructor(address _boxer2) payable public{
        boxer1 = msg.sender;
        boxer2 = _boxer2;
    }
    
    function registerAsOpponent(address boxerInput) public {
        require(boxerInput != address(0));
        boxer2 = boxerInput;
    }
    
    function resetBox() public{
        matchCompleted = false;
        boxer1Fought = false;
        boxer2Fought = false;
        boxer1Deposit = boxer2Deposit = 0;
        emit Hello("reset!");
    }
    
    function startBox() public payable {
        require(msg.value > 0);
        require(!matchCompleted && (msg.sender == boxer1 || msg.sender == boxer2 ));
        uint msgValue = msg.value;
        
        if (msg.sender == boxer1 && boxer1Fought == false){
            emit Hello("Boxer1 Boxing!");
            boxer1Fought = true;
            boxer1Deposit = boxer1Deposit + msg.value;
        }
        else if (msg.sender == boxer2 && boxer2Fought == false) {
            emit Hello("Boxer2 Boxing!");
            boxer2Fought = true;
            boxer2Deposit = boxer2Deposit + msg.value;
        }
        
        if(boxer1Fought && boxer2Fought){
            emit Hello("Boxer Both Boxed!");
            if(boxer1Deposit >= boxer2Deposit * 2){
                emit Hello("Boxer1 win!");
                matchCompleted = true;
                winningboxer = boxer1;
            } else if(boxer2Deposit >= boxer1Deposit * 2){
                emit Hello("Boxer2 win!");
                matchCompleted = true;
                winningboxer = boxer2;
            }
        }
    }
    
    function boxOpponent(uint256 strength) public{
        if (msg.sender == boxer1) {
            boxer1Deposit += strength;
        } else if (msg.sender == boxer2) {
            boxer2Deposit += strength;
        }
    }
    
    
    function withdraw() public payable {
        require(matchCompleted && winningboxer == msg.sender);    
        uint amount = earnings;
        
        earnings = 0;
        msg.sender.transfer(amount);
    }
    
    // function eventMatchStart() public payable {
        
    // }
    function endOfMatch() public {
        matchCompleted = true;
        
        earnings = boxer2Deposit + boxer1Deposit;
        emit eventEndOfMatch(winningboxer, earnings);
        
    }
    
    
    
    function endOfRound() public {
        boxer2Fought = false;
        boxer1Fought = false;
        emit eventEndOfRound(boxer1Deposit, boxer2Deposit);
        
    }

}