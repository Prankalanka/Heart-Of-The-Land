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
	
	static sEnter = function(_data) {
		held = _data;
	}
	
	static sExit = function() {
		held = undefined;
	}
	
	static updLogic = function() {
		var _targetPos = entity.inputHandler.throwPos;
		height = _targetPos[1] + sqrt(sqr(_targetPos[0]) + sqr(_targetPos[1]));
		
		
		doChecks();
	}
	
	doChecks = function() {
		checkRelease();
		checkCancel();
	}
	
	static checkRelease = function() {
		if !entity.inputHandler.holdInputHeld {
			var _targetPos = entity.inputHandler.throwPos;
			
			throwProjectile(held, _targetPos, height);
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
	
	static throwProjectile = function (_proj, _targetPos, _height) {
		// WE'RE USING RADIANS		
		var _grav = _proj.projGrav;
		var _tX = _targetPos[0];
		var _tY = _targetPos[1];
		show_debug_message(_targetPos);
		
		var _a = (-0.5 * _grav);
		var _b = sqrt(2 * _grav * _height);
		var _c = -_tY;
		
		var _posTime = quadraticEquation(_a, _b, _c, 1);
		var _negTime = quadraticEquation(_a, _b, _c, -1);
		var _time = max(_posTime, _negTime);
		
		var _angle = arctan(_b * _time / _tX);
		
		var _initVel = _b / sign(_angle);
		
		var _data =  [_initVel, _angle];
		
		_proj.stateMachine.changeState(entity.projectileState, 0, _data);
		_proj.stateMachine.changeState(entity.projectileState, 1, _data);
		_proj.stateMachine.changeState(entity.projectileState, 2, _data);
	}
	
	static quadraticEquation = function(_a, _b, _c,  _sign) {
		return (-_b + _sign * sqrt(sqr(_b) - 4 * _a * _c)) / (2 * _a);
	}
}