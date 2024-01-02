// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./student.sol";


contract MWAY is ERC20, students, ReentrancyGuard {

    /*TYPE DECLARATION*/
    address public contractAccount; // address of the contract
    address public ownerAccount; // contract owner
    
    /* VARIABLES*/
    string constant public _symbol = "MWAY";
    string constant public _name = "Mealway Coin";
    uint constant public _initialSupply = 1000000000000000000;// 18 zeros
    uint constant public _decimal = 2;
    uint256 constant private ETH_TO_MWAY_RATE = 100; // 10 WEI * rate = 1000 tokens
    
    /* EVENTS */
    //emits when spendToken function is called
    event ItemPurchased(address indexed buyer, uint item, uint quantity);
    //emits when etherToMWAY function is called
    event EtherDeposited(address indexed depositor, uint256 etherAmount, uint256 tokenAmount);
    //emits when mint function is called
    event TokensMinted(address indexed to, uint256 amount);
    //emits when approvedSpender function is called
    event SpenderApproved(address indexed owner, address indexed spender, uint256 amount);
    
    /* ERRORS */
    // Fallback function to handle Ether sent to the contract without any data 
    receive() external payable {
        revert("Fallback function not allowed");
    }

    /* CONSTRUCTOR */
    constructor() ERC20(_name, _symbol) {
        //create constructor
        _mint(msg.sender, _initialSupply * 10 ** _decimal);
        assert(_initialSupply > 0);
        contractAccount = address(this);
        ownerAccount = msg.sender;
    }

    /* MODIFIERS */
    //only the owner can access specific functions 
    modifier ownerOnly(){
        require(msg.sender == ownerAccount, "Insufficient Privileges");
        _;
    }

    //only allows positive input values
    modifier onlyPositiveValue(uint256 value) {
        require(value > 0, "Value must be greater than zero");
        _;
    }

    /* FUNCTIONS */
    //allows student to check their token balance
    function checkMyBalance() public view returns (uint256){
        return balanceOf(msg.sender);    
    }  
    
    // Function to deposit Ether and receive MWAY in exchange
    function etherToMWAY() public payable nonReentrant onlyPositiveValue(msg.value){
        require(msg.value > 0, "Must send Ether with the transaction");
        
        // Calculate the amount of tokens to mint based on the exchange rate
        uint256 _tokenAmount = msg.value * ETH_TO_MWAY_RATE;

        // Mint the tokens and send them to the depositor
        _mint(msg.sender, _tokenAmount);

        // Emit an event to log the deposit
        emit EtherDeposited(msg.sender, msg.value, _tokenAmount);
    }

    // function to purchase food items from menu
    function spendTokens(
        uint8 _item,
        uint8 _quantity) public nonReentrant onlyPositiveValue(_quantity) returns (bool){
        // require student to be registered to be able to purchase
        require(isStudentRegistered[msg.sender], "Student is not Registered!!!");
    
        // ensures item selected is within the menu
        require(Menu.getFoodPrice(_item) > 0, "Invalid item");
        uint _totalCost = Menu.getFoodPrice(_item) * _quantity;        

        // require statement for overflow
        require(_totalCost / Menu.getFoodPrice(_item) == _quantity, "Multiplication overflow");

        // requires student's balance to be equal or greater than total cost
        require(balanceOf(msg.sender) >= _totalCost, "Insufficient balance");

        // Transfer tokens to the owner (seller)
        _transfer(msg.sender, ownerAccount, _totalCost);

        emit ItemPurchased(msg.sender, _item, _quantity);

        // Ensures that the total cost is greater than 0
        assert(_totalCost > 0);

        return true;
    }

    // function to approve a spender on behalf of the owner, onlyowner can call
    function approveSpender(address _spender, uint256 _amount) public ownerOnly returns (bool){
        _approve(msg.sender, _spender, _amount);

        //
        emit SpenderApproved(msg.sender, _spender, _amount);
        return true;
    }

    // function to return the allowance of the authorised spender
    function getAllowance(address _owner, address _spender) public view returns (uint256) {
    return allowance(_owner, _spender);
    }

    // function to allow approved address to transfer tokens from the owner's account to another account
    function transferFromWithApproval(
        address _from, 
        address _to, 
        uint256 _amount) public nonReentrant onlyPositiveValue(_amount) returns (bool) {
        // Ensure that the spender is approved to spend the required amount
        require(allowance(_from, msg.sender) >= _amount, "Allowance too low");

        // Transfer tokens from the owner's account to the recipient
        _transfer(_from, _to, _amount);

        // Decrease the spender's allowance
        _approve(_from, msg.sender, allowance(_from, msg.sender) - _amount);

        return true;
    }
    
    // Function to transfer tokens to another wallet address
    function transferTokens(address _to, uint256 _amount) public nonReentrant returns (bool) {
        require(_to != address(0), "Invalid address");
        
        //checks for underflow
        require(balanceOf(msg.sender) >= _amount, "Insufficient balance");
        require(_amount > 0, "Amount must be greater than zero"); 
        
        // Use the transfer function from ERC20
        _transfer(msg.sender, _to, _amount);

        return true;
    }

    //function to mint extra tokens if required
    function mint(address _to, uint _amount) external ownerOnly onlyPositiveValue(_amount){
        //check for overflow
        require(totalSupply() + _amount > totalSupply(), "Token supply overflow");

        _mint(_to, _amount);

        //ensures minted amount is greater than 0
        assert(_amount > 0);

        //
        emit TokensMinted(_to, _amount);
    }
}
