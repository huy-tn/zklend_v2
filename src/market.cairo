mod view;
mod external;
mod internal;
mod traits;
mod errors;
// mod storage;

struct UpdatedAccumulators {
    lending_accumulator: felt252,
    debt_accumulator: felt252,
}

#[starknet::contract]
pub mod Market {
    use starknet::{ClassHash, ContractAddress};


    // Hack to simulate the `crate` keyword
    // use super::super as crate;

    use zklend_v2::interfaces::{IMarket, MarketReserveData};

    use super::{external, view};

    use starknet::storage::Map;


    #[storage]
    struct Storage {
        pub oracle: ContractAddress,
        pub treasury: ContractAddress,
        pub reserves: Map::<ContractAddress, MarketReserveData>,
        pub reserve_count: felt252,
        // index -> token
        pub reserve_tokens: Map::<felt252, ContractAddress>,
        // token -> index
        pub reserve_indices: Map::<ContractAddress, felt252>,
        /// Bit 0: whether reserve #0 is used as collateral
        /// Bit 1: whether user has debt in reserve #0
        /// Bit 2: whether reserve #1 is used as collateral
        /// Bit 3: whether user has debt in reserve #1
        /// ...
        pub user_flags: Map::<ContractAddress, felt252>,
        // (user, token) -> debt
        pub raw_user_debts: Map::<(ContractAddress, ContractAddress), felt252>,
        // This weird naming is to maintain backward compatibility with the Cairo 0 version
        pub Ownable_owner: ContractAddress,
        // Used in `reentrancy_guard`
        pub entered: bool,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        NewReserve: NewReserve,
        TreasuryUpdate: TreasuryUpdate,
        AccumulatorsSync: AccumulatorsSync,
        InterestRatesSync: InterestRatesSync,
        InterestRateModelUpdate: InterestRateModelUpdate,
        CollateralFactorUpdate: CollateralFactorUpdate,
        BorrowFactorUpdate: BorrowFactorUpdate,
        ReserveFactorUpdate: ReserveFactorUpdate,
        DebtLimitUpdate: DebtLimitUpdate,
        DepositLimitUpdate: DepositLimitUpdate,
        Deposit: Deposit,
        Withdrawal: Withdrawal,
        Borrowing: Borrowing,
        Repayment: Repayment,
        Liquidation: Liquidation,
        FlashLoan: FlashLoan,
        CollateralEnabled: CollateralEnabled,
        CollateralDisabled: CollateralDisabled,
        ContractUpgraded: ContractUpgraded,
        OwnershipTransferred: OwnershipTransferred,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct NewReserve {
        pub token: ContractAddress,
        pub z_token: ContractAddress,
        pub decimals: felt252,
        pub interest_rate_model: ContractAddress,
        pub collateral_factor: felt252,
        pub borrow_factor: felt252,
        pub reserve_factor: felt252,
        pub flash_loan_fee: felt252,
        pub liquidation_bonus: felt252,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct TreasuryUpdate {
        pub new_treasury: ContractAddress,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct AccumulatorsSync {
        pub token: ContractAddress,
        pub lending_accumulator: felt252,
        pub debt_accumulator: felt252,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct InterestRatesSync {
        pub token: ContractAddress,
        pub lending_rate: felt252,
        pub borrowing_rate: felt252,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct InterestRateModelUpdate {
        pub token: ContractAddress,
        pub interest_rate_model: ContractAddress,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct CollateralFactorUpdate {
        pub token: ContractAddress,
        pub collateral_factor: felt252,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct BorrowFactorUpdate {
        pub token: ContractAddress,
        pub borrow_factor: felt252,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct ReserveFactorUpdate {
        pub token: ContractAddress,
        pub reserve_factor: felt252,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct DebtLimitUpdate {
        pub token: ContractAddress,
        pub limit: felt252,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct DepositLimitUpdate {
        pub token: ContractAddress,
        pub limit: felt252,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct Deposit {
        pub user: ContractAddress,
        pub token: ContractAddress,
        pub face_amount: felt252,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct Withdrawal {
        pub user: ContractAddress,
        pub token: ContractAddress,
        pub face_amount: felt252,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct Borrowing {
        pub user: ContractAddress,
        pub token: ContractAddress,
        pub raw_amount: felt252,
        pub face_amount: felt252,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct Repayment {
        pub repayer: ContractAddress,
        pub beneficiary: ContractAddress,
        pub token: ContractAddress,
        pub raw_amount: felt252,
        pub face_amount: felt252,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct Liquidation {
        pub liquidator: ContractAddress,
        pub user: ContractAddress,
        pub debt_token: ContractAddress,
        pub debt_raw_amount: felt252,
        pub debt_face_amount: felt252,
        pub collateral_token: ContractAddress,
        pub collateral_amount: felt252,
    }

    /// `fee` indicates the actual fee paid back, which could be higher than the minimum required.
    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct FlashLoan {
        pub initiator: ContractAddress,
        pub receiver: ContractAddress,
        pub token: ContractAddress,
        pub amount: felt252,
        pub fee: felt252,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct CollateralEnabled {
        pub user: ContractAddress,
        pub token: ContractAddress,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct CollateralDisabled {
        pub user: ContractAddress,
        pub token: ContractAddress,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct ContractUpgraded {
        pub new_class_hash: ClassHash,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct OwnershipTransferred {
        pub previous_owner: ContractAddress,
        pub new_owner: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress, oracle: ContractAddress) {
        external::initializer(ref self, owner, oracle);
        // self.oracle.write(oracle);
    }

    #[abi(embed_v0)]
    impl IMarketImpl of IMarket<ContractState> {
        fn get_reserve_data(self: @ContractState, token: ContractAddress) -> MarketReserveData {
            view::get_reserve_data(self, token)
        }

        fn get_lending_accumulator(self: @ContractState, token: ContractAddress) -> felt252 {
            view::get_lending_accumulator(self, token)
        }

        fn get_debt_accumulator(self: @ContractState, token: ContractAddress) -> felt252 {
            view::get_debt_accumulator(self, token)
        }
        // WARN: this must be run BEFORE adjusting the accumulators (otherwise always returns 0)
        fn get_pending_treasury_amount(self: @ContractState, token: ContractAddress) -> felt252 {
            view::get_pending_treasury_amount(self, token)
        }

        fn get_total_debt_for_token(self: @ContractState, token: ContractAddress) -> felt252 {
            view::get_total_debt_for_token(self, token)
        }

        fn get_user_debt_for_token(
            self: @ContractState, user: ContractAddress, token: ContractAddress,
        ) -> felt252 {
            view::get_user_debt_for_token(self, user, token)
        }

        /// Returns a bitmap of user flags.
        fn get_user_flags(self: @ContractState, user: ContractAddress) -> felt252 {
            view::get_user_flags(self, user)
        }

        fn is_user_undercollateralized(
            self: @ContractState, user: ContractAddress, apply_borrow_factor: bool,
        ) -> bool {
            view::is_user_undercollateralized(self, user, apply_borrow_factor)
        }

        fn is_collateral_enabled(
            self: @ContractState, user: ContractAddress, token: ContractAddress,
        ) -> bool {
            view::is_collateral_enabled(self, user, token)
        }

        fn user_has_debt(self: @ContractState, user: ContractAddress) -> bool {
            view::user_has_debt(self, user)
        }

        fn deposit(ref self: ContractState, token: ContractAddress, amount: felt252) {
            external::deposit(ref self, token, amount)
        }

        fn withdraw(ref self: ContractState, token: ContractAddress, amount: felt252) {
            external::withdraw(ref self, token, amount)
        }

        fn withdraw_all(ref self: ContractState, token: ContractAddress) {
            external::withdraw_all(ref self, token)
        }

        fn borrow(ref self: ContractState, token: ContractAddress, amount: felt252) {
            external::borrow(ref self, token, amount)
        }

        fn repay(ref self: ContractState, token: ContractAddress, amount: felt252) {
            external::repay(ref self, token, amount)
        }

        fn repay_for(
            ref self: ContractState,
            token: ContractAddress,
            amount: felt252,
            beneficiary: ContractAddress,
        ) {
            external::repay_for(ref self, token, amount, beneficiary)
        }

        fn repay_all(ref self: ContractState, token: ContractAddress) {
            external::repay_all(ref self, token)
        }

        fn enable_collateral(ref self: ContractState, token: ContractAddress) {
            external::enable_collateral(ref self, token)
        }

        fn disable_collateral(ref self: ContractState, token: ContractAddress) {
            external::disable_collateral(ref self, token)
        }

        /// With the current design, liquidators are responsible for calculating the maximum amount
        /// allowed.
        /// We simply check collteralization factor is below one after liquidation.
        /// TODO: calculate max amount on-chain because compute is cheap on StarkNet.
        fn liquidate(
            ref self: ContractState,
            user: ContractAddress,
            debt_token: ContractAddress,
            amount: felt252,
            collateral_token: ContractAddress,
        ) {
            external::liquidate(ref self, user, debt_token, amount, collateral_token)
        }

        fn flash_loan(
            ref self: ContractState,
            receiver: ContractAddress,
            token: ContractAddress,
            amount: felt252,
            calldata: Span::<felt252>,
        ) {
            external::flash_loan(ref self, receiver, token, amount, calldata)
        }

        // fn upgrade(ref self: ContractState, new_implementation: ClassHash) {
        //     external::upgrade(ref self, new_implementation)
        // }

        fn add_reserve(
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
            external::add_reserve(
                ref self,
                token,
                z_token,
                interest_rate_model,
                collateral_factor,
                borrow_factor,
                reserve_factor,
                flash_loan_fee,
                liquidation_bonus,
            )
        }

        fn set_treasury(ref self: ContractState, new_treasury: ContractAddress) {
            external::set_treasury(ref self, new_treasury)
        }

        fn set_interest_rate_model(
            ref self: ContractState, token: ContractAddress, interest_rate_model: ContractAddress,
        ) {
            external::set_interest_rate_model(ref self, token, interest_rate_model)
        }

        fn set_collateral_factor(
            ref self: ContractState, token: ContractAddress, collateral_factor: felt252,
        ) {
            external::set_collateral_factor(ref self, token, collateral_factor)
        }

        fn set_borrow_factor(
            ref self: ContractState, token: ContractAddress, borrow_factor: felt252,
        ) {
            external::set_borrow_factor(ref self, token, borrow_factor)
        }

        fn set_reserve_factor(
            ref self: ContractState, token: ContractAddress, reserve_factor: felt252,
        ) {
            external::set_reserve_factor(ref self, token, reserve_factor)
        }

        fn set_debt_limit(ref self: ContractState, token: ContractAddress, limit: felt252) {
            external::set_debt_limit(ref self, token, limit)
        }

        fn set_deposit_limit(ref self: ContractState, token: ContractAddress, limit: felt252) {
            external::set_deposit_limit(ref self, token, limit)
        }

        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            external::transfer_ownership(ref self, new_owner)
        }

        fn renounce_ownership(ref self: ContractState) {
            external::renounce_ownership(ref self)
        }
    }
    // #[abi(embed_v0)]
// impl ReservesStorageShortcutsImpl of ReservesStorageShortcuts<ContractState> {

    // }
}
