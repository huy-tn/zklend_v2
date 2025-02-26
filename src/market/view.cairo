// use traits::Into;
// use zeroable::Zeroable;

use core::num::traits::Zero;

use starknet::{ContractAddress, get_block_timestamp};

use crate::interfaces::{IZTokenDispatcher, IZTokenDispatcherTrait, MarketReserveData};
use crate::libraries::{safe_decimal_math, safe_math};

use super::internal;
// use super::storage::{ReservesStorageShortcuts, ReservesStorageShortcutsImpl};

use super::Market as contract;

use contract::ContractState;

use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
use starknet::storage::{StorageMapReadAccess, StorageMapWriteAccess};

const SECONDS_PER_YEAR: felt252 = 31536000;

pub fn get_reserve_data(self: @ContractState, token: ContractAddress) -> MarketReserveData {
    self.reserves.read(token)
}

pub fn get_lending_accumulator(self: @ContractState, token: ContractAddress) -> felt252 {
    internal::assert_reserve_enabled(self, token);
    let (
        reserve_reserve_factor,
        reserve_last_update_timestamp,
        reserve_lending_accumulator,
        reserve_current_lending_rate,
    ) =
        internal::read_for_get_lending_accumulator(
        self, token,
    );

    let block_timestamp: felt252 = get_block_timestamp().into();
    if reserve_last_update_timestamp == block_timestamp {
        // Accumulator already updated on the same block
        reserve_lending_accumulator
    } else {
        // Apply simple interest
        let time_diff = safe_math::sub(block_timestamp, reserve_last_update_timestamp);

        // Treats reserve factor as zero if treasury address is not set
        let treasury_addr = self.treasury.read();
        let effective_reserve_factor = if treasury_addr.is_zero() {
            0
        } else {
            reserve_reserve_factor
        };

        let one_minus_reserve_factor = safe_math::sub(
            safe_decimal_math::SCALE, effective_reserve_factor,
        );

        // New accumulator
        // (current_lending_rate * (1 - reserve_factor) * time_diff / SECONDS_PER_YEAR + 1) *
        // accumulator
        let temp_1 = safe_math::mul(reserve_current_lending_rate, time_diff);
        let temp_2 = safe_math::mul(temp_1, one_minus_reserve_factor);
        let temp_3 = safe_math::div(temp_2, SECONDS_PER_YEAR);
        let temp_4 = safe_math::div(temp_3, safe_decimal_math::SCALE);
        let temp_5 = safe_math::add(temp_4, safe_decimal_math::SCALE);
        let latest_accumulator = safe_decimal_math::mul(temp_5, reserve_lending_accumulator);

        latest_accumulator
    }
}

pub fn get_debt_accumulator(self: @ContractState, token: ContractAddress) -> felt252 {
    internal::assert_reserve_enabled(self, token);
    let (reserve_last_update_timestamp, reserve_debt_accumulator, reserve_current_borrowing_rate) =
        internal::read_for_get_debt_accumulator(
        self, token,
    );

    let block_timestamp: felt252 = get_block_timestamp().into();
    if (reserve_last_update_timestamp == block_timestamp) {
        // Accumulator already updated on the same block
        reserve_debt_accumulator
    } else {
        // Apply simple interest
        let time_diff = safe_math::sub(block_timestamp, reserve_last_update_timestamp);

        // (current_borrowing_rate * time_diff / SECONDS_PER_YEAR + 1) * accumulator
        let temp_1 = safe_math::mul(reserve_current_borrowing_rate, time_diff);
        let temp_2 = safe_math::div(temp_1, SECONDS_PER_YEAR);
        let temp_3 = safe_math::add(temp_2, safe_decimal_math::SCALE);
        let latest_accumulator = safe_decimal_math::mul(temp_3, reserve_debt_accumulator);

        latest_accumulator
    }
}

// WARN: this must be run BEFORE adjusting the accumulators (otherwise always returns 0)
pub fn get_pending_treasury_amount(self: @ContractState, token: ContractAddress) -> felt252 {
    internal::assert_reserve_enabled(self, token);
    let (
        reserve_z_token_address,
        reserve_reserve_factor,
        reserve_last_update_timestamp,
        reserve_lending_accumulator,
        reserve_current_lending_rate,
    ) =
        internal::read_for_get_pending_treasury_amount(
        self, token,
    );

    // Nothing for treasury if address set to zero
    let treasury_addr = self.treasury.read();
    if treasury_addr.is_zero() {
        return 0;
    }

    let block_timestamp: felt252 = get_block_timestamp().into();
    if reserve_last_update_timestamp == block_timestamp {
        // Treasury amount already settled on the same block
        0
    } else {
        // Apply simple interest
        let time_diff = safe_math::sub(block_timestamp, reserve_last_update_timestamp);

        let raw_supply = IZTokenDispatcher { contract_address: reserve_z_token_address }
            .get_raw_total_supply();

        // Amount to be paid to treasury (based on the adjusted accumulator)
        // (current_lending_rate * reserve_factor * time_diff / SECONDS_PER_YEAR) * accumulator *
        // raw_supply
        let temp_1 = safe_math::mul(reserve_current_lending_rate, time_diff);
        let temp_2 = safe_math::mul(temp_1, reserve_reserve_factor);
        let temp_3 = safe_math::div(temp_2, SECONDS_PER_YEAR);
        let temp_4 = safe_math::div(temp_3, safe_decimal_math::SCALE);
        let temp_5 = safe_decimal_math::mul(temp_4, reserve_lending_accumulator);
        let amount_to_treasury = safe_decimal_math::mul(raw_supply, temp_5);

        amount_to_treasury
    }
}

pub fn get_total_debt_for_token(self: @ContractState, token: ContractAddress) -> felt252 {
    internal::assert_reserve_enabled(self, token);
    let raw_total_debt = internal::read_raw_total_debt(self, token);

    let debt_accumulator = get_debt_accumulator(self, token);
    let scaled_up_debt = safe_decimal_math::mul(raw_total_debt, debt_accumulator);
    scaled_up_debt
}

pub fn get_user_debt_for_token(
    self: @ContractState, user: ContractAddress, token: ContractAddress,
) -> felt252 {
    let debt_accumulator = get_debt_accumulator(self, token);
    let raw_debt = self.raw_user_debts.read((user, token));

    let scaled_up_debt = safe_decimal_math::mul(raw_debt, debt_accumulator);
    scaled_up_debt
}

/// Returns a bitmap of user flags.
pub fn get_user_flags(self: @ContractState, user: ContractAddress) -> felt252 {
    self.user_flags.read(user)
}

pub fn is_user_undercollateralized(
    self: @ContractState, user: ContractAddress, apply_borrow_factor: bool,
) -> bool {
    let user_not_undercollateralized = internal::is_not_undercollateralized(
        self, user, apply_borrow_factor,
    );

    !user_not_undercollateralized
}

pub fn is_collateral_enabled(
    self: @ContractState, user: ContractAddress, token: ContractAddress,
) -> bool {
    internal::is_used_as_collateral(self, user, token)
}

pub fn user_has_debt(self: @ContractState, user: ContractAddress) -> bool {
    internal::user_has_debt(self, user)
}
