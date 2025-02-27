use starknet::ContractAddress;

use zklend_v2::interfaces::{
    IInterestRateModelDispatcher, IMarketDispatcher, IPriceOracleSourceDispatcher,
    ITestContractDispatcher, IZTokenDispatcher,
};
use zklend_v2::irms::default_interest_rate_model::DefaultInterestRateModel;

use super::mock::{
    IAccountDispatcher, IERC20Dispatcher, IFlashLoanHandlerDispatcher, IMockMarketDispatcher,
    IMockPriceOracleDispatcher,
};

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

// pub fn deploy_account(salt: felt252) -> IAccountDispatcher {
//     let (contract_address, _) = deploy_syscall(
//         mock::account::Account::TEST_CLASS_HASH.try_into().unwrap(),
//         salt,
//         array![].span(),
//         false
//     )
//         .unwrap();

//     IAccountDispatcher { contract_address }
// }

// Currently, salt is not used
pub fn deploy_account(salt: felt252) -> IAccountDispatcher {
    let contract = declare("Account").unwrap().contract_class();
    let calldata = array![];
    let (contract_address, _) = contract.deploy(@calldata).unwrap();

    IAccountDispatcher { contract_address }
}

pub fn deploy_erc20(
    name: felt252, symbol: felt252, decimals: u8, initial_supply: u256, recipient: ContractAddress,
) -> IERC20Dispatcher {
    let contract = declare("ERC20").unwrap().contract_class();
    let mut calldata = array![
        name,
        symbol,
        decimals.into(),
        initial_supply.low.into(),
        initial_supply.high.into(),
        recipient.into(),
    ];

    let (contract_address, _) = contract.deploy(@calldata).unwrap();

    IERC20Dispatcher { contract_address }
}

pub fn deploy_mock_price_oracle() -> IMockPriceOracleDispatcher {
    let contract = declare("MockPriceOracle").unwrap().contract_class();
    let mut calldata = array![];

    let (contract_address, _) = contract.deploy(@calldata).unwrap();

    IMockPriceOracleDispatcher { contract_address }
}

pub fn deploy_mock_market() -> IMockMarketDispatcher {
    let contract = declare("MockMarket").unwrap().contract_class();
    let mut calldata = array![];

    let (contract_address, _) = contract.deploy(@calldata).unwrap();

    IMockMarketDispatcher { contract_address }
}

pub fn deploy_flash_loan_handler() -> IFlashLoanHandlerDispatcher {
    let contract = declare("FlashLoanHandler").unwrap().contract_class();
    let mut calldata = array![];

    let (contract_address, _) = contract.deploy(@calldata).unwrap();

    IFlashLoanHandlerDispatcher { contract_address }
}

pub fn deploy_default_interest_rate_model(
    slope_0: felt252, slope_1: felt252, y_intercept: felt252, optimal_rate: felt252,
) -> IInterestRateModelDispatcher {
    let contract = declare("DefaultInterestRateModel").unwrap().contract_class();
    let calldata = array![slope_0, slope_1, y_intercept, optimal_rate];
    let (contract_address, _) = contract.deploy(@calldata).unwrap();

    IInterestRateModelDispatcher { contract_address }
}

pub fn deploy_z_token(
    owner: ContractAddress,
    market: ContractAddress,
    underlying: ContractAddress,
    name: felt252,
    symbol: felt252,
    decimals: felt252,
) -> IZTokenDispatcher {
    let contract = declare("ZToken").unwrap().contract_class();
    let calldata = array![owner.into(), market.into(), underlying.into(), name, symbol, decimals];
    let (contract_address, _) = contract.deploy(@calldata).unwrap();

    IZTokenDispatcher { contract_address }
}

pub fn deploy_market(owner: ContractAddress, oracle: ContractAddress) -> IMarketDispatcher {
    let contract = declare("Market").unwrap().contract_class();
    let calldata = array![owner.into(), oracle.into()];
    let (contract_address, _) = contract.deploy(@calldata).unwrap();

    IMarketDispatcher { contract_address }
}
