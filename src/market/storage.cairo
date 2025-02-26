use starknet::ContractAddress;
use core::result::ResultTrait;

use crate::interfaces::MarketReserveData;
use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};

use super::Market as contract;
use contract::ContractState;


#[derive(Drop)]
pub struct StorageBatch1 {
    interest_rate_model: ContractAddress,
    raw_total_debt: felt252,
}

#[derive(Drop)]
pub struct StorageBatch2 {
    decimals: felt252,
    z_token_address: ContractAddress,
    collateral_factor: felt252,
}

#[derive(Drop)]
struct StorageBatch3 {
    reserve_factor: felt252,
    last_update_timestamp: felt252,
    lending_accumulator: felt252,
    current_lending_rate: felt252,
}

#[derive(Drop)]
pub struct StorageBatch4 {
    last_update_timestamp: felt252,
    debt_accumulator: felt252,
    current_borrowing_rate: felt252,
}

#[derive(Drop)]
pub struct StorageBatch5 {
    z_token_address: ContractAddress,
    reserve_factor: felt252,
    last_update_timestamp: felt252,
    lending_accumulator: felt252,
    current_lending_rate: felt252,
}

#[derive(Drop)]
pub struct StorageBatch6 {
    z_token_address: ContractAddress,
    reserve_factor: felt252,
    lending_accumulator: felt252,
    debt_accumulator: felt252,
    raw_total_debt: felt252,
}
