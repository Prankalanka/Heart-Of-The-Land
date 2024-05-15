enum CAM_MANS {
	PLYR,
}

camMan = CAM_MANS.PLYR;

xCam = camera_get_view_x(view_camera[0]);
yCam = camera_get_view_y(view_camera[0]);

targetX = 0;
targetY = 0;

xMidOffset = camera_get_view_width(view_camera[0]) / 2;
yMidOffset = camera_get_view_width(view_camera[0]) / 2;

xVel = 0;
xVelMax = 250;
yVel = 0;

camXAccel = 0;
camYAccel = 0;

lookAheadDist = 0;
lookAheadMax = (camera_get_view_width(view_camera[0]) / 12.25) * 1;
lAAccel = 6.25;
lADecel = 0.985;

// Returns the next smoothed value after the current value given
 smoothDamp = function(_current, _target, _currentVelocity, _smoothTime, _maxSpeed = 999999999999999999999999999999999999999999999999999999999999)
{
    // Based on Game Programming Gems 4 Chapter 1.10
    _smoothTime = max(0.0001, _smoothTime);
    var _omega = 2 / _smoothTime;

    var _exponent = 1/ (1 + _omega + 0.48 * _omega * _omega + 0.235 * _omega * _omega * _omega);
    var _change = _current - _target;
    var _originalTo = _target;

    // Clamp maximum speed
    var _maxChange = _maxSpeed * _smoothTime;
    _change = clamp(_change, -_maxChange, _maxChange);
    _target = _current - _change;

    var _temp = (_currentVelocity + _omega * _change);
    _currentVelocity = (_currentVelocity - _omega * _temp) * _exponent;
    var _output = _target + (_change + _temp) * _exponent;

    // Prevent overshooting
    if (_originalTo - _current > 0.0 and 0.0 == _output and _output > _originalTo)
    {
        _output = _originalTo;
        _currentVelocity = (_output - _originalTo);
    }

    return _output;
}