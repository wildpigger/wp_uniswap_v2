pragma solidity >=0.5.0;

// 定义一个ERC20标准的接口
interface IERC20 {
    // 定义授权事件，当owner授权spender使用value数量的代币时触发
    // 参数：
    // - owner: 授权人地址
    // - spender: 被授权人地址
    // - value: 授权的代币数量
    event Approval(address indexed owner, address indexed spender, uint value);

    // 定义转账事件，当from地址向to地址转账value数量的代币时触发
    // 参数：
    // - from: 转出代币的地址
    // - to: 接收代币的地址
    // - value: 转账的代币数量
    event Transfer(address indexed from, address indexed to, uint value);

    // 返回代币的名称
    function name() external view returns (string memory);

    // 返回代币的符号
    function symbol() external view returns (string memory);

    // 返回代币的精度，即小数点后有多少位
    function decimals() external view returns (uint8);

    // 返回代币的总供应量
    function totalSupply() external view returns (uint);

    // 返回指定地址的代币余额
    // 参数：
    // - owner: 要查询余额的地址
    function balanceOf(address owner) external view returns (uint);

    // 返回owner授权给spender使用的代币数量
    // 参数：
    // - owner: 授权人地址
    // - spender: 被授权人地址
    function allowance(address owner, address spender) external view returns (uint);

    // 授权spender可以使用value数量的代币
    // 参数：
    // - spender: 被授权使用代币的地址
    // - value: 授权的代币数量
    function approve(address spender, uint value) external returns (bool);

    // 将value数量的代币从调用者地址转账到to地址
    // 参数：
    // - to: 接收代币的地址
    // - value: 转账的代币数量
    function transfer(address to, uint value) external returns (bool);

    // 将value数量的代币从from地址转账到to地址，前提是调用者必须被授权使用from地址的代币
    // 参数：
    // - from: 转出代币的地址
    // - to: 接收代币的地址
    // - value: 转账的代币数量
    function transferFrom(address from, address to, uint value) external returns (bool);
}
