// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "../CrossChainBridge/extendedIERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";


contract LiquidityPool is ERC20{
    
    uint256 public reserve1;
    uint256 public reserve2;
    IERC20  public immutable token1;
    IERC20  public immutable token2;

    constructor(address _token1, address _token2) ERC20("LP Token", "LPT"){
        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
    }
    event LPTokensMinted(address user, uint256 value);
    event LPTokensBurned(address user, uint256 value);
    function _updateReserve(uint256 _reserve1, uint256 _reserve2) internal {
       reserve1 = _reserve1;
       reserve2 = _reserve2;
    }

    function addLiquidity(uint256 amountTokenA, uint256 amountTokenB) public {
        require(token1.transferFrom(msg.sender, address(this), amountTokenA), "Transaction Failed at token1");
        require(token2.transferFrom(msg.sender, address(this), amountTokenB), "Transaction Failed at token2");

        uint256 totalLiquidity = totalSupply();

        uint256 totalShares;

        if (reserve1 > 0 || reserve2 > 0){

            require(amountTokenA * reserve2 == amountTokenB * reserve1, "Unbalanced Liquidity");

            totalShares = min((amountTokenA * totalLiquidity) / reserve1,
             (amountTokenB * totalLiquidity) / reserve2);

             _mint(msg.sender, totalShares);
        }
        else {
            totalShares = sqrt(amountTokenA * amountTokenB);
            _mint(address(1), 10**3);
            _mint (msg.sender, totalShares - 10**3);
        }
        require (totalShares > 0, "NO LP Tokens To Mint");
        _updateReserve(token1.balanceOf(address(this)), token2.balanceOf(address(this)));
        emit LPTokensMinted(msg.sender, totalShares);
    }

    function removeLiquidity(uint256 amount) public {
       require(amount <= balanceOf(msg.sender) && amount > 0, "Insufficient Funds");
       uint256 amountToken1 = (amount*reserve1) / totalSupply();
       uint256 amountToken2 = (amount*reserve2) / totalSupply();
       require(amountToken1 > 0 && amountToken2 > 0, "Insufficient Transfer Amount");
       _burn(msg.sender, amount);
       require(token1.transfer(msg.sender, amountToken1), "Transfer Failed");
       require(token2.transfer(msg.sender, amountToken2), "Transfer Failed");
       _updateReserve(reserve1 - amountToken1, reserve2 - amountToken2);
       emit LPTokensBurned(msg.sender, amount);
    }
    function swapTokens(address tokenToSwap, uint256 valueToSwap, uint256 minAmountOut) public {
        require(totalSupply() >0,"Add Liquidity First");
        require(tokenToSwap == address(token1) || tokenToSwap == address(token2), "Invalid Address");
      bool isToken1 = tokenToSwap == address(token1);
      (IERC20 tokenIn, IERC20 tokenOut) = isToken1 ? (token1, token2): (token2, token1);
      uint256 reserveOut = tokenOut.balanceOf(address(this));
      uint256 reserveIn  = tokenIn.balanceOf(address(this));
      uint256 amountwithfee = (valueToSwap * 995) / 1000; // fee 0.5%
      require(tokenIn.transferFrom(msg.sender, address(this), valueToSwap), "transferFrom Failed");
      uint256 amountOut = (reserveOut * amountwithfee) / (reserveIn + amountwithfee);
      require(amountOut >= minAmountOut, "Slippage Tolerance Exceeded");
      require(amountOut <= tokenOut.balanceOf(address(this)), "Insuffcient Liquidity in the Pool");
      require(tokenOut.transfer(msg.sender, amountOut),"Transfer Failed");
      _updateReserve(token1.balanceOf(address(this)), token2.balanceOf(address(this)));
      
      
      
    }

     function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }
}
