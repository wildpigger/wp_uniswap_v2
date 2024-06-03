pragma solidity >=0.5.0;

// 定义 IUniswapV2Pair 接口，用于描述 Uniswap V2 交易对合约的标准接口
interface IUniswapV2Pair {
    // 事件：当调用 approve 函数时触发
    event Approval(address indexed owner, address indexed spender, uint value);
    // 事件：当调用 transfer 或 transferFrom 函数时触发
    event Transfer(address indexed from, address indexed to, uint value);

    // 获取代币名称
    function name() external pure returns (string memory);
    // 获取代币符号
    function symbol() external pure returns (string memory);
    // 获取代币小数位数
    function decimals() external pure returns (uint8);
    // 获取代币总供应量
    function totalSupply() external view returns (uint);
    // 获取某地址的代币余额
    // 参数：
    // - owner: 代币拥有者的地址
    function balanceOf(address owner) external view returns (uint);
    // 获取某地址的代币授权额度
    // 参数：
    // - owner: 代币拥有者的地址
    // - spender: 被授权者的地址
    function allowance(address owner, address spender) external view returns (uint);

    // 批准代币转移额度
    // 参数：
    // - spender: 被授权者的地址
    // - value: 授权额度
    function approve(address spender, uint value) external returns (bool);
    // 转移代币
    // 参数：
    // - to: 接收者的地址
    // - value: 转移的代币数量
    function transfer(address to, uint value) external returns (bool);
    // 从某地址转移代币
    // 参数：
    // - from: 发送者的地址
    // - to: 接收者的地址
    // - value: 转移的代币数量
    function transferFrom(address from, address to, uint value) external returns (bool);

    // 获取域分隔符，用于 EIP-712 签名
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    // 获取 PERMIT 类型哈希，用于 EIP-2612 签名
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    // 获取某地址的 nonce 值，用于 EIP-2612 签名
    // 参数：
    // - owner: 地址
    function nonces(address owner) external view returns (uint);

    // 执行 EIP-2612 签名授权
    // 参数：
    // - owner: 代币拥有者的地址
    // - spender: 被授权者的地址
    // - value: 授权额度
    // - deadline: 授权截止时间
    // - v: 签名参数 v
    // - r: 签名参数 r
    // - s: 签名参数 s
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    // 事件：当铸造流动性时触发
    event Mint(address indexed sender, uint amount0, uint amount1);
    // 事件：当销毁流动性时触发
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    // 事件：当进行交易交换时触发
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    // 事件：当同步储备量时触发
    event Sync(uint112 reserve0, uint112 reserve1);

    // 获取最小流动性
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    // 获取工厂合约地址
    function factory() external view returns (address);
    // 获取第一个代币的地址
    function token0() external view returns (address);
    // 获取第二个代币的地址
    function token1() external view returns (address);
    // 获取储备量信息
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    // 获取第一个代币累计价格
    function price0CumulativeLast() external view returns (uint);
    // 获取第二个代币累计价格
    function price1CumulativeLast() external view returns (uint);
    // 获取上一次的 k 值
    function kLast() external view returns (uint);

    // 铸造流动性代币
    // 参数：
    // - to: 接收流动性代币的地址
    function mint(address to) external returns (uint liquidity);
    // 销毁流动性代币
    // 参数：
    // - to: 接收代币的地址
    function burn(address to) external returns (uint amount0, uint amount1);
    // 进行交易交换
    // 参数：
    // - amount0Out: 第一个代币的输出数量
    // - amount1Out: 第二个代币的输出数量
    // - to: 接收代币的地址
    // - data: 交易数据
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    // 将多余的代币转移给指定地址
    // 参数：
    // - to: 接收多余代币的地址
    function skim(address to) external;
    // 同步储备量
    function sync() external;

    // 初始化交易对
    // 参数：
    // - token0: 第一个代币的地址
    // - token1: 第二个代币的地址
    function initialize(address token0, address token1) external;
}
