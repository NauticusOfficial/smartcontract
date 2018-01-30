pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// 'NAUT' Nauticus Token Fixed Contract
//
// Symbol      : NAUT
// Name        : NauticusToken
// Total supply: 22,000,000,000.000000000000000000
// Decimals    : 18
//
// (c) Nauticus
// ----------------------------------------------------------------------------
/**
 * The Permission contract provides basic access control.
 */
contract Permission {
    address public owner;
	function Permission() public {owner = msg.sender;}

	modifier onlyOwner() { 
		require(msg.sender == owner);
		_;
	}

	function changeOwner(address newOwner) onlyOwner public{
		require(newOwner != address(0));
		owner = newOwner;
	}
		
}	

/**
 * The Math helps maintain safe Math operations.
 */
library Math {

	function add(uint a, uint b) internal pure returns (uint c){
		c = a + b;
		require(c >= a);
		require(c >= b);
	}

	function sub(uint a, uint b) internal pure returns (uint c){
		require(b <= a);
		c = a - b;
	}

	function mul(uint a, uint b) internal pure returns (uint c){
		c = a * b;
		require(a == 0 || c / a == b);
	}

	function div(uint a, uint b) internal pure returns (uint c){
		require(b > 0);
		c = a / b;
	}
}


/**
 * The NauticusToken contract contains ERC20 compliant components, and holds the bulk of token logic.
 */
contract NauticusToken is Permission{
    using Math for uint;
    
    
    string public constant name = "NauticusTokenBeta";
	string public constant symbol = "NTSB";
	uint32 public constant decimals = 18;
    uint public totalSupply;
	address constant nauticus = 0x05E0D106647128F866a41B7847BEA739Eed80Ad3;
	bool private dCapActive = false;
	
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
    function approve(address spender, uint val) public returns (bool success) {
        allowed[msg.sender][spender] = val;
        Approval(msg.sender, spender, val);
        return true;
    }
    event Approval(address indexed owner, address indexed spender, uint indexed val);

    
    
    //start time in UNIX timestamp
    uint constant inception = 1509458400;
    uint constant duration = 120;
    
    //hardcap
    uint public hardCap = 18000000000.000000000000000000;
    
    bool public transferActive = true;

	
	
	
	modifier ICOActive() { 
		require(now > inception && now < inception  + (duration * 1 days)); 
		_; 
	}

	modifier transferble() { 
		//if you are NOT Nauticus
		if(msg.sender != owner){
			require(transferActive);
		}
		_;
	}
	

	function totalSupply() public constant returns (uint){
		//return the totalSupply, less the tokens in address(0).
		return totalSupply.sub(balances[address(0)]);
	}

	function transfer(address to, uint val) transferble public returns (bool){
		//only send to a valid address
		require(to != address(0));
		require(val <= balances[msg.sender]);

		//deduct the val from sender
		balances[msg.sender] = balances[msg.sender] - val;

		//give the val to the recipient
		balances[to] = balances[to] + val;

		//emit transfer event 
		Transfer(msg.sender,to,val);
		return true;
	}

	event Transfer(address sender, address recipient, uint val);

	function balanceOf(address client) public constant returns (uint balance){
		return balances[client];
	}

	function transferFrom(address from, address recipient, uint val) transferble public returns (bool){
		//to and from must be valid addresses
		require(recipient != address(0));
		require(from != address(0));
		//tokens must exist in from account
		require(balances[from] <= val);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(val);
		balances[from] = balances[from] - val;
		balances[recipient] = balances[recipient] + val;


		Transfer(from,recipient,val);
        return true;
	}
	
	function mint(address recipient,uint val) onlyOwner public returns (bool){
	    balances[recipient] = balances[recipient].add(val);
	    totalSupply = totalSupply.add(val);
	    return true;
	    
	}
	
    function allowance(address holder, address recipient) public constant returns (uint remaining) {
        return allowed[holder][recipient];
    }
    function burn(uint publicTokens) onlyOwner public returns  (bool success){
        transfer(address(0),hardCap - (10*((10*publicTokens) * 6)).div(1000));
        
        return true;
    }
    

    
    function NauticusToken () public {mint(owner,hardCap);}
	


}	


