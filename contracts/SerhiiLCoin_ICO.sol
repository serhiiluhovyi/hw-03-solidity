pragma solidity 0.8.10;

import "./SerhiiLCoin.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface HomeContractClient {
    function getStudentsList() external view returns (string[] memory students);
}

contract SerhiiLCoin_ICO is SerhiiLCoin {

    address public admin;
    address payable public deposit;
    address private HomeContractAddr = 0x0E822C71e628b20a35F8bCAbe8c11F274246e64D;

    //    uint tokenPrice = 0.1 ether;  // 1 ETH = 10 SLC, 1 CRPT = 0.1
    uint public hardCap = 50 ether;
    uint public raisedAmount; // this value will be in wei
    uint public saleStart = block.timestamp;
    uint public saleEnd = block.timestamp + 604800; //one week

    uint public tokenTradeStart = saleEnd + 604800; //transferable in a week after saleEnd
    uint public maxInvestment = 0.3 ether;
    uint public minInvestment = 0.1 ether;

    AggregatorV3Interface internal priceFeed;

    // ICO states
    enum State {
        beforeStart,
        running,
        afterEnd,
        halted
    }

    State public icoState;

    constructor(){
        admin = msg.sender;
        deposit = payable(0x023c5740862327682ab022D6B3e160cc4Cc0EdfD); // my metamask acc 2
        icoState = State.beforeStart;
        priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e); //https://docs.chain.link/docs/ethereum-addresses/
    }

    modifier onlyAdmin(){
        require(msg.sender == admin);
        _;
    }

    // emergency stop
    function halt() public onlyAdmin {
        icoState = State.halted;
    }

    function resume() public onlyAdmin {
        icoState = State.running;
    }

    function changeDepositAddress(address payable newDeposit) public onlyAdmin {
        deposit = newDeposit;
    }

    function getCurrentState() public view returns (State){
        if (icoState == State.halted) {
            return State.halted;
        } else if (block.timestamp < saleStart) {
            return State.beforeStart;
        } else if (block.timestamp >= saleStart && block.timestamp <= saleEnd) {
            return State.running;
        } else {
            return State.afterEnd;
        }
    }

    event Invest(address investor, uint value, uint tokens);

    function studentListSize() view public returns (uint){
        return HomeContractClient(HomeContractAddr).getStudentsList().length;
    }

    function getLatestETHUSDPrice() public view returns (uint) {
        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return uint(price);
    }

    function calcTokenPrice() public view returns (uint) {
        uint count = studentListSize();
        return getLatestETHUSDPrice() / count * 1000000; // just adjucted the price for readable demo with metemask - 1eth = 80 - 100 this coins
    }

    // function called when sending eth to the contract
    function buyTokens() payable public returns (bool){
        icoState = getCurrentState();
        require(icoState == State.running);
        if(msg.value < minInvestment || msg.value > maxInvestment){
            (bool sent, bytes memory data) = msg.sender.call{gas:210000,value:msg.value}("Sorry, contract rules: minInvestment = 0.1 ether and maxInvestment = 0.3 ether");
        }

        raisedAmount += msg.value;
        require(raisedAmount <= hardCap);

        uint tokenPrice = calcTokenPrice();
        uint tokens = msg.value / tokenPrice;

        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        deposit.transfer(msg.value); // transfering the value sent to the ICO to the deposit address

        emit Invest(msg.sender, msg.value, tokens);

        return true;
    }

    // this function is called automatically when someone sends ETH to the contract's address
    receive() payable external {
        buyTokens();
    }

    // burning unsold tokens
    function burn() public returns (bool){
        icoState = getCurrentState();
        require(icoState == State.afterEnd);
        balances[founder] = 0;
        return true;
    }

    function transfer(address to, uint tokens) public override returns (bool success){
        require(block.timestamp > tokenTradeStart);
        // the token will be transferable only after tokenTradeStart
        super.transfer(to, tokens);
        return true;
    }


    function transferFrom(address from, address to, uint tokens) public override returns (bool success){
        require(block.timestamp > tokenTradeStart);
        // the token will be transferable only after tokenTradeStart
        super.transferFrom(from, to, tokens);
        return true;
    }

}
