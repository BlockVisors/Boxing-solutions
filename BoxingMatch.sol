pragma solidity ^0.4.24;

contract BoxingMatch {
    /**
    * Our boxers
    */
	address public boxer1;
	address public boxer2;

	bool public boxer1Fought;
	bool public boxer2Fought;

	uint public boxer1Deposit;
	uint public boxer2Deposit;

	bool public matchFinished;
    address public theWinner;
    uint public gains;

    /**
    * The logs that will be emitted in every step of the contract's life cycle
    */
	event MatchStartsEvent(address boxer1, address boxer2);
	event EndOfRoundEvent(uint boxer1Deposit, uint boxer2Deposit);
	event EndOfMatch(address winner, uint gains);

    /**
    * The contract constructor
    */
	constructor(uint256 _deposit1) public payable {
		boxer1 = msg.sender;
		boxer1Deposit = _deposit1;
	}

    /**
    * A second wrestler can register as an opponent
    */
	function registerAsAnOpponent(uint256 _deposit2) public payable {
        require(boxer2 == address(0));
        boxer2Deposit = _deposit2;
        boxer2 = msg.sender;
        emit MatchStartsEvent(boxer1, boxer2);
    }


    /**
    * Every round a player can put a sum of ether, if one of the player put in twice or
    * more the money (in total) than the other did, the first wins
    */
    function box() public payable {
    	require(!matchFinished && boxer2 != address(0));
        
    	if(msg.sender == boxer1 && boxer1Fought == false) {
    		boxer1Fought = true;
    		boxer1Deposit = boxer1Deposit + msg.value;
    	}
    	
    	if(msg.sender == boxer2 && boxer2Fought == false) {
    		boxer2Fought = true;
    		boxer2Deposit = boxer2Deposit + msg.value;
    	}
    	
    	if(boxer1Fought && boxer2Fought) {
    		if(boxer1Deposit >= boxer2Deposit * 2) {
    		  //  theWinner = boxer1;
    			endOfGame(boxer1);
    		} else if (boxer2Deposit >= boxer1Deposit * 2) {
    		  //  theWinner = boxer2;
    			endOfGame(boxer2);
    		} else {
                endOfRound();
    		}
    	}
    	
    }

    function endOfRound() internal {
    	boxer1Fought = false;
    	boxer2Fought = false;

    	emit EndOfRoundEvent(boxer1Deposit, boxer2Deposit);
    }

    function endOfGame(address winner) internal {
        matchFinished = true;
        theWinner = winner;

        gains = boxer1Deposit + boxer2Deposit;
        emit EndOfMatch(winner, gains);
    }

    /**
    * The withdraw function, following the withdraw pattern shown and explained here:
    * http://solidity.readthedocs.io/en/develop/common-patterns.html#withdrawal-from-contracts
    */
    function withdraw() public {
        require(matchFinished && theWinner == msg.sender);

        uint amount = gains;
        gains = 0;
        msg.sender.transfer(amount);
    }
}