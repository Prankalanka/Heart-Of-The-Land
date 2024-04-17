function CombatState(_persistVar, _tempVar, _stateMachine, _userInput, _anims, _data = undefined) : EntityState(_persistVar, _tempVar, _stateMachine, _userInput, _anims, _data = undefined) constructor {
	static stateSEnter = sEnter;
}

function IdleCombatState(_persistVar, _tempVar, _stateMachine, _userInput, _anims, _data = undefined) : CombatState(_persistVar, _tempVar, _stateMachine, _userInput, _anims, _data = undefined) constructor {
	static name = "Idle Combat";
	static num = STATEHIERARCHY.idleCombat;
	
	static updLogic = function() {
	}
	
	checkChanges = function() {
		checkHold();
	}
	
	static checkHold = function() {
		if userInput.holdInput {
			// Check if there's any near throwables (when inventory implemented check that first)
			with entity {
				if place_meeting(x, y, par_throwable) {
					var _held = instance_nearest(x, y, par_throwable);
					
					// Done here so they're at the hold and held states at the same time
					stateMachine.requestChange(holdState, 0, _held);
					_held.stateMachine.requestChange(_held.heldState, 0, id);
					_held.stateMachine.requestChange(_held.heldState, 1, id);
					_held.stateMachine.requestChange(_held.heldState, 2, id);
				}
			}
		}
	}
}

function HoldState(_persistVar, _tempVar, _stateMachine, _userInput, _anims, _data = undefined) : CombatState(_persistVar, _tempVar, _stateMachine, _userInput, _anims, _data = undefined) constructor {
	static name = "Hold";
	static num = STATEHIERARCHY.hold;
	
	held = undefined;
	
	height = 0;
	multi = 0.15;
	angle = 0;
	initVel = 0;
	areAxesOpposite = 1;
	weight = 1/3;
	
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
		
	}
	
	checkChanges = function() {
		checkRelease();
		checkCancel();
	}
	
	static checkRelease = function() {
		if !userInput.holdHeld {
			if entity != plyr {
				aimProjectilePos();
			}
			throwProjectile(); // Changes held's state
			stateMachine.requestChange(entity.idleCombatState, 0);
		}
	}
	
	static checkCancel = function() {
		if userInput.holdCancel {
			// Put in inventory once we implement it
			entity.stateMachine.requestChange(entity.idleCombatState, 0);
			
			held.stateMachine.requestChange(held.idleCombatState, 0);
			held.stateMachine.requestChange(held.idleState, 1);
			held.stateMachine.requestChange(held.idleState, 2);
		}
	}
	
	static quadraticEquation = function(_a, _b, _c,  _sign) {
		return (-_b + _sign * sqrt(sqr(_b) - 4 * _a * _c)) / (2 * _a);
	}
	
	static drawPath = function() {
		totalTime = 20;
		var _lastXPos = held.x;
		var _lastYPos = held.y;
		
		//show_debug_message([initVel, angle]);
		for (var i = 0; i < totalTime; i += 1 * multi) {
			var _nextXPos = initVel * i  *cos(angle) * areAxesOpposite + held.x; 
			var _nextYPos = (initVel * i * sin(angle)  - (1/2) *  -held.projGrav * sqr(i)) + held.y;
			
			draw_line(_lastXPos, _lastYPos, _nextXPos, _nextYPos);
			
			_lastXPos = _nextXPos;
			_lastYPos = _nextYPos;
			//show_debug_message(initVel * i * sin(angle)); // This is just repeatedly multiplies the first number can add into acceleration
		}
		
		// We have a speed 
		// We accelerate along the y axes by adding half of our acceleration multiplied the square of time
		for (var i = 0; i < totalTime; i += 1 * multi) {
			/*
			var yPos = held.y;
			var _yVelocity = initVel * i * sin(angle);
			var _yNextAccel = 1/2 * -held.projGrav * sqr(i); // accel is meters per second squared which is probably why we're squaring i
			var _yNextVelocity = _yVelocity * weightMulti + _yNextAccel * weightMulti;
			
			yPos += _yNextVelocity;
			
			var _xPos = held.y;
			
			// HOW DO WE HANDLE COLLISIONS AND THE ADDITION OF OTHER FORCES
			// Once we collide with something on the yAxis we could set our initVel or areAxesOpposite variable to 0 or reverse their sign
			// But that would affect the x axis, so we not to separatae y and x calculations
			// Additionally we'd want to reset i in the yAxis calculation
			// This system is not fun to manaage
			
			// USING ENTITY YVEL VAR
			// We could use our entity's yVel variable, and add the individual acceleration to that
			
			// FACTORING OUT "i"
			// We'd needd to convert initVel * i * sin(angle) + 1/2 * -held.projGrav * sqr(i)
			// i * (initVel/i * 1 * sin(angle)/i + 1/2 / i * -held.projGrav / i * i)
			// Those equations should be equal
			
			// ADDING ACCELERANTS TO BASE VELOCITY
			// We take each individual accelerant and multiply it by "i"
			// The variable i is better called timeMulti, since we're not relying on it to run the equation, just how fast it should run
			// We'll call it timeMulti from now on
			
			// Calculating OUR ACTUAL YVEL 
			// We now just add that all to our yVel,
			// We can make the addition cumulative when we just want to continue the force
			// We can reset y to 0 when we don't want to
			// It shouldn't affect our end position, just how long it takes to reach it
			
			// UPDATE Y FUNCTION
			// Use the updateY function, or make one that handles bouncing
			// This can be done with an optional argument that just handles colliding by setting yVel to 0
			// We could pass in a function that changes the sign and strength of our initialVelocity
			// And also gets rid of any forces that had the same sign as the direction we collided in (EXCEPT FOR GRAVITY)
			
			// CONFIRMING IT SOLVES OUR PROBLEMS OF HANDLING COLLISIONS AND ADDITION OF OTHER FORCES
			// What would happen if an additional force is added, we'd also just factor out i and add it to the velocity the next frame
			// Each factored out force, essentially increments in its multiplication each time it is added, so adding another random force midway would work
			// What would happen when we collide? We reset our yVel to 0 so all the multiplications of each force would be 0, this doesn't actually get rid of those forces in our acceleration equation
			// So we just get rid of all forces that are the same sign as the direction we collided in
			// How do we turn initVel into acceleration?
			// In the previous equation, "i" would be multiplied by initVel, increasing every frame
			// Now initVel is being added onto every frame, we just need to multiply it by timeMulti, which is a constant value unlike "i", to get it scaled to the speed we want without changing the path
			// What would happen if a thrust force is overtaken, I tihnk we should get rid of it somehow for the equation to be balanced
			// Thrust forces require contact so they're always impulses (when colliding with other moveable stuff we can do an equation to see how much the impulse should be)
			// Therefore we really only need one thrust force at a time, we can reset our friction and/or gravity every time that impulse occurs
			// I think that's a plan
			
			// We'll start with an array for our projectile, forces
			// There are three types of force that we're going to worry about
			// Thrust, Gravity, and Friction/Drag
			// These will be stored in an array, thrust being the first index, friction/drag second, and gravity third because the x axis doesn't have gravity
			// The thrust is a calculation like initVel that linearly gets bigger but is subtracted from by friction which probably also linearly enlarges, and gravity which expenonentially enlarges
			// Once a thrust calculation is not going to be the same sign as the net force of that axis, the gravity and friction reset and the thrust is set to 0
			
			// Thrust is like what we have with our initVel, it is applied once but equationally it's there forever
			
			// What would be the acceleration when dding (initVel *  sin(angle)#
			var _yVelocity = initVel * i * sin(angle); // if we could convert this to an acceleration, do we need to?
			var _yNextAccel = 1/2 * -held.projGrav * sqr(i); // accel is meters per second squared which is probably why we're squaring i
			var _yNextVelocity = _yVelocity * weightMulti + _yNextAccel * weightMulti;
			*/
			// Could probably have multiple forces acting on som
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
		initVel = -1 * ((_b / sin(angle)) * _magnitude/ 150); // I know sin gives us direction, and magnitude gives us power
		//show_debug_message([radtodeg(angle),  initVel, height, _b, sin(angle)]);
	}
	
	static aimProjectilePos = function () {
		areAxesOpposite = 1;
		// WE'RE USING RADIANS		
		var _targetPos = userInput.throwPos;
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
		
		initVel = -1 * (_b / sin(angle));
	}
	
	static throwProjectile = function() {
		var _data =  [initVel, angle, multi, areAxesOpposite];
		
		held.stateMachine.requestChange(held.projectileState, 0, _data);
		held.stateMachine.requestChange(held.projectileState, 1);
		held.stateMachine.requestChange(held.projectileState, 2);
	}
}
	
