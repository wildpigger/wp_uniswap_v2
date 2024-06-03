pragma solidity >=0.5.0;

// 定义 IUniswapV2ERC20 接口，用于描述 ERC-20 兼容代币合约的标准接口
interface IUniswapV2ERC20 {
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
}
