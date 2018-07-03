pragma solidity ^0.4.24;

/////設定管理者/////

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}    

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns(bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/////遊戲合約/////

contract game is owned{
    
//初始設定
    address public tokenAddress = 0x7741074905402D41AaF64abBa5BbD3a1705e8Ff5;
    
    mapping (address => uint) readyTime;
    uint public amount = 1000*100;  //*100為10^2，幣為兩位小數
    uint public cooldown = 300;  //冷卻時間(秒)
    mapping (address => uint8) record;

//管理權限
    function set_amount(uint new_amount)onlyOwner{
        amount = new_amount*100;
    }
    
    function set_address(address new_address)onlyOwner{
        tokenAddress = new_address;
    }
    
    function set_cooldown(uint new_cooldown)onlyOwner{
        cooldown = new_cooldown;
    }
    
    function withdraw(uint _amount)onlyOwner{
        require(ERC20Basic(tokenAddress).transfer(owner, _amount*100));
    }
    
//來猜拳!!! 
    function (){
        play_game(0);
    }
    
    function play_paper(){
        play_game(0);
    }
    
    function play_scissors(){
        play_game(1);
    }
    
    function play_stone(){
        play_game(2);
    }
    
    function play_game(uint8 play) internal{
        require(readyTime[msg.sender] < block.timestamp);
        
        uint8 comp=uint8(uint(keccak256(block.difficulty, block.timestamp))%3);
        uint8 result = compare(play, comp);
        
        record[msg.sender] = result * 9 + play * 3 + comp ;
        
        if (result == 2){ //玩家贏
            require(ERC20Basic(tokenAddress).transfer(msg.sender, amount));
            
        }
        
        else if(result == 1){ //平手
        }
        
        else if(result == 0) //玩家輸
            readyTime[msg.sender] = block.timestamp + cooldown;
    }
    
    function compare(uint8 player,uint computer) view public returns(uint8 result){
        // input     0 => 布   1 => 剪刀   2 => 石頭
        // output    0 => 輸   1 => 平手   2 => 贏
        uint8 _result;
        
        if (player==0 && computer==2){  //布贏石頭 (玩家贏)
            _result = 2;
        }
        
        else if(player==2 && computer==0){ //石頭輸布(玩家輸)
            _result = 0;
        }
        
        else if(player == computer){ //平手
            _result = 1;
        }
        
        else{
            if (player > computer){ //玩家贏 (玩家贏)
                _result = 2;
            }
            else{ //玩家輸
                _result = 0;
            }
        }
        return _result;
    }
    
    
//查詢

    function resolve(uint8 orig) view returns(uint8 result, uint8 play, uint8 comp){
        uint8 _result = orig/9;
        uint8 _play = (orig%9)/3;
        uint8 _comp = orig%3;
        return(_result, _play, _comp);
    }
    
    function judge(uint8 orig) view returns(string mora){
        // 0 => 布   1 => 剪刀   2 => 石頭
            if (orig == 0){
                return &quot;paper&quot;;
            }
            else if (orig == 1){
                return &quot;scissors&quot;;
            }
            else if (orig == 2){
                return &quot;stone&quot;;
            }
            else {
                return &quot;error&quot;;
            }
        }
        
    function win(uint8 _result) view returns(string result){
        // 0 => 輸   1 => 平手   2 => 贏
        if (_result == 0){
                return &quot; lose!! &quot;;
            }
            else if (_result == 1){
                return &quot; draw~~ &quot;;
            }
            else if (_result == 2){
                return &quot; win!!!&quot;;
            }
            else {
                return &quot; error &quot;;
            }
    }
    
    function view_readyTime(address _address) view public returns(uint _readyTime){
        if (block.timestamp >= readyTime[_address]){
        return 0 ;
        }
        else{
        return readyTime[_address] - block.timestamp ;
        }
    }
    
    function self_readyTime() view public returns(uint _readyTime){
        view_readyTime(msg.sender);
    }
    
    function view_last_result(address _address) view public returns(string result, string play, string comp){
        uint8 orig = record[_address];
        (uint8 _result, uint8 _play, uint8 _comp) = resolve(orig);
        return (win(_result), judge(_play), judge(_comp));
    }
        
    function self_last_result() view public returns(string result, string player, string computer){
        view_last_result(msg.sender);
    }
    
}