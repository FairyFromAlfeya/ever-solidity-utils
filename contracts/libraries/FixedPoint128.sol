pragma ton-solidity >= 0.57.1;

/// @title FP128 Utility
/// @dev Range: [0, 2 ** 128 - 1]. Resolution: 1 / 2 ** 128
library FixedPoint128 {
    // @dev Multiplier to transform an integer to FP128 format
    uint constant FIXED_POINT_128_MULTIPLIER = 2 ** 128;

    /// @notice Transforms an integer to FP128 format
    /// @param _a Number to transform
    /// @return uint Same number in FP128 representation
    function encode(uint128 _a) internal returns (uint) {
        return uint(_a) * FIXED_POINT_128_MULTIPLIER;
    }

    /// @notice Transforms numerator and denominator to number in FP128 format
    /// @dev A denominator can not be zero and must be checked before
    /// @param _numerator Numerator of the number
    /// @param _denominator Denominator of the number
    /// @return uint Number in FP128 representation
    function encodeFromNumeratorAndDenominator(
        uint128 _numerator,
        uint128 _denominator
    ) internal returns (uint) {
        return div(encode(_numerator), _denominator);
    }

    /// @notice Divides FP128 number on other non-FP128
    /// @param _a FP128 number
    /// @param _b non-FP128 number
    /// @return uint Division result in FP128 representation
    function div(uint _a, uint128 _b) internal returns (uint) {
        return _a / uint(_b);
    }

    /// @notice Calculates expected amount by specified amount and rate
    /// @dev expected = amount * rate / FP128Multiplier
    /// @param _amount Amount of the first token
    /// @param _rate Price of the expected token
    /// @return uint128 Expected amount of the second token
    function calculateExpectedAmountByRate(
        uint128 _amount,
        uint _rate
    ) internal returns (uint128) {
        return uint128(
            math.muldiv(
                _amount,
                _rate,
                FIXED_POINT_128_MULTIPLIER
            )
        );
    }
}
