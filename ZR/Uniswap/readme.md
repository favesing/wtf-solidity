# 一 UniswapV2Pair.so
## 1 _update
### 1.1 代码
```
// update reserves and, on the first call per block, price accumulators
function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
    require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'UniswapV2: OVERFLOW');
    uint32 blockTimestamp = uint32(block.timestamp % 2**32);
    uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
    if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
        // 关键行：累计价格 = 价格 * 时间
        price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
        price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
    }
    reserve0 = uint112(balance0);
    reserve1 = uint112(balance1);
    blockTimestampLast = blockTimestamp;
    emit Sync(reserve0, reserve1);
}
```
### 1.2 时间加权平均价格(TWAP)
时间加权平均价格（TWAP）是区块链和 DeFi 领域一个极其重要的概念，尤其是在像 Uniswap 这样的去中心化交易所中。它被广泛用作一种抗操纵的链上价格预言机
```
uint32 timeElapsed = blockTimestamp - blockTimestampLast; // 计算时间间隔
if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
    // 关键行：累计价格 = 价格 * 时间
    price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
    price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
}
```

#### 1.2.1 核心思想：解决什么问题？
在区块链上获取资产价格最直接的方法是询问 Uniswap 这样的 DEX：“ETH/USDC 当前的价格是多少？”。

然而，这个当前价格很容易被操纵：

- 一个巨鲸可以在一个区块内进行一笔大额交易，人为地推高或拉低瞬时价格。
- 如果另一个合约（例如借贷协议）直接读取这个被操纵后的价格，可能会导致错误的清算或不公平的交易。

 TWAP 的核心思想是：不使用瞬时价格，而是使用一段时间内的平均价格。 因为单笔交易很难长时间操纵整个市场的平均价格，所以 TWAP 更可靠、更抗操纵。

#### 1.2.2 TWAP工作原理
TWAP 的计算公式本质上与物理学中计算平均速度类似：

![TWAP原理图](img/CleanShot20250911-112014.png)

```
// 计算 reserve0 的价格*时间
price0CumulativeLast += (reserve1 / reserve0) * timeElapsed;
// 类比 : 人民币:美元 = 10:1
计算人民币价格累加 += (1/10) = 0.1美元价格
```
一个简单的类比：计算平均车速
想象一下计算一辆汽车的平均速度：

- 你不是在某个瞬间看一眼速度表（容易被急加速/急刹车操纵），而是记录下整个行程的 总距离 和 总时间。
- 平均速度 = 总距离 / 总时间

## 2 _minFee
### 2.1 代码
```
// if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
    address feeTo = IUniswapV2Factory(factory).feeTo();
    feeOn = feeTo != address(0);
    uint _kLast = kLast; // gas savings
    if (feeOn) {
        if (_kLast != 0) {
            uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
            uint rootKLast = Math.sqrt(_kLast);
            if (rootK > rootKLast) {
                uint numerator = totalSupply.mul(rootK.sub(rootKLast));
                uint denominator = rootK.mul(5).add(rootKLast);
                uint liquidity = numerator / denominator;
                if (liquidity > 0) _mint(feeTo, liquidity);
            }
        }
    } else if (_kLast != 0) {
        kLast = 0;
    }
}
```

- 作用：根据流动性池的增长情况，铸造新的 LP Token 作为手续费奖励。

- 触发条件：当前储备量的几何平均数 rootK大于上一次的值 rootKLast（即流动性池规模扩大）。

### 2.2 关键变量解析

(1) rootK和 rootKLast

	rootK = √(reserve0 * reserve1)
	当前储备量 _reserve0和 _reserve1的几何平均数，代表当前流动性池的规模。

	rootKLast = √(_kLast)
	上一次的储备量几何平均数（存储在 _kLast中）。

(2) totalSupply

	当前 LP Token 的总供应量。

(3) feeTo

	协议指定的手续费接收地址（由工厂合约 setFeeTo设置）。

### 2.3 数学逻辑详解

(1) 检查流动性增长
```
if (rootK > rootKLast) { ... }
```

	只有当前流动性池规模（rootK）比上次大时，才分配手续费

(2) 计算新增流动性
```
uint numerator = totalSupply.mul(rootK.sub(rootKLast));
uint denominator = rootK.mul(5).add(rootKLast);
uint liquidity = numerator / denominator;
```

	分子：totalSupply * (rootK - rootKLast)

	新增流动性的“总量”。

	分母：rootK * 5 + rootKLast

	调节系数，确保手续费比例约为 1/6（见下文推导）。

	结果：liquidity是新铸造的 LP Token 数量。

(3) 手续费比例推导

	假设 rootKLast = x，rootK = x + Δx（Δx 是增长部分）。
	手续费比例为：

![image_png](img/CleanShot20250911-125614.png)

(4) 铸造 LP Token
```
if (liquidity > 0) _mint(feeTo, liquidity);
```
	将计算出的 liquidity铸造给 feeTo地址。

### 2.4. 为什么这样设计？

- 激励协议生态：手续费奖励鼓励用户提供流动性。

- 抗操纵性：基于几何平均数（而非算术平均数）计算，防止单边储备量操纵。

- 公平性：手续费按流动性池规模的增长比例分配。

### 2.5. 示例演算
```
假设：

_reserve0 = 100，_reserve1 = 100（当前储备）

_kLast = 90 * 90 = 8100（上次储备）

totalSupply = 1000（LP Token 总量）

计算：

1.rootK = √(100 * 100) = 100

2.rootKLast = √8100 = 90

3.rootK > rootKLast→ 进入逻辑

4.numerator = 1000 * (100 - 90) = 10000

5.denominator = 100 * 5 + 90 = 590

6.liquidity = 10000 / 590 ≈ 16

7.铸造 16 个 LP Token 给 feeTo。
```
