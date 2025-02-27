// This is a re-implementation of OpenZeppelin's Cairo 0 `ReentrancyGuard` library (v0.6.1):
//
// https://github.com/OpenZeppelin/cairo-contracts/blob/70cbd05ed24ccd147f24b18c638dbd6e7fea88bb/src/openzeppelin/security/reentrancyguard/library.cairo
//
// Not using their own Cairo 1 version because, as of this writing:
//
// 1. It's not officially released yet (v0.6.1 is still the latest release);
// 2. It's implemented as a contract instead of a library, so there seems to be no way to integrate
//    into our contract;

mod errors {
    pub const REENTRANT_CALL: felt252 = 'RG_REENTRANT_CALL';
}

/// This trait abstracts away the `reentrancy_guard` library's interaction with the parent contract.
pub trait ReentrancyGuard<T> {
    // Storage proxy
    fn read_entered(self: @T) -> bool;

    // Storage proxy
    fn write_entered(ref self: T, entered: bool);
}

pub fn start<T, impl TReentrancyGuard: ReentrancyGuard<T>, impl TDrop: Drop<T>>(ref self: T) {
    let has_entered = self.read_entered();
    assert(!has_entered, errors::REENTRANT_CALL);
    self.write_entered(true);
}

pub fn end<T, impl TReentrancyGuard: ReentrancyGuard<T>, impl TDrop: Drop<T>>(ref self: T) {
    self.write_entered(false);
}
