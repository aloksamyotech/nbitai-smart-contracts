// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract NbitaiTokenSale is Ownable, Pausable {
    // Inverse basis point
    uint256 public constant INVERSE_BASIS_POINT = 10 ** 18;

    uint256 public claimTime;
    address public token;
    uint256 public totalSold;

    mapping(address => uint256) public totalCollection;
    mapping(address => uint256) public rates;
    mapping(address => uint256) public balanceOf;

    event Rate(address indexed paymentToken, uint256 rate);
    event NewClaimTime(uint256 claimTime);
    event IssueSupply(address indexed from, uint256 supply);
    event Withdrawal(address indexed user, uint amount);
    event WithdrawSupply(address indexed to, uint256 supply);
    event WithdrawCollection(
        address indexed paymentToken,
        address indexed to,
        uint256 supply
    );
    event Sale(
        address indexed buyer,
        uint256 amount,
        address indexed paymentToken,
        uint256 rate,
        uint256 paidAmount,
        string indexed referralCode
    );

    constructor(address _token, uint _claimTime) Ownable(msg.sender) {
        require(
            block.timestamp < _claimTime,
            "NbitaiTokenSale: Claim time should be in the future"
        );

        token = _token;
        claimTime = _claimTime;
    }

    /**
     * Call ERC20 `transferFrom`
     *
     * @dev Transfer tokens
     * @param _token Token address
     * @param _from Address to charge fees
     * @param _to Address to receive fees
     * @param _amount Amount of protocol tokens to charge
     */
    function _transferTokens(
        address _token,
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        if (_amount > 0) {
            require(
                ERC20(_token).transferFrom(_from, _to, _amount),
                "NbitaiTokenSale#_transferTokens: ERC20_TRANSFER_FAILED"
            );
        }
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setRate(address _token, uint256 _rate) external onlyOwner {
        rates[_token] = _rate;
        emit Rate(_token, _rate);
    }

    function setClaim(uint256 _claimTime) external onlyOwner {
        claimTime = _claimTime;
        emit NewClaimTime(_claimTime);
    }

    function supply() public view returns (uint256) {
        return ERC20(token).balanceOf(address(this));
    }

    function collection(address _paymentToken) public view returns (uint256) {
        return ERC20(_paymentToken).balanceOf(address(this));
    }

    function addSupply(address _from, uint256 _supply) external onlyOwner {
        require(
            ERC20(token).allowance(_from, address(this)) >= _supply,
            "NbitaiTokenSale#addSupply: NOT_AUTHORIZED_TO_SPEND"
        );
        _transferTokens(token, _from, address(this), _supply);
        emit IssueSupply(_from, _supply);
    }

    function withdrawSupply(address _to, uint256 _supply) external onlyOwner {
        require(
            supply() >= _supply,
            "NbitaiTokenSale#withdrawSupply: INSUFFICIENT_SUPPLY"
        );
        require(
            ERC20(token).transfer(_to, _supply),
            "NbitaiTokenSale#withdrawSupply: TRANSFER_FAILED"
        );
        emit WithdrawSupply(_to, _supply);
    }

    function withdrawCollection(
        address _paymentToken,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        require(
            collection(_paymentToken) >= _amount,
            "NbitaiTokenSale#withdrawCollection: INSUFFICIENT_AMOUNT"
        );
        require(
            ERC20(_paymentToken).transfer(_to, _amount),
            "NbitaiTokenSale#withdrawCollection: TRANSFER_FAILED"
        );
        emit WithdrawCollection(_paymentToken, _to, _amount);
    }

    function purchase(
        uint256 amount,
        address paymentToken,
        string memory referralCode
    ) external whenNotPaused {
        require(
            amount > 0,
            "NbitaiTokenSale#purchase: AMOUNT_ZERO_NOT_ALLOWED"
        );
        require(
            rates[paymentToken] > 0,
            "NbitaiTokenSale#purchase: PAYMENT_TOKEN_NOT_ALLOWED"
        );

        uint256 receiveAmount = Math.mulDiv(
            amount,
            rates[paymentToken],
            INVERSE_BASIS_POINT
        );
        require(
            supply() >= receiveAmount,
            "NbitaiTokenSale#purchase: INSUFFICIENT_AMOUNT"
        );

        _transferTokens(paymentToken, msg.sender, address(this), amount);

        balanceOf[msg.sender] += receiveAmount;
        totalSold += receiveAmount;
        totalCollection[paymentToken] += amount;

        emit Sale(
            msg.sender,
            receiveAmount,
            paymentToken,
            rates[paymentToken],
            amount,
            referralCode
        );
    }

    function withdraw() external {
        require(
            block.timestamp >= claimTime,
            "NbitaiTokenSale#withdraw: WITHDRAW_NOT_ALLOWED_YET"
        );

        uint256 amount = balanceOf[msg.sender];
        require(
            amount > 0,
            "NbitaiTokenSale#withdraw: AMOUNT_ZERO_NOT_ALLOWED"
        );
        require(
            ERC20(token).transfer(msg.sender, amount),
            "NbitaiTokenSale#withdraw: TRANSFER_FAILED"
        );

        balanceOf[msg.sender] = 0;

        emit Withdrawal(msg.sender, amount);
    }
}
