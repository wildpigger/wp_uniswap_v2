# unisawp路由合约
- 合约分3部分,添加流动性,移除流动性,交换


|**方法名称**|**可视范围**|**类型**|**修饰符**|
|:-:|:-:|:-:|:-:|
| Constructor | Public  | 🛑  ||
| Fallback | External  |  💵 ||
| receive | External  |  💵 ||
| _addLiquidity | Internal 🔒 | 🛑  | |
| addLiquidity | External  | 🛑  | ensure |
| addLiquidityETH | External  |  💵 | ensure |
| removeLiquidity | Public  | 🛑  | ensure |
| removeLiquidityETH | Public  | 🛑  | ensure |
| removeLiquidityWithPermit | External  | 🛑  ||
| removeLiquidityETHWithPermit | External  | 🛑  ||
| removeLiquidityETHSupportingFeeOnTransferTokens | Public  | 🛑  | ensure |
| removeLiquidityETHWithPermitSupportingFeeOnTransferTokens | External  | 🛑  ||
| _swap | Internal 🔒 | 🛑  | |
| swapExactTokensForTokens | External  | 🛑  | ensure |
| swapTokensForExactTokens | External  | 🛑  | ensure |
| swapExactETHForTokens | External  |  💵 | ensure |
| swapTokensForExactETH | External  | 🛑  | ensure |
| swapExactTokensForETH | External  | 🛑  | ensure |
| swapETHForExactTokens | External  |  💵 | ensure |
| _swapSupportingFeeOnTransferTokens | Internal 🔒 | 🛑  | |
| swapExactTokensForTokensSupportingFeeOnTransferTokens | External  | 🛑  | ensure |
| swapExactETHForTokensSupportingFeeOnTransferTokens | External  |  💵 | ensure |
| swapExactTokensForETHSupportingFeeOnTransferTokens | External  | 🛑  | ensure |


## 添加流动性方法
- pair合约拥有一套erc20代币的所有方法
- 用户准备TokenA和TokenB两个代币,期望数量AB,最小数量AB四个数值创建流动性
- 添加流动性方法根据期望AB数量和最小AB数量乘以储备量比例计算最优取出数量AB
- 流动性方法根据取出数量AB将Token存入pair合约
- pair合约为用户创建一个liquidity流动性数值,为存入数量AB的平方根
- 添加流动性方法分为两种,添加两个token的流动性和添加token和ETH的流动性
- 添加token和ETH的流动性方法会将ETH兑换成WETH再进行操作,

### _addLiquidity 添加流动性私有方法
    * @dev 添加流动性的私有方法
    * @param tokenA tokenA地址
    * @param tokenB tokenB地址
    * @param amountADesired 期望数量A
    * @param amountBDesired 期望数量B
    * @param amountAMin 最小数量A
    * @param amountBMin 最小数量B
    * @return amountA   数量A
    * @return amountB   数量B

1. 如果TokenA，TokenB的配对合约不存在则创建pair
2. 从`pair合约`获取 储备量A, 储备量B，储备量AB经过排序
3. 如果储备reserveA, reserveB==0，
    - 则返回值(数量A,数量B)=期望值(期望数量A,期望数量B)
    - 否则
        1. 最优数量B = 期望数量A * 储备量B / 储备量A
        2. 如果最优数量B <= 期望数量B
            - 则
                1. 确认最优数量B >= 最小数量B
                2. (数量A,数量B) = 期望数量A, 最优数量B
            - 否则
                1. 最优数量A = 期望数量A * 储备量A / 储备量B
                2. 断言最优数量A <= 期望数量A
                3. 确认最优数量A >= 最小数量A
                4. (数量A,数量B) = 最优数量A, 期望数量B

### addLiquidity 添加流动性方法
     * @param token token地址
     * @param amountTokenDesired 期望数量
     * @param amountTokenMin Token最小数量
     * @param amountETHMin ETH最小数量
     * @param to to地址
     * @param deadline 最后期限
     * @return amountToken   Token数量
     * @return amountETH   ETH数量
     * @return liquidity   流动性数量

1. (数量A,数量B) = _addLiquidity(tokenA地址,tokenB地址,期望数量A,期望数量B,最小数量A,最小数量B)
2. 根据TokenA,TokenB地址,获取`pair合约`地址
3. 将数量为`数量A`的tokenA从msg.sender账户中安全发送到`pair合约`地址
4. 将数量为`数量B`的tokenB从msg.sender账户中安全发送到`pair合约`地址
5. 流动性数量 = pair合约的铸造方法铸造给`to地址`的返回值

### addLiquidityETH 添加ETH流动性方法
     * @dev 添加ETH流动性方法
     * @param token token地址
     * @param amountTokenDesired Token期望数量
     * @param amountTokenMin Token最小数量
     * @param amountETHMin ETH最小数量
     * @param to to地址
     * @param deadline 最后期限
     * @return amountToken   Token数量
     * @return amountETH   ETH数量
     * @return liquidity   流动性数量

1. (Token数量,ETH数量) = _addLiquidity(token地址,WETH地址,Token期望数量,收到的主币数量,Token最小数量,ETH最小数量)
2. 根据Token,WETH地址,获取`pair合约`地址
3. 将`Token数量`的token从msg.sender账户中安全发送到`pair合约`地址
4. 向`WETH合约`存款`ETH数量`的主币
5. 将`ETH数量`的`WETH`token发送到`pair合约`地址
6. 流动性数量 = pair合约的铸造方法铸造给`to地址`的返回值
7. 如果`收到的主币数量`>`ETH数量` 则返还`收到的主币数量`-`ETH数量`

## 移除流动性方法
- 将发送账户的流动性数量返还给pair合约
- 在pair合约中销毁流动性数量,然后根据最小数量AB计算返还给用户的tokenAB
- 移除流动性方法分两种,移除两个token的流动性,和移除token和ETH的流动性
- 这两种方法又分别拥有两个前置方法,带签名移除两个token流动性和带签名移除token和ETH流动性
- 除此之外还有支持收税的移除ETH流动性方法,和带签名支持收税的移除ETH流动性方法

### removeLiquidity 移除流动性方法
     * @dev 移除流动性
     * @param tokenA tokenA地址
     * @param tokenB tokenB地址
     * @param liquidity 流动性数量
     * @param amountAMin 最小数量A
     * @param amountBMin 最小数量B
     * @param to to地址
     * @param deadline 最后期限
     * @return amountA   数量A
     * @return amountB   数量B

1. 计算TokenA,TokenB的CREATE2地址，而无需进行任何外部调用
2. 将流动性数量从用户发送到pair地址(需提前批准)
3. pair合约销毁流动性数量,并将数值0,1的token发送到to地址
4. 排序tokenA,tokenB
5. 按排序后的token顺序返回数值AB
6. 确保数值AB大于最小值AB

### removeLiquidityETH 移除ETH流动性方法
     * @dev 移除ETH流动性
     * @param token token地址
     * @param liquidity 流动性数量
     * @param amountTokenMin token最小数量
     * @param amountETHMin ETH最小数量
     * @param to to地址
     * @param deadline 最后期限
     * @return amountToken   token数量
     * @return amountETH   ETH数量

1. (token数量,ETH数量) = 移除流动性(token地址,WETH地址,流动性数量,token最小数量,ETH最小数量,当前合约地址,最后期限)
2. 将token数量的token发送到to地址
3. 从WETH取款ETH数量
4. 将ETH数量的ETH发送到to地址

### removeLiquidityWithPermit 带签名移除流动性方法
     * @dev 带签名移除流动性
     * @param tokenA tokenA地址
     * @param tokenB tokenB地址
     * @param liquidity 流动性数量
     * @param amountAMin 最小数量A
     * @param amountBMin 最小数量B
     * @param to to地址
     * @param deadline 最后期限
     * @param approveMax 全部批准
     * @param v v
     * @param r r
     * @param s s
     * @return amountA   数量A
     * @return amountB   数量B

1. 计算TokenA,TokenB的CREATE2地址，而无需进行任何外部调用
2. 如果全部批准,value值等于最大uint256,否则等于流动性
3. 调用pair合约的许可方法(调用账户,当前合约地址,数值,最后期限,v,r,s)
4. (数量A,数量B) = 移除流动性(tokenA地址,tokenB地址,流动性数量,最小数量A,最小数量B,to地址,最后期限)

### removeLiquidityETHWithPermit 带签名移除ETH流动性方法
     * @dev 带签名移除ETH流动性
     * @param token token地址
     * @param liquidity 流动性数量
     * @param amountTokenMin token最小数量
     * @param amountETHMin ETH最小数量
     * @param to to地址
     * @param deadline 最后期限
     * @param approveMax 全部批准
     * @param v v
     * @param r r
     * @param s s
     * @return amountToken   token数量
     * @return amountETH   ETH数量

1. 计算TokenA,TokenB的CREATE2地址，而无需进行任何外部调用
2. 如果全部批准,value值等于最大uint256,否则等于流动性
3. 调用pair合约的许可方法(调用账户,当前合约地址,数值,最后期限,v,r,s)
4. (token数量,ETH数量) = 移除ETH流动性(token地址,流动性数量,token最小数量,ETH最小数量,to地址,最后期限)

## 交换方法
- 基础的交换方法有6种
    1. 根据精确的token交换尽量多的token
    2. 使用尽量少的token交换精确的token
    3. 根据精确的ETH交换尽量多的token
    4. 使用尽量少的token交换精确的ETH
    5. 根据精确的token交换尽量多的ETH
    6. 使用尽量少的ETH交换精确的token
- 交换方法调用时,可以传入两个token的交易对,或者传入多个token的路径地址数组
- 多个token的路径地址数组中,每前后两个token地址必须是一个已经配对的交易对
- 交换方法会遍历路径数组,将每两个交易对排序后调用交易对的pair合约的交换方法进行交易
- 除此之外交换方法还有3种支持收税的交换方法
    1. 支持收税的根据精确的token交换尽量多的token
    2. 支持收税的根据精确的ETH交换尽量多的token
    3. 支持收税的根据精确的token交换尽量多的ETH

### _swap 私有交换方法
     * @dev 私有交换
     * @param amounts 数额数组
     * @param path 路径
     * @param _to to地址

1. 遍历`路径数组`
2. (输入地址,输出地址) = (当前地址,下一个地址)
3. token0 = 排序(输入地址,输出地址)
3. 输出数量 = 数额数组下一个数额
4. (输出数额0,输出数额1) = 输入地址==token0 ? (0,输出数额) : (输出数额,0)
5. to地址 = i<路径长度-2 ? (输出地址,路径下下个地址)的pair合约地址 : to地址
6. 调用(输入地址,输出地址)的`pair合约`地址的`交换`方法(输出数额0,输出数额1,to地址,0x00)

### swapExactTokensForTokens 根据精确的token交换尽量多的token
     * @dev 根据精确的token交换尽量多的token
     * @param amountIn 精确输入数额
     * @param amountOutMin 最小输出数额
     * @param path 路径数组
     * @param to to地址
     * @param deadline 最后期限
     * @return amounts[]  数额数组

1. 数额数组 ≈ 遍历路径数组((精确输入数额 * 储备量Out) / (储备量In * 1000 + 输入数额))
2. 确认数额数组最后一个元素>=最小最小输出数额
3. 将数量为数额数组[0]的路径[0]的token从调用者账户发送到路径0,1的pair合约
4. 私有交换(数额数组,路径数组,to地址)

### swapTokensForExactTokens 使用尽量少的token交换精确的token
     * @dev 使用尽量少的token交换精确的token
     * @param amountOut 精确输出数额
     * @param amountInMax 最大输入数额
     * @param path 路径数组
     * @param to to地址
     * @param deadline 最后期限
     * @return amounts[]  数额数组

1. 数额数组 ≈ 遍历路径数组((储备量In * 储备量Out * 1000) / (储备量Out - 输出数额 * 997) + 1)
2. 确认数额数组第一个元素<=最大输入数额
3. 将数量为数额数组[0]的路径[0]的token从调用者账户发送到路径0,1的pair合约
4. 私有交换(数额数组,路径数组,to地址)

### swapExactETHForTokens 根据精确的ETH交换尽量多的token
     * @dev 根据精确的ETH交换尽量多的token
     * @param amountOutMin 最小输出数额
     * @param path 路径数组
     * @param to to地址
     * @param deadline 最后期限
     * @return amounts[]  数额数组

1. 确认路径第一个地址为WETH
2. 数额数组 ≈ 遍历路径数组((精确输入数额 * 储备量Out) / (储备量In * 1000 + msg.value))
3. 确认数额数组最后一个元素>=最小输出数额
4. 将数额数组[0]的数额存款ETH到WETH合约
5. 断言将数额数组[0]的数额的WETH发送到路径(0,1)的pair合约地址
6. 私有交换(数额数组,路径数组,to地址)

### swapTokensForExactETH 使用尽量少的token交换精确的ETH
     * @param amountOut 精确输出数额
     * @param amountInMax 最大输入数额
     * @param path 路径数组
     * @param to to地址
     * @param deadline 最后期限
     * @return amounts[]  数额数组

1. 确认路径最后一个地址为WETH
2. 数额数组 ≈ 遍历路径数组((储备量In * 储备量Out * 1000) / (储备量Out - 输出数额 * 997) + 1)
3. 确认数额数组第一个元素<=最大输入数额
4. 将数量为数额数组[0]的路径[0]的token从调用者账户发送到路径0,1的pair合约
5. 私有交换(数额数组,路径数组,to地址)
6. 从WETH合约提款数额数组最后一个数值的ETH
7. 将数额数组最后一个数值的ETH发送到to地址

### swapExactTokensForETH 根据精确的token交换尽量多的ETH
     * @dev 根据精确的token交换尽量多的ETH
     * @param amountIn 精确输入数额
     * @param amountOutMin 最小输出数额
     * @param path 路径数组
     * @param to to地址
     * @param deadline 最后期限
     * @return amounts[]  数额数组

1. 确认路径最后一个地址为WETH
2. 数额数组 ≈ 遍历路径数组((精确输入数额 * 储备量Out) / (储备量In * 1000 + 输入数额))
3. 确认数额数组最后一个元素>=最小输出数额
4. 将数量为数额数组[0]的路径[0]的token从调用者账户发送到路径0,1的pair合约
5. 私有交换(数额数组,路径数组,当前合约地址)
6. 从WETH合约提款数额数组最后一个数值的ETH
7. 将数额数组最后一个数值的ETH发送到to地址

### swapETHForExactTokens 使用尽量少的ETH交换精确的token
     * @dev 使用尽量少的ETH交换精确的token
     * @param amountOut 精确输出数额
     * @param path 路径数组
     * @param to to地址
     * @param deadline 最后期限
     * @return amounts[]  数额数组

1. 确认路径第一个地址为WETH
2. 数额数组 ≈ 遍历路径数组((储备量In * 储备量Out * 1000) / (储备量Out - 输出数额 * 997) + 1)
3. 确认数额数组第一个元素<=msg.value
4. 将数额数组[0]的数额存款ETH到WETH合约
5. 断言将数额数组[0]的数额的WETH发送到路径(0,1)的pair合约地址
6. 私有交换(数额数组,路径数组,to地址)
7. 如果`收到的主币数量`>`数额数组[0]` 则返还`收到的主币数量`-`数额数组[0]`

### _swapSupportingFeeOnTransferTokens 支持收税的私有交换
     * @dev 支持收税的私有交换
     * @notice 要求初始金额已经发送到第一对
     * @param path 路径数组
     * @param _to to地址

1. 遍历`路径数组`
2. (输入地址,输出地址) = (当前地址,下一个地址)
3. token0 = 排序(输入地址,输出地址)
4. pair地址 = (输入地址,输出地址)
5. 初始化输入数值,输出数值
6. 获取储备_reserve0,_reserve1
7. 排序(储备量In,储备量Out)
8. 输入数额 = pair地址在token合约的余额 - 储备量In
9. 输出数额 = (输入数额 * 储备量Out) / (储备量In * 1000 + 输入数额)
10. (输出数额0,输出数额1) = 输入地址 == token0 ? (0,输出数额0) : (输出数额0,0)
11. to地址 = 当前循环到倒数第二 ? pair地址(输出地址,路径最后一个地址) : _to地址
12. 交换(输出数额0,输出数额1,to地址,0x00)

### swapExactTokensForTokensSupportingFeeOnTransferTokens 支持收税的根据精确的token交换尽量多的token
     * @dev 支持收税的根据精确的token交换尽量多的token
     * @param amountIn 精确输入数额
     * @param amountOutMin 最小输出数额
     * @param path 路径数组
     * @param to to地址
     * @param deadline 最后期限
     
1. 将数量为数额数组[0]的路径[0]的token从调用者账户发送到路径0,1的pair合约
2. 记录to地址在路径数组最后一个token地址的余额
3. 支持收税的私有交换(路径数组,to地址)
4. 确认to地址在路径数组最后一个token地址的当前余额 - 之前的余额 >= 最小输出数额

### swapExactETHForTokensSupportingFeeOnTransferTokens 支持收税的根据精确的ETH交换尽量多的token
     * @dev 支持收税的根据精确的ETH交换尽量多的token
     * @param amountOutMin 最小输出数额
     * @param path 路径数组
     * @param to to地址
     * @param deadline 最后期限

1. 确认路径第一个地址为WETH
2. 输入数额为msg.value
3. 将输入数额存款ETH到WETH合约
4. 断言将输入数额的WETH发送到路径(0,1)的pair合约地址
5. 记录to地址在路径数组最后一个token地址的余额
6. 支持收税的私有交换(路径数组,to地址)
7. 确认to地址在路径数组最后一个token地址的当前余额 - 之前的余额 >= 最小输出数额

### swapExactTokensForETHSupportingFeeOnTransferTokens 支持收税的根据精确的token交换尽量多的ETH
     * @dev 支持收税的根据精确的token交换尽量多的ETH
     * @param amountIn 精确输入数额
     * @param amountOutMin 最小输出数额
     * @param path 路径数组
     * @param to to地址
     * @param deadline 最后期限

1. 确认路径最后一个地址为WETH
2. 将数量为数额数组[0]的路径[0]的token从调用者账户发送到路径0,1的pair合约
3. 支持收税的私有交换(路径数组,当前合约地址)
4. 输出数额 = 当前合约地址在WETH的余额
5. 确认输出数额 >= 最小输出数额
6. 从WETH合约提款输出数额
7. 将输出数额的ETH发送到to地址

