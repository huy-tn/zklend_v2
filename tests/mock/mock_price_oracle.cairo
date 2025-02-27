#[starknet::contract]
pub mod MockPriceOracle {
    use starknet::ContractAddress;
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};

    // use zeroable::Zeroable;
    use core::num::traits::Zero;

    use zklend_v2::interfaces::{IPriceOracle, PriceWithUpdateTime};

    use super::super::IMockPriceOracle;

    #[storage]
    struct Storage {
        prices: Map::<ContractAddress, PriceData>
    }

    #[derive(Drop, starknet::Store)]
    struct PriceData {
        price: felt252,
        update_time: felt252
    }

    #[abi(embed_v0)]
    impl IPriceOracleImpl of IPriceOracle<ContractState> {
        fn get_price(self: @ContractState, token: ContractAddress) -> felt252 {
            let data = self.prices.read(token);
            assert(!data.price.is_zero(), 'MOCK_ORACLE_PRICE_NOT_SET');
            data.price
        }

        fn get_price_with_time(
            self: @ContractState, token: ContractAddress
        ) -> PriceWithUpdateTime {
            let data = self.prices.read(token);
            assert(!data.price.is_zero(), 'MOCK_ORACLE_PRICE_NOT_SET');
            return PriceWithUpdateTime { price: data.price, update_time: data.update_time };
        }
    }

    #[abi(embed_v0)]
    impl IMockPriceOracleImpl of IMockPriceOracle<ContractState> {
        fn set_price(
            ref self: ContractState, token: ContractAddress, price: felt252, update_time: felt252
        ) {
            self.prices.write(token, PriceData { price, update_time });
        }
    }
}
