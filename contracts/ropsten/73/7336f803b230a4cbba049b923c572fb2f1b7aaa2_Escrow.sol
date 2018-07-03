pragma solidity 0.4.24;
pragma experimental &quot;v0.5.0&quot;;

/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract SRNTPriceOracleBasic {
    uint256 public SRNT_per_ETH;
}

contract Escrow {
    using SafeMath for uint256;

    address public party_a;
    address public party_b;
    address constant serenity_wallet = 0x47c8F28e6056374aBA3DF0854306c2556B104601;
    address constant burn_address = 0x0000000000000000000000000000000000000001;
    ERC20Basic constant SRNT_token = ERC20Basic(0xBC7942054F77b82e8A71aCE170E4B00ebAe67eB6);
    SRNTPriceOracleBasic constant SRNT_price_oracle = SRNTPriceOracleBasic(0xae5D95379487d047101C4912BddC6942090E5D17);

    uint256 public withdrawal_amount;
    address public withdrawal_address;
    address public withdrawal_last_voter;

    event Deposit(uint256 amount);
    event WithdrawalRequest(address receiver, address requester, uint256 amount);
    event Withdrawal(address receiver, uint256 amount);

    constructor (address new_party_a, address new_party_b) public {
        party_a = new_party_a;
        party_b = new_party_b;
    }

    function () external payable {
        // New deposit - take commission and issue an event
        uint256 fee = msg.value.div(100);
        uint256 srnt_balance = SRNT_token.balanceOf(address(this));
        uint256 fee_paid_by_srnt = srnt_balance.div(SRNT_price_oracle.SRNT_per_ETH());
        if (fee_paid_by_srnt < fee) {  // Burn all SRNT, deduct from fee
            if (fee_paid_by_srnt > 0) {
                fee = fee.sub(fee_paid_by_srnt);
                SRNT_token.transfer(burn_address, srnt_balance);
            }
            serenity_wallet.transfer(fee);
            emit Deposit(msg.value.sub(fee));
        } else {  // There&#39;s more SRNT available than needed. Burn a part of it.
            SRNT_token.transfer(burn_address, fee.mul(SRNT_price_oracle.SRNT_per_ETH()));
            emit Deposit(msg.value);
        }
    }

    function request_withdrawal(address to, uint256 amount) external {
        require(msg.sender != withdrawal_last_voter);  // You can&#39;t vote twice
        require((msg.sender == party_a) || (msg.sender == party_b) || (msg.sender == serenity_wallet));
        require((to == party_a) || (to == party_b));  // You can&#39;t withdraw to some random guy
        require(amount <= address(this).balance);

        withdrawal_last_voter = msg.sender;

        emit WithdrawalRequest(to, msg.sender, amount);

        if ((withdrawal_amount == amount) && (withdrawal_address == to)) {  // We have consensus
            delete withdrawal_amount;
            delete withdrawal_address;
            delete withdrawal_last_voter;
            to.transfer(amount);
            emit Withdrawal(to, amount);
        } else {
            withdrawal_amount = amount;
            withdrawal_address = to;
        }
    }

}