use core::num::traits::Zero;

use starknet::ContractAddress;
use starknet::event::EventEmitter;

use crate::interfaces::{
    IERC20Dispatcher, IERC20DispatcherTrait, IZTokenDispatcher, IZTokenDispatcherTrait,
    MarketReserveData,
};
use crate::libraries::{ownable, reentrancy_guard, safe_decimal_math};

use super::traits::{MarketOwnable, MarketReentrancyGuard};
use super::{errors, internal};

use super::Market as contract;
use super::UpdatedAccumulators;

use contract::ContractState;

use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
use starknet::storage::{StorageMapReadAccess, StorageMapWriteAccess};

pub fn initializer(ref self: ContractState, owner: ContractAddress, oracle: ContractAddress) {
    // Temporarily disable these check
    assert(owner.is_non_zero(), errors::ZERO_ADDRESS);
    assert(oracle.is_non_zero(), errors::ZERO_ADDRESS);

    ownable::initializer(ref self, owner);
    self.oracle.write(oracle);
}

pub fn deposit(ref self: ContractState, token: ContractAddress, amount: felt252) {
    reentrancy_guard::start(ref self);
    internal::deposit(ref self, token, amount);
    reentrancy_guard::end(ref self);
}

pub fn withdraw(ref self: ContractState, token: ContractAddress, amount: felt252) {
    reentrancy_guard::start(ref self);
    internal::withdraw(ref self, token, amount);
    reentrancy_guard::end(ref self);
}

pub fn withdraw_all(ref self: ContractState, token: ContractAddress) {
    reentrancy_guard::start(ref self);
    internal::withdraw_all(ref self, token);
    reentrancy_guard::end(ref self);
}

pub fn borrow(ref self: ContractState, token: ContractAddress, amount: felt252) {
    reentrancy_guard::start(ref self);
    internal::borrow(ref self, token, amount);
    reentrancy_guard::end(ref self);
}

pub fn repay(ref self: ContractState, token: ContractAddress, amount: felt252) {
    reentrancy_guard::start(ref self);
    internal::repay(ref self, token, amount);
    reentrancy_guard::end(ref self);
}

pub fn repay_for(
    ref self: ContractState, token: ContractAddress, amount: felt252, beneficiary: ContractAddress,
) {
    reentrancy_guard::start(ref self);
    internal::repay_for(ref self, token, amount, beneficiary);
    reentrancy_guard::end(ref self);
}

pub fn repay_all(ref self: ContractState, token: ContractAddress) {
    reentrancy_guard::start(ref self);
    internal::repay_all(ref self, token);
    reentrancy_guard::end(ref self);
}

pub fn enable_collateral(ref self: ContractState, token: ContractAddress) {
    reentrancy_guard::start(ref self);
    internal::enable_collateral(ref self, token);
    reentrancy_guard::end(ref self);
}

pub fn disable_collateral(ref self: ContractState, token: ContractAddress) {
    reentrancy_guard::start(ref self);
    internal::disable_collateral(ref self, token);
    reentrancy_guard::end(ref self);
}

/// With the current design, liquidators are responsible for calculating the maximum amount allowed.
/// We simply check collteralization factor is below one after liquidation.
/// TODO: calculate max amount on-chain because compute is cheap on StarkNet.
pub fn liquidate(
    ref self: ContractState,
    user: ContractAddress,
    debt_token: ContractAddress,
    amount: felt252,
    collateral_token: ContractAddress,
) {
    reentrancy_guard::start(ref self);
    internal::liquidate(ref self, user, debt_token, amount, collateral_token);
    reentrancy_guard::end(ref self);
}

pub fn flash_loan(
    ref self: ContractState,
    receiver: ContractAddress,
    token: ContractAddress,
    amount: felt252,
    calldata: Span::<felt252>,
) {
    reentrancy_guard::start(ref self);
    internal::flash_loan(ref self, receiver, token, amount, calldata);
    reentrancy_guard::end(ref self);
}

// pub fn upgrade(ref self: ContractState, new_implementation: ClassHash) {
//     ownable::assert_only_owner(@self);
//     replace_class_syscall(new_implementation).unwrap_syscall();

//     self
//         .emit(
//             contract::Event::ContractUpgraded(
//                 contract::ContractUpgraded { new_class_hash: new_implementation }
//             )
//         );
// }

pub fn add_reserve(
    ref self: ContractState,
    token: ContractAddress,
    z_token: ContractAddress,
    interest_rate_model: ContractAddress,
    collateral_factor: felt252,
    borrow_factor: felt252,
    reserve_factor: felt252,
    flash_loan_fee: felt252,
    liquidation_bonus: felt252,
) {
    ownable::assert_only_owner(@self);

    assert(token.is_non_zero(), errors::ZERO_ADDRESS);
    assert(z_token.is_non_zero(), errors::ZERO_ADDRESS);
    assert(interest_rate_model.is_non_zero(), errors::ZERO_ADDRESS);

    let existing_reserve_z_token = internal::read_z_token_address(@self, token);
    assert(existing_reserve_z_token.is_zero(), errors::RESERVE_ALREADY_EXISTS);

    // Checks collateral_factor range
    assert(
        Into::<_, u256>::into(collateral_factor) <= safe_decimal_math::SCALE_U256,
        errors::COLLATERAL_FACTOR_RANGE,
    );

    // Checks borrow_factor range
    assert(
        Into::<_, u256>::into(borrow_factor) <= safe_decimal_math::SCALE_U256,
        errors::BORROW_FACTOR_RANGE,
    );

    // Checks reserve_factor range
    assert(
        Into::<_, u256>::into(reserve_factor) <= safe_decimal_math::SCALE_U256,
        errors::RESERVE_FACTOR_RANGE,
    );

    // There's no need to limit `flash_loan_fee` range as it's charged on top of the loan amount.

    let decimals = IERC20Dispatcher { contract_address: token }.decimals();
    let z_token_decimals = IERC20Dispatcher { contract_address: z_token }.decimals();
    assert(decimals == z_token_decimals, errors::TOKEN_DECIMALS_MISMATCH);

    // Checks underlying token of the Z token contract
    let z_token_underlying = IZTokenDispatcher { contract_address: z_token }.underlying_token();
    assert(z_token_underlying == token, errors::UNDERLYING_TOKEN_MISMATCH);

    let new_reserve = MarketReserveData {
        enabled: true,
        decimals,
        z_token_address: z_token,
        interest_rate_model,
        collateral_factor,
        borrow_factor,
        reserve_factor,
        last_update_timestamp: 0,
        lending_accumulator: safe_decimal_math::SCALE,
        debt_accumulator: safe_decimal_math::SCALE,
        current_lending_rate: 0,
        current_borrowing_rate: 0,
        raw_total_debt: 0,
        flash_loan_fee,
        liquidation_bonus,
        debt_limit: 0,
        deposit_limit: 0,
    };

    // use core::starknet::storage::{ Mutable, StoragePointerWriteAccess};

    self.reserves.write(token, new_reserve);

    self
        .emit(
            contract::Event::NewReserve(
                contract::NewReserve {
                    token,
                    z_token,
                    decimals,
                    interest_rate_model,
                    collateral_factor,
                    borrow_factor,
                    reserve_factor,
                    flash_loan_fee,
                    liquidation_bonus,
                },
            ),
        );

    self
        .emit(
            contract::Event::AccumulatorsSync(
                contract::AccumulatorsSync {
                    token,
                    lending_accumulator: safe_decimal_math::SCALE,
                    debt_accumulator: safe_decimal_math::SCALE,
                },
            ),
        );
    self
        .emit(
            contract::Event::InterestRatesSync(
                contract::InterestRatesSync { token, lending_rate: 0, borrowing_rate: 0 },
            ),
        );

    let current_reserve_count = self.reserve_count.read();
    let new_reserve_count = current_reserve_count + 1;
    self.reserve_count.write(new_reserve_count);
    self.reserve_tokens.write(current_reserve_count, token);
    self.reserve_indices.write(token, current_reserve_count);

    // We can only have up to 125 reserves due to the use of bitmap for user collateral usage
    // and debt flags until we will change to use more than 1 felt for that.
    assert(Into::<_, u256>::into(new_reserve_count) <= 125, errors::TOO_MANY_RESERVES);
}

pub fn set_treasury(ref self: ContractState, new_treasury: ContractAddress) {
    ownable::assert_only_owner(@self);

    self.treasury.write(new_treasury);
    self.emit(contract::Event::TreasuryUpdate(contract::TreasuryUpdate { new_treasury }));
}

pub fn set_interest_rate_model(
    ref self: ContractState, token: ContractAddress, interest_rate_model: ContractAddress,
) {
    ownable::assert_only_owner(@self);

    assert(interest_rate_model.is_non_zero(), errors::ZERO_ADDRESS);

    internal::assert_reserve_exists(@self, token);

    // Settles interest payments up until this point to prevent retrospective changes.
    let UpdatedAccumulators {
        debt_accumulator: updated_debt_accumulator, ..,
    } = internal::update_accumulators(ref self, token);

    internal::write_interest_rate_model(ref self, token, interest_rate_model);
    self
        .emit(
            contract::Event::InterestRateModelUpdate(
                contract::InterestRateModelUpdate { token, interest_rate_model },
            ),
        );

    internal::update_rates_and_raw_total_debt(
        ref self,
        token, // token
        updated_debt_accumulator, // updated_debt_accumulator
        false, // is_delta_reserve_balance_negative
        0, // abs_delta_reserve_balance
        false, // is_delta_raw_total_debt_negative
        0 // abs_delta_raw_total_debt
    );
}

pub fn set_collateral_factor(
    ref self: ContractState, token: ContractAddress, collateral_factor: felt252,
) {
    ownable::assert_only_owner(@self);

    // Checks collateral_factor range
    assert(
        Into::<_, u256>::into(collateral_factor) <= safe_decimal_math::SCALE_U256,
        errors::COLLATERAL_FACTOR_RANGE,
    );

    internal::assert_reserve_exists(@self, token);
    internal::write_collateral_factor(ref self, token, collateral_factor);
    self
        .emit(
            contract::Event::CollateralFactorUpdate(
                contract::CollateralFactorUpdate { token, collateral_factor },
            ),
        );
}

pub fn set_borrow_factor(ref self: ContractState, token: ContractAddress, borrow_factor: felt252) {
    ownable::assert_only_owner(@self);

    // Checks borrow_factor range
    assert(
        Into::<_, u256>::into(borrow_factor) <= safe_decimal_math::SCALE_U256,
        errors::BORROW_FACTOR_RANGE,
    );

    internal::assert_reserve_exists(@self, token);
    internal::write_borrow_factor(ref self, token, borrow_factor);
    self
        .emit(
            contract::Event::BorrowFactorUpdate(
                contract::BorrowFactorUpdate { token, borrow_factor },
            ),
        );
}

pub fn set_reserve_factor(
    ref self: ContractState, token: ContractAddress, reserve_factor: felt252,
) {
    ownable::assert_only_owner(@self);

    // Checks reserve_factor range
    assert(
        Into::<_, u256>::into(reserve_factor) <= safe_decimal_math::SCALE_U256,
        errors::RESERVE_FACTOR_RANGE,
    );

    internal::assert_reserve_exists(@self, token);

    // Settles interest payments up until this point to prevent retrospective changes.
    let UpdatedAccumulators {
        debt_accumulator: updated_debt_accumulator, ..,
    } = internal::update_accumulators(ref self, token);
    internal::update_rates_and_raw_total_debt(
        ref self,
        token, // token
        updated_debt_accumulator, // updated_debt_accumulator
        false, // is_delta_reserve_balance_negative
        0, // abs_delta_reserve_balance
        false, // is_delta_raw_total_debt_negative
        0 // abs_delta_raw_total_debt
    );

    internal::write_reserve_factor(ref self, token, reserve_factor);
    self
        .emit(
            contract::Event::ReserveFactorUpdate(
                contract::ReserveFactorUpdate { token, reserve_factor },
            ),
        );
}

pub fn set_debt_limit(ref self: ContractState, token: ContractAddress, limit: felt252) {
    ownable::assert_only_owner(@self);

    internal::assert_reserve_exists(@self, token);
    internal::write_debt_limit(ref self, token, limit);
    self.emit(contract::Event::DebtLimitUpdate(contract::DebtLimitUpdate { token, limit }));
}

pub fn set_deposit_limit(ref self: ContractState, token: ContractAddress, limit: felt252) {
    ownable::assert_only_owner(@self);

    internal::assert_reserve_exists(@self, token);
    internal::write_deposit_limit(ref self, token, limit);
    self.emit(contract::Event::DepositLimitUpdate(contract::DepositLimitUpdate { token, limit }));
}

pub fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
    ownable::transfer_ownership(ref self, new_owner);
}

pub fn renounce_ownership(ref self: ContractState) {
    ownable::renounce_ownership(ref self);
}
