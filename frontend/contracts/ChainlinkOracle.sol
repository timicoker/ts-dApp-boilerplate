pragma solidity ^0.8.0;
import "https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/evm-contracts/src/v0.6/ChainlinkClient.sol";

//this Chainlink example inherits from ChainlinkClient

contract ChainlinkExample is ChainlinkClient {
    //define state variables stored on the block chain
    uint256 public currentPrice;
    address public owner;
    address public Oracle;
    bytes32 public jobId;
    uint256 public fee;

    //constructor is run at the time of contract creating
    constructor() public {
        setPublicChainlinkToken();
        owner = msg.sender;
        Oracle = 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e;
        jobId = "29fa9aa13bf1468788b7cc4a500a45b8";
        fee = 0.1 * 10**18; // 0.1 LINK
    }

    //function below creates a Chainlink API request to get a price
    //only the owner of the contract can call this function
    function requestPrice() public onlyOwner returns (bytes32 requestId) {
        //create a variable and store it temporarily in memory
        Chainlink.Request memory request =
            buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        //set the url to perform the GET request
        request.add(
            "get",
            "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD"
        );
        //set the path to find the requred data in the api response
        request.add("path", "USD");
        //multiply the results by 100 to remove decimals
        request.addInt("times", 100);
        //send the request
        return sendChainlinkRequestTo(Oracle, request, fee);
    }

    function fulfill(bytes32 _requestId, uint256 _price)
        public
        recordChainlinkFulfillment(_requestId)
    {
        currentPrice = _price;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}
