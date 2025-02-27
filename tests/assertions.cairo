pub fn assert_approximatedly_equals(left: u256, right: u256, error: u256) {
    let abs = if left > right {
        left - right
    } else {
        right - left
    };
    assert(abs <= error, 'APPROXIMATE_EQUALITY_FAILED');
}
