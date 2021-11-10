// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import 'hardhat/console.sol';

contract TomCoin is ERC20,Ownable{
    address payable public treasury;
    uint256 public iwoStartTime = 1636459200;//2021-11-09 20:00
    uint256 public iwoendtime = 1636473600;//2021-11-10 00:00:00
    uint256 public idostarttime = 1636545600;//2021-11-10 20:00:00
    uint256 public idoEndTime = 1636560000;//2021-11-11 00:00:00
    uint256 public freetime;
    uint256[] public subscribers;
    
    mapping (address => uint8) public whitelist;
    mapping( address => uint8) public idolist;

    event IWO(address buyer, uint256 inTokens, uint256 outTokens);
    event IDO(address buyer, uint256 inTokens, uint256 outTokens);
    event WITHDRAW(address withdrawer, uint256 amount);
    event WITHDRAWTOKEN(address withdrawer, uint256 amount);
    event SWAP(address owner,uint256 inTokens, uint256 outTokens);

    constructor(address payable _treasury) ERC20("Tom Coin","TOM"){  
        treasury = _treasury;      
        _mint(treasury, 100000000 * 1e8);
        _approve(treasury, address(this),type(uint256).max);
        freetime = 1667890700;
    }

    function decimals() public pure override returns (uint8) {
        return 8;
    }

    function addWhiteList(address[] memory vips) external onlyOwner{
        require(vips.length>0,"Numpty List");
        for(uint256 i=0;i<vips.length;i++){
            if(vips[i]==address(0)) continue;
            if(whitelist[vips[i]] == uint8(1)) continue;
            whitelist[vips[i]] = uint8(1);
        }
    }

    function setIwoTime(uint256 _starttime, uint256 _endtime) external onlyOwner {
        require(block.timestamp<iwoStartTime,"CAN'T SET");
        require(_starttime > block.timestamp &&_endtime > block.timestamp, "ERROR TIME");
        iwoendtime = _endtime;
        iwoStartTime = _starttime;
    }
    function iwo() payable external{
        require(block.timestamp >= iwoStartTime && block.timestamp <= iwoendtime , "UNACTIVATED");
        require(whitelist[msg.sender] == uint8(1), "DON'T ALLOWN");
        require(msg.value == 5 ether,"ERROR VALUE");

        uint256 amount = msg.value * 5000 / (10 ** (18 - decimals()));
        require(amount<=balanceOf(address(this)),"INSUFFIENT TOKEN");

        whitelist[msg.sender] = uint8(2);
        treasury.transfer(msg.value);        
        _transfer(address(this), msg.sender, amount);
        
        emit IWO(msg.sender,msg.value,amount);
    }

    function setIdoTime(uint256 _starttime, uint256 _endtime) external onlyOwner{
        require(block.timestamp<idostarttime,"CAN'T SET");
        require(_starttime > block.timestamp &&_endtime > block.timestamp, "ERROR TIME");
        idostarttime = _starttime;
        idoEndTime = _endtime;
    }

    function ido() payable external{        
        require(block.timestamp >= idostarttime && block.timestamp <= idoEndTime, "UNACTIVATED");
        require(msg.value >= 2 ether && msg.value <= 5 ether,"OVER OR LOWER");
        require(idolist[msg.sender]==0, "REPEAT");
        uint256 amount = msg.value * 5000 / (10 ** (18 - decimals()));
        require(amount<=balanceOf(address(this)),"INSUFFIENT TOKEN");

        idolist[msg.sender] = uint8(1);
        treasury.transfer(msg.value);        
        _transfer(address(this), msg.sender, amount);
        
        emit IDO(msg.sender,msg.value,amount);
    }

    function withdrawToken( uint256 amount ) external onlyOwner {
        if(amount > balanceOf(address(this))){
            amount = balanceOf(address(this));
        }
        require(amount > 0, "ZERO");

        transfer(msg.sender, amount);
        emit WITHDRAWTOKEN(msg.sender, amount);

    }

    function setFreetime( uint256 _timestamp) external onlyOwner{
        require(_timestamp > block.timestamp,"ERROR TIME");
        freetime = _timestamp;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(block.timestamp>freetime || msg.sender==treasury || msg.sender == address(this), "PROHIBITED PERIOD OF TRANSFER");
        return ERC20.transfer(recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool){
        require(block.timestamp>freetime || msg.sender==treasury || msg.sender == address(this), "PROHIBITED PERIOD OF TRANSFER");
        return ERC20.transferFrom(sender, recipient, amount);
    }

    receive() external payable {

    }
}