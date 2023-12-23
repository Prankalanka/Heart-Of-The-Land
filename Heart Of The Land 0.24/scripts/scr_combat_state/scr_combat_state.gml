function CombatState(_id, _animName) : EntityState(_id, _animName) constructor{
	static stateSEnter = sEnter;
}

function IdleCombatState(_id, _animName) : CombatState(_id, _animName) constructor{
	static name = "Idle Combat";
	static num = STATEHIERARCHY.idleCombat;
	
	
	static updLogic = function() {
		doChecks();
	}
	
	doChecks = function() {
		checkHold();
	}
	
	static checkHold = function() {
		if entity.inputHandler.holdInput {
			// Check if there's any near throwables (when inventory implemented check that first)
			with entity {
				if place_meeting(x, y, par_throwable) {
					var _held = instance_nearest(x, y, par_throwable);
					
					// Done here so they're at the hold and held states at the same time
					stateMachine.changeState(holdState, 0, _held);
					_held.stateMachine.changeState(_held.heldState, 0, id);
					_held.stateMachine.changeState(_held.heldState, 1, id);
					_held.stateMachine.changeState(_held.heldState, 2, id);
				}
			}
		}
	}
}

function HoldState(_id, _animName) : CombatState(_id, _animName) constructor{
	static name = "Hold";
	static num = STATEHIERARCHY.hold;
	
	held = undefined;
	
	height = 0;
	multi = 0.1;
	angle = 0;
	initVel = 0;
	areAxesOpposite = 1;
	
	initMPos = [];
	
	static sEnter = function(_data) {
		held = _data;
		initMPos = [mouse_x, mouse_y];
	}
	
	static sExit = function() {
		held = undefined;
	}
	
	static updLogic = function() {
		if entity == plyr { // Player always wants to aim projectile cuz we wanna draw it or 
			aimProjectilePlyr(); 
		}
		
		doChecks();
	}
	
	doChecks = function() {
		checkRelease();
		checkCancel();
	}
	
	static checkRelease = function() {
		if !entity.inputHandler.holdInputHeld {
			if entity != plyr {
				aimProjectilePos();
			}
			throwProjectile(); // Changes held's state
			stateMachine.changeState(entity.idleCombatState, 0);
		}
	}
	
	static checkCancel = function() {
		if entity.inputHandler.holdCancel {
			// Put in inventory once we implement it
			entity.stateMachine.changeState(entity.idleCombatState, 0);
			
			held.stateMachine.changeState(entity.idleCombatState, 0);
			held.stateMachine.changeState(entity.idleState, 1);
			held.stateMachine.changeState(entity.idleState, 2);
		}
	}
	
	static aimProjectilePos = function () {
		areAxesOpposite = 1;
		// WE'RE USING RADIANS		
		var _targetPos = entity.inputHandler.throwPos;
		var _sqrX = sqr(held.x - _targetPos[0]);
		var _sqrY = sqr(held.y - _targetPos[1]);
		height = (held.y - _targetPos[1]) + sqrt(_sqrX + _sqrY) / 2;
		
		var _grav = held.projGrav;
		var _tX = _targetPos[0];
		var _tY = _targetPos[1];
		//show_debug_message(_targetPos);
		
		var _a = (-0.5 * _grav);
		var _height = max(height, 0.01);
		var _b = sqrt(2 * _grav * _height);
		var _c = - (held.y - _tY);
		
		var _posTime = quadraticEquation(_a, _b, _c, 1);
		var _negTime = quadraticEquation(_a, _b, _c, -1);
		var _time = max(_posTime, _negTime);
		
		angle = arctan((_time * _b) / (held.x - _tX));
		
		initVel = _b / sin(angle);
	}
	
	static quadraticEquation = function(_a, _b, _c,  _sign) {
		return (-_b + _sign * sqrt(sqr(_b) - 4 * _a * _c)) / (2 * _a);
	}
	
	static drawPath = function() {
		totalTime = 100;
		var _lastXPos = held.x;
		var _lastYPos = held.y;
		
		//show_debug_message([initVel, angle]);
		for (var i = 0; i < totalTime; i += 1 * multi) {
			var _nextXPos = -initVel * i * cos(angle) * areAxesOpposite + held.x; 
			var _nextYPos = (-initVel * i * sin(angle)  - (1/2) *  -held.projGrav * sqr(i)) + held.y;
			
			draw_line(_lastXPos, _lastYPos, _nextXPos, _nextYPos);
			
			_lastXPos = _nextXPos;
			_lastYPos = _nextYPos;
		}
	}
	
	static aimProjectilePlyr = function() {
		areAxesOpposite = -1;
		// WE'RE USING RADIANS		
		var _grav = held.projGrav;
		var _xDiff = mouse_x - initMPos[0];
		var _yDiff = mouse_y - initMPos[1];
		
		// Get angle from initial mouse pos to current mouse position
		angle = degtorad(point_direction(initMPos[0], initMPos[1], mouse_x, mouse_y));
		
		// The sin of the angle ranges from -1 to 1, it's a direction and a multiplier which forces the value to conform to a circle of sorts (normalisation kinda)
		// Multiplying that by our _yDiff conforms that value to something (maybe the unit circle)  so that we don't have differing velocities for the same maagnitude
		// We make it an absolute value because we don't care about sign, we'll set it later
		height = abs(sin(angle) * _yDiff);
	
		var _b = sqrt(2 * _grav * height) * sign(_yDiff); // A variable from the projectile motion equation 
		var _magnitude = sqrt(sqr(_xDiff) + sqr(_yDiff)); // If you don't know what magnitude is idk what to tell you

		// Not sure why the maths works, I just know that we can rearrange the equation to get this
		initVel = (_b / sin(angle)) * _magnitude/ 150; // I know sin gives us direction, and magnitude gives us power
		show_debug_message([radtodeg(angle),  initVel, height, _b, sin(angle)]);
	}
	
	static throwProjectile = function() {
		var _data =  [initVel, angle, multi, areAxesOpposite];
		
		held.stateMachine.changeState(held.projectileState, 0, _data);
		held.stateMachine.changeState(held.projectileState, 1, _data);
		held.stateMachine.changeState(held.projectileState, 2, _data);
	}
}