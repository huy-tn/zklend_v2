mod view;
mod external;
mod internal;
mod traits;
mod errors;

#[starknet::contract]
pub mod ZToken {
    use starknet::storage::Map;
    use starknet::{ClassHash, ContractAddress};

    use crate::interfaces::IZToken;

    use super::{external, view};

    #[storage]
    struct Storage {
        pub market: ContractAddress,
        pub underlying: ContractAddress,
        pub token_name: felt252,
        pub token_symbol: felt252,
        pub token_decimals: felt252,
        pub raw_total_supply: felt252,
        pub raw_balances: Map::<ContractAddress, felt252>,
        pub allowances: Map::<(ContractAddress, ContractAddress), felt252>,
        // This weird naming is to maintain backward compatibility with the Cairo 0 version
        pub Ownable_owner: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        Transfer: Transfer,
        Approval: Approval,
        RawTransfer: RawTransfer,
        EchoRawBalance: EchoRawBalance,
        ContractUpgraded: ContractUpgraded,
        OwnershipTransferred: OwnershipTransferred,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct Transfer {
        pub from: ContractAddress,
        pub to: ContractAddress,
        pub value: u256,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct Approval {
        pub owner: ContractAddress,
        pub spender: ContractAddress,
        pub value: u256,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct RawTransfer {
        pub from: ContractAddress,
        pub to: ContractAddress,
        pub raw_value: felt252,
        pub accumulator: felt252,
        pub face_value: felt252,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct EchoRawBalance {
        pub user: ContractAddress,
        pub raw_balance: felt252,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct ContractUpgraded {
        new_class_hash: ClassHash,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct OwnershipTransferred {
        pub previous_owner: ContractAddress,
        pub new_owner: ContractAddress,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        owner: ContractAddress,
        market: ContractAddress,
        underlying: ContractAddress,
        name: felt252,
        symbol: felt252,
        decimals: felt252,
    ) {
        external::initializer(ref self, owner, market, underlying, name, symbol, decimals)
    }

    #[abi(embed_v0)]
    impl IZTokenImpl of IZToken<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            view::name(self)
        }

        fn symbol(self: @ContractState) -> felt252 {
            view::symbol(self)
        }

        fn decimals(self: @ContractState) -> felt252 {
            view::decimals(self)
        }

        fn totalSupply(self: @ContractState) -> u256 {
            view::totalSupply(self)
        }

        fn felt_total_supply(self: @ContractState) -> felt252 {
            view::felt_total_supply(self)
        }

        fn balanceOf(self: @ContractState, account: ContractAddress) -> u256 {
            view::balanceOf(self, account)
        }

        fn felt_balance_of(self: @ContractState, account: ContractAddress) -> felt252 {
            view::felt_balance_of(self, account)
        }

        fn allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress,
        ) -> u256 {
            view::allowance(self, owner, spender)
        }

        fn felt_allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress,
        ) -> felt252 {
            view::felt_allowance(self, owner, spender)
        }

        fn underlying_token(self: @ContractState) -> ContractAddress {
            view::underlying_token(self)
        }

        fn get_raw_total_supply(self: @ContractState) -> felt252 {
            view::get_raw_total_supply(self)
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
            external::transfer(ref self, recipient, amount)
        }

        fn felt_transfer(
            ref self: ContractState, recipient: ContractAddress, amount: felt252,
        ) -> bool {
            external::felt_transfer(ref self, recipient, amount)
        }

        fn transferFrom(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256,
        ) -> bool {
            external::transferFrom(ref self, sender, recipient, amount)
        }

        fn felt_transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: felt252,
        ) -> bool {
            external::felt_transfer_from(ref self, sender, recipient, amount)
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
            external::approve(ref self, spender, amount)
        }

        fn felt_approve(
            ref self: ContractState, spender: ContractAddress, amount: felt252,
        ) -> bool {
            external::felt_approve(ref self, spender, amount)
        }

        fn transfer_all(ref self: ContractState, recipient: ContractAddress) -> felt252 {
            external::transfer_all(ref self, recipient)
        }

        fn echo_raw_balances(ref self: ContractState, mut users: Span<ContractAddress>) {
            external::echo_raw_balances(ref self, users)
        }

        // fn upgrade(ref self: ContractState, new_implementation: ClassHash) {
        //     external::upgrade(ref self, new_implementation)
        // }

        fn mint(ref self: ContractState, to: ContractAddress, amount: felt252) -> bool {
            external::mint(ref self, to, amount)
        }

        fn burn(ref self: ContractState, user: ContractAddress, amount: felt252) {
            external::burn(ref self, user, amount)
        }

        fn burn_all(ref self: ContractState, user: ContractAddress) -> felt252 {
            external::burn_all(ref self, user)
        }

        fn move(
            ref self: ContractState,
            from_account: ContractAddress,
            to_account: ContractAddress,
            amount: felt252,
        ) {
            external::move(ref self, from_account, to_account, amount)
        }

        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            external::transfer_ownership(ref self, new_owner)
        }

        fn renounce_ownership(ref self: ContractState) {
            external::renounce_ownership(ref self)
        }
    }
}
