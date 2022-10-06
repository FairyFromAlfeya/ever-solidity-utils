pragma ton-solidity >= 0.57.1;

import "../../libraries/UtilityFlag.sol";
import "../../libraries/UtilityGas.sol";
import "../../libraries/FixedPoint128.sol";

import "../interfaces/ITWAPOracle.sol";
import "../interfaces/IOnObservationCallback.sol";
import "../interfaces/IOnRateCallback.sol";

import "../libraries/OracleErrors.sol";

/// @title TWAP-Oracle
/// @notice Stores, calculates, and provides prices for DEX pair
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract TWAPOracle is ITWAPOracle {
    /// @dev Historical data on prices
    mapping(uint32 => Point) internal _points;

    /// @dev A current count of points
    uint16 internal _length;

    /// @dev Oracle's options
    OracleOptions internal _options;

    /// @dev Only the pair's root can call a function with this modifier
    modifier onlyRoot() virtual {
        _;
    }

    /// @dev Needs to be implemented by pair
    /// @return uint128[] Current pair's tokens reserves
    function _reserves() internal view virtual returns (uint128[]);

    /// @dev Needs to be implemented by pair
    /// @return address[] Current pair's token roots addresses
    function _tokenRoots() internal view virtual returns (address[]);

    function setOracleOptions(
        OracleOptions _newOptions,
        address _remainingGasTo
    ) external onlyRoot override {
        tvm.rawReserve(UtilityGas.INITIAL_BALANCE, 0);

        // Check input params
        require(_newOptions.cardinality >= _options.cardinality, OracleErrors.LOWER_CARDINALITY);
        require(_newOptions.minRateDeltaDenominator > 0, OracleErrors.NON_POSITIVE_DENOMINATOR);

        // Update options
        _options = _newOptions;
        emit OracleOptionsUpdated(_newOptions);

        _remainingGasTo.transfer({ value: 0, flag: UtilityFlag.ALL_NOT_RESERVED + UtilityFlag.IGNORE_ERRORS });
    }

    function getOracleOptions() external view responsible override returns (OracleOptions) {
        return {
            value: 0,
            bounce: false,
            flag: UtilityFlag.REMAINING_GAS
        } _options;
    }

    function removeLastNPoints(
        uint16 _count,
        address _remainingGasTo
    ) external onlyRoot override {
        tvm.rawReserve(UtilityGas.INITIAL_BALANCE, 0);

        // Check input params
        require(_count > 0, OracleErrors.NON_POSITIVE_COUNT);
        require(_count <= _length, OracleErrors.BIGGER_THAN_LENGTH);

        // Remove last point _count times and decrease length
        for (uint16 i = 0; i < _count; i++) {
            _points.delMin();
            _length -= 1;
        }

        _remainingGasTo.transfer({ value: 0, flag: UtilityFlag.ALL_NOT_RESERVED + UtilityFlag.IGNORE_ERRORS });
    }

    function getObservation(uint32 _timestamp) external view responsible override returns (optional(Observation)) {
        return {
            value: 0,
            bounce: false,
            flag: UtilityFlag.REMAINING_GAS
        } _tryGetObservationByTimestamp(_timestamp);
    }

    function observation(
        uint32 _timestamp,
        TvmCell _payload
    ) external view override {
        tvm.rawReserve(UtilityGas.INITIAL_BALANCE, 0);

        IOnObservationCallback(msg.sender)
            .onObservationCallback{ value: 0, flag: UtilityFlag.ALL_NOT_RESERVED }
            (_tryGetObservationByTimestamp(_timestamp), _payload);
    }

    function getRate(
        uint32 _fromTimestamp,
        uint32 _toTimestamp
    ) external view responsible override returns (optional(Rate), uint128[]) {
        return {
            value: 0,
            bounce: false,
            flag: UtilityFlag.REMAINING_GAS
        } (
            _calculateRate(_fromTimestamp, _toTimestamp),
            _reserves()
        );
    }

    function rate(
        uint32 _fromTimestamp,
        uint32 _toTimestamp,
        address _callbackTo,
        TvmCell _payload
    ) external view override {
        tvm.rawReserve(UtilityGas.INITIAL_BALANCE, 0);

        IOnRateCallback(_callbackTo)
            .onRateCallback{ value: 0, flag: UtilityFlag.ALL_NOT_RESERVED }
            (_calculateRate(_fromTimestamp, _toTimestamp), _reserves(), _payload);
    }

    function getExpectedAmountByTWAP(
        uint128 _amount,
        address _tokenRoot,
        uint32 _fromTimestamp,
        uint32 _toTimestamp
    ) external view responsible override returns (uint128) {
        address[] roots = _tokenRoots();

        // Check input params
        require(_tokenRoot == roots[0] || _tokenRoot == roots[1], OracleErrors.WRONG_TOKEN_ROOT);
        require(_amount > 0, OracleErrors.WRONG_AMOUNT);

        optional(Rate) rateOpt = _calculateRate(_fromTimestamp, _toTimestamp);

        // Revert call if rate is null
        if (!rateOpt.hasValue()) {
            revert(OracleErrors.CAN_NOT_CALCULATE_TWAP);
        }

        bool isLeftTokenRoot = roots[0] == _tokenRoot;
        Rate rates = rateOpt.get();

        return {
            value: 0,
            bounce: false,
            flag: UtilityFlag.REMAINING_GAS
        } FixedPoint128.calculateExpectedAmountByRate(
            _amount,
            isLeftTokenRoot ? rates.price1To0 : rates.price0To1
        );
    }

    /// @dev Initializes oracle with the first point
    /// @param _timestamp UNIX timestamp in seconds of observations start
    /// @return bool Whether or not oracle was initialized
    function _initializeTWAPOracle(uint32 _timestamp) internal returns (bool) {
        // Check input params and initialization status of the oracle
        require(_points.empty(), OracleErrors.ALREADY_INITIALIZED);
        require(_timestamp > 0, OracleErrors.NON_POSITIVE_TIMESTAMP);

        Point first = Point(0, 0);

        // Initialize state
        _options = OracleOptions(
            15,
            1,
            100,
            1000
        );

        // Update _points and increase _length
        _points[_timestamp] = first;
        _length += 1;

        emit OracleInitialized(
            Observation(
                _timestamp,
                first.price0To1Cumulative,
                first.price1To0Cumulative
            )
        );

        return true;
    }

    /// @dev Try to write a new point in the historical array
    /// @param _token0ReserveOld Previous token 0 reserve
    /// @param _token1ReserveOld Previous token 1 reserve
    /// @param _timestamp UNIX timestamp in seconds of the observation
    /// @return Observation An observation that was written or an empty observation if it wasn't processed
    function _write(
        uint128 _token0ReserveOld,
        uint128 _token1ReserveOld,
        uint32 _timestamp
    ) internal returns (Observation) {
        // Check that oracle is initialized or return an empty observation
        if (_points.empty()) {
            return Observation(0, 0, 0);
        }

        // Get the last point
        // Safe operation, because we checked _points.empty() previously
        (uint32 lastTimestamp, Point lastPoint) = _points.max().get();

        // Should never occur
        if (_timestamp < lastTimestamp) {
            return Observation(0, 0, 0);
        }

        // Calculate the interval between points and get current reserves
        uint32 timeElapsed = _timestamp - lastTimestamp;
        uint128[] reserves = _reserves();

        // Check that pair has reserves
        if (reserves[0] == 0 || reserves[1] == 0) {
            return Observation(0, 0, 0);
        }

        // Checking can oracle write this point or return an empty point
        if (timeElapsed < _options.minInterval) {
            uint rateDelta = _calculateRateDelta(
                reserves[0],
                reserves[1],
                _token0ReserveOld,
                _token1ReserveOld
            );

            uint minRateDelta = FixedPoint128.encodeFromNumeratorAndDenominator(
                _options.minRateDeltaNumerator,
                _options.minRateDeltaDenominator
            );

            if (rateDelta < minRateDelta) {
                return Observation(0, 0, 0);
            }
        }

        Point next = _createNextPoint(
            lastPoint,
            timeElapsed,
            reserves[0],
            reserves[1]
        );

        // Write a new point
        _points[_timestamp] = next;

        // Increase length or delete the oldest point
        if (_length < _options.cardinality) {
            _length += 1;
        } else {
            _points.delMin();
        }

        Observation newObservation = Observation(
            _timestamp,
            next.price0To1Cumulative,
            next.price1To0Cumulative
        );

        emit OracleUpdated(newObservation);

        return newObservation;
    }

    /// @notice Calculates TWAP for the given interval
    /// @dev If there is no point with a timestamp equal to _fromTimestamp or _toTimestamp
    /// will take the point with the nearest timestamp
    /// @param _fromTimestamp Start of interval for TWAP
    /// @param _toTimestamp End of interval for TWAP
    /// @return optional(Rate) Packed rate info in the time range between _fromTimestamp and _toTimestamp
    /// or null if impossible to calculate
    function _calculateRate(
        uint32 _fromTimestamp,
        uint32 _toTimestamp
    ) private view returns (optional(Rate)) {
        // Check input params
        require(!_points.empty(), OracleErrors.NOT_INITIALIZED);
        require(_fromTimestamp < _toTimestamp, OracleErrors.FROM_IS_BIGGER_THAN_TO);
        require(_fromTimestamp > 0, OracleErrors.NON_POSITIVE_TIMESTAMP);

        optional(Rate) rateOpt;

        // Find the nearest observations
        Observation fromObservation = _calculateObservation(_fromTimestamp);
        Observation toObservation = _calculateObservation(_toTimestamp);

        // Check if they are the same
        if (fromObservation.timestamp == toObservation.timestamp) {
            // Safe operation, because we checked _points.empty() previously
            (uint32 lastTimestamp,) = _points.max().get();

            // If they equal to the last point then just return reserves ratio
            if (fromObservation.timestamp == lastTimestamp) {
                uint128[] reserves = _reserves();

                rateOpt.set(
                    Rate(
                        FixedPoint128.div(FixedPoint128.encode(reserves[0]), reserves[1]),
                        FixedPoint128.div(FixedPoint128.encode(reserves[1]), reserves[0]),
                        fromObservation.timestamp,
                        toObservation.timestamp
                    )
                );
            }
        } else {
            uint32 timeElapsed = toObservation.timestamp - fromObservation.timestamp;

            rateOpt.set(
                Rate(
                    (toObservation.price0To1Cumulative - fromObservation.price0To1Cumulative) / timeElapsed,
                    (toObservation.price1To0Cumulative - fromObservation.price1To0Cumulative) / timeElapsed,
                    fromObservation.timestamp,
                    toObservation.timestamp
                )
            );
        }

        return rateOpt;
    }

    /// @dev Creates Point structure from given values
    /// @param _previous Last point in _points
    /// @param _timeElapsed Time passed after the last point write
    /// @param _token0Reserve Current reserve of token 0
    /// @param _token1Reserve Current reserve of token 1
    /// @return Point Point created by input params
    function _createNextPoint(
        Point _previous,
        uint32 _timeElapsed,
        uint128 _token0Reserve,
        uint128 _token1Reserve
    ) private pure returns (Point) {
        // Encode reserves to FP128
        uint token0ReserveX128 = FixedPoint128.encode(_token0Reserve);
        uint token1ReserveX128 = FixedPoint128.encode(_token1Reserve);

        // Calculate cumulatives' delta
        uint price0To1CumulativeDelta = math.muldiv(token0ReserveX128, _timeElapsed, _token1Reserve);
        uint price1To0CumulativeDelta = math.muldiv(token1ReserveX128, _timeElapsed, _token0Reserve);

        return Point(
            _previous.price0To1Cumulative + price0To1CumulativeDelta,
            _previous.price1To0Cumulative + price1To0CumulativeDelta
        );
    }

    /// @dev Calculates rate delta from given values
    /// @param _token0ReserveNew Current token 0 reserve
    /// @param _token1ReserveNew Current token 1 reserve
    /// @param _token0ReserveOld Previous token 0 reserve
    /// @param _token1ReserveOld Previous token 1 reserve
    /// @return uint Rate's percent delta in FP128 representation
    function _calculateRateDelta(
        uint128 _token0ReserveNew,
        uint128 _token1ReserveNew,
        uint128 _token0ReserveOld,
        uint128 _token1ReserveOld
    ) private pure returns (uint) {
        // Check input params
        if (
            _token0ReserveNew == 0 ||
            _token1ReserveNew == 0 ||
            _token0ReserveOld == 0 ||
            _token1ReserveOld == 0
        ) {
            return 0;
        }

        uint resultX128 = math.muldiv(
            math.muldiv(uint256(_token0ReserveNew), FixedPoint128.FIXED_POINT_128_MULTIPLIER, _token0ReserveOld),
            _token1ReserveOld,
            _token1ReserveNew
        );

        // Percent delta can be negative
        return FixedPoint128.FIXED_POINT_128_MULTIPLIER > resultX128 ?
            FixedPoint128.FIXED_POINT_128_MULTIPLIER - resultX128 :
            resultX128 - FixedPoint128.FIXED_POINT_128_MULTIPLIER;
    }

    /// @dev Calculates observation by timestamp
    /// @param _timestamp Target UNIX timestamp in seconds
    /// @return Observation Observation that equal to target or the nearest
    function _calculateObservation(uint32 _timestamp) private view returns (Observation) {
        uint32 timestamp;
        Point point;

        optional(uint32, Point) opt = _points.nextOrEq(_timestamp);

        // Save equal or next if it exists
        if (opt.hasValue()) {
            (timestamp, point) = opt.get();
        }

        // If we didn't find the exact point then find the closest
        if (timestamp != _timestamp) {
            optional(uint32, Point) prev = _points.prev(_timestamp);

            // Update with the previous point if it's closer
            if (prev.hasValue()) {
                (uint32 prevTimestamp, Point prevPoint) = prev.get();
                bool isPrevCloser = timestamp < 1 || (_timestamp - prevTimestamp < timestamp - _timestamp);

                if (isPrevCloser) {
                    timestamp = prevTimestamp;
                    point = prevPoint;
                }
            }
        }

        return Observation(
            timestamp,
            point.price0To1Cumulative,
            point.price1To0Cumulative
        );
    }

    /// @dev Try to find observation with the target timestamp
    /// @param _timestamp Target UNIX timestamp in seconds
    /// @return optional(Observation) Observation with target timestamp or null if it doesn't exist
    function _tryGetObservationByTimestamp(uint32 _timestamp) private view returns (optional(Observation)) {
        optional(Point) pointOpt = _points.fetch(_timestamp);
        optional(Observation) observationOpt;

        // Set if exists
        if (pointOpt.hasValue()) {
            Point point = pointOpt.get();

            observationOpt.set(
                Observation(
                    _timestamp,
                    point.price0To1Cumulative,
                    point.price1To0Cumulative
                )
            );
        }

        return observationOpt;
    }

    /// @dev Pack all oracle's data for a contract upgrade
    /// @return TvmCell Packed data to unpack after code upgrade
    function _packAllOracleData() internal view returns (TvmCell) {
        TvmBuilder builder;

        builder.store(_points);
        builder.store(_options);
        builder.store(_length);

        return builder.toCell();
    }
}
