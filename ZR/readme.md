# 一、Solidity 学习资料
Etherenm: https://ethereum.org/zh/developers/docs/

WTF学习资料: https://www.wtf.academy/

WTF代码示例: https://github.com/AmazingAng/WTF-Solidity/blob/main/12_Event/readme.md

Uniswap: https://github.com/Uniswap/v2-core/tree/master/contracts

# 二、测试
目标: 部署到Sepolia ETH网络, 并在Etherscan上查看log

    合约 Solidity101-12-EventToken.sol

    首先，你需要一个包含 _transfer()函数的 ERC-20 合约。以下是示例代码：
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply);
    }

    // 公开的 transfer 函数（可选，因为 ERC20 已有 transfer）
    function publicTransfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    // 或者直接使用内部 _transfer（需要权限控制）
    function adminTransfer(address from, address to, uint256 amount) public returns (bool) {
        // 通常需要权限检查，这里简化示例
        _transfer(from, to, amount);
        return true;
    }
}
```

​​步骤 1：编译合约​​
- 在 Remix 中粘贴上述代码
- 选择正确的编译器版本（0.8.0+）
- 编译合约

​​步骤 2：连接 Sepolia 网络​​

1. 安装 MetaMask 并连接到 Sepolia 测试网
2. 获取 Sepolia ETH 测试币（从 faucet）
3. 在 Remix 的 "Deploy & Run Transactions" 选项卡中：
    - Environment: ​​Injected Provider - MetaMask​​
    - Account: 选择你的 Sepolia 账户
    - 确保网络显示为 ​​Sepolia​​

​​步骤 3：部署合约​

```
// 使用 _transfer()函数在 Sepolia 测试网络上转账 100 代币，以下是完整的步骤和验证方法：
// 部署参数：初始供应量，例如 1000000 * 10^18
1000000000000000000000000
```
- 点击 "Deploy"
- 在 MetaMask 中确认交易

​​步骤 4：执行转账​

- 使用 publicTransfer