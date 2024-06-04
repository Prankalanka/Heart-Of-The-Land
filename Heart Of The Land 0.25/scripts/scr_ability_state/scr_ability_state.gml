/// Super class for all ability states
/// Switches to either Idle, Move or InAir states once ability is done
function AbilityState(_persistVar, _stateMachine, _inputHandler, _anims, _data = undefined) : EntityState(_persistVar, _stateMachine, _inputHandler, _anims, _data = undefined) constructor {
	static stateSEnter = sEnter;
		
	static checkAbility1 = function() {
		if inRegion[1] {
			if persistVar.xVel == 0 and inputHandler.xInputDir == 0 {
				stateMachine.requestChange(SH.IDLE, 1);
			} else {
				stateMachine.requestChange(SH.WALK, 1);
			}
		}
	}
		
	static checkAbility2 = function() {
		if inRegion[2] {
			if !persistVar.isBelow {
				stateMachine.requestChange(SH.INAIR, 2);
			}
			else {
				if persistVar.xVel == 0 and inputHandler.xInputDir == 0 {
					stateMachine.requestChange(SH.IDLE, 2);
				} else {
					stateMachine.requestChange(SH.WALK, 2);
				}
			}
		}
	}
}

function JumpState(_persistVar, _stateMachine, _inputHandler, _anims, _data = undefined) : AbilityState(_persistVar, _stateMachine, _inputHandler, _anims, _data = undefined) constructor {
	static name = "Jump";
	static num = SH.JUMP;
	static abilitySEnter = sEnter;
	peak = _data[0];
	framesToPeak = _data[1];
	initJumpVel = _data[2];
	grav = _data[3];
	yVelMax = _data[4];
	isAbilityDone = false;
	
	static sEnter = function(_data = undefined) {
		isAbilityDone = false;
		
		// Set input values (these handle if we're continuing a jump or not)
		inputHandler.spaceReleasedSinceJump = false;
		inputHandler.currJumpFrame = 1;
		inputHandler.jumpBuffer = 0;
	}
	
	static updLogic = function() {
		// Set velocity and spaceReleased
		persistVar.yVel = initJumpVel;
	
		// Update yVel and Y
		updGrav(grav, 1, yVelMax);
	}
	
	static getAnimEnter = function() {
		var _spriteIndex = activeAnims[faceDir(inputHandler.xInputDir)];
		return [_spriteIndex, undefined, undefined];
	}
	
	static getAnimUpd = function() {
		// Change anim if we change direction
		var _spriteIndex = activeAnims[faceDir(inputHandler.xInputDir)];
		return [_spriteIndex, undefined, undefined];
	}

	checkChanges = function() {
		// Change to other state, this one is only active for one frame
		checkAbility2();
	}
}

function DashState(_persistVar, _stateMachine, _inputHandler, _anims, _data = undefined) : AbilityState(_persistVar, _stateMachine, _inputHandler, _anims, _data = undefined) constructor {
	static name = "Dash";
	static num = SH.DASH;
	dir = 0;
	dashFrame = 0;
	isAbilityDone = false;
	if _data != false {
		dashDuration = _data[0];
		xVelMax = _data[1];
	}
	
	static sEnter = function(_data = undefined) {	
		// Update dir
		dir = inputHandler.dashInputDir;
		
		// Reset dashFtame
		dashFrame = 0;
		
		isAbilityDone = false;
	}
	
	static sExit = function() {
		dashFrame = 0;
	}
		
	static updLogic = function() {
		// Increment to move along the graph
	    // Start at 1 cuz 0 makes xVel equal 0
	    dashFrame += 1;
		
		persistVar.xVel = (dashFrame == 1)? xVelMax * dir : (persistVar.xVel + 17.7 * dir) * 0.57;
		
	    if dashFrame == dashDuration {
			isAbilityDone = true;
	    }
	}
	
	static getAnimUpd = function() {
		// Change anim if we change direction
		var _spriteIndex = activeAnims[faceDir(sign(persistVar.xVel))];
		return [_spriteIndex, undefined, undefined];
	}
	
	static checkWalk12 = function() {
		if dashFrame == dashDuration and abs(persistVar.xVel) <= persistVar.xVelMax {
			if inRegion[1] {
				stateMachine.requestChange(SH.WALK, 1);
			}
			if inRegion[2] {	
				stateMachine.requestChange(SH.WALK, 2);
			}
		}
	}
		
	static checkInAir2 = function() {
		if  !(persistVar.isBelow) {
			stateMachine.requestChange(SH.INAIR, 2);
		} 
	}
	
	static checkJump2 = function() {
		if inputHandler.jumpInput and !persistVar.isAbove and persistVar.isBelow {
			stateMachine.requestChange(SH.JUMP, 2);
		}
	}
		
	static checkClimb12 = function() {
		if inputHandler.climbHeld and inputHandler.surface != undefined and inputHandler.cdClimb == 0 {
			// Check if our x value is closer to the left or right bbox boundary
			var _rightDiff = abs(inputHandler.surface.bbox_right) - abs(persistVar.x);
			var _leftDiff = abs(inputHandler.surface.bbox_left) - abs(persistVar.x);
			var _wallDir = ( abs(_rightDiff) > abs(_leftDiff))? -1 : 1;
			
			if inRegion[1] {
				stateMachine.requestChange(SH.CLIMB, 1, [_wallDir]);
			}
			if inRegion[2] {	
				stateMachine.requestChange(SH.CLIMB, 2, [_wallDir]);
			}
		}
	}
		
	static checkAbilityDone12 = function() {
		if isAbilityDone {
			checkAbility1();
			checkAbility2();
		}
	}
		
	checkChanges = function() {
		checkWalk12();
		checkJump2();
		checkInAir2();
		checkClimb12();
		checkAbilityDone12();
	}
}

function AirDashState(_persistVar, _stateMachine, _inputHandler, _anims, _data = undefined) : DashState(_persistVar, _stateMachine, _inputHandler, _anims, _data = undefined) constructor {
	static name = "Air Dash";
	static num = SH.AIRDASH;
	peak = _data[0];
	framesToPeak = _data[1];
	initYVel =_data[2];
	grav = _data[3];
	dashDuration = _data[4];
	// Has properties of dash state

	static sEnter = function() {
		// Update dir
		dir = inputHandler.dashInputDir;
		
		// Reset dashFtame
		dashFrame = 0;
		
		isAbilityDone = false;
		
		inputHandler.groundedAfterAirDash = false;
	}	
	
	static updLogic = function() {
		// Incremented until we reach duration and then exit state
	    dashFrame += 1;
		
		// Set vel
		persistVar.xVel = (dashFrame == 1)? 8.94 * dir : (persistVar.xVel + 3.6 * dir) * 0.85;
		if inRegion[2] {persistVar.yVel = initYVel;}
		
	    if dashFrame == dashDuration {
			isAbilityDone = true;
	    }
	}
	
	// airDash state gives away control of yVel after one frame since it can't apply gravity
	static checkInAir2 = function() {
		if  dashFrame >= 1 {
			stateMachine.requestChange(SH.INAIR, 2, [grav]);
		} 
	}
	
	checkChanges = function() {
		checkWalk12();
		checkInAir2();
		checkClimb12();
		checkAbilityDone12();
	}
	
}

function ProjectileState(_persistVar, _stateMachine, _inputHandler, _anims, _data = undefined) : AbilityState(_persistVar, _stateMachine, _inputHandler, _anims, _data = undefined) constructor {
	static name = "Projectile";
	static num = SH.PROJECTILE;

	projectileFrame = 0;
	
	angle = 0;
	initVel = 5;
	areAxesOpposite = 1;
	multi = 1;
	
	xVel = 0;
	yVel = 0;
	lastXPos = 0;
	lastYPos = 0;
	initPos = [];
	
	xForces = [0, 0, 0];
	xRepeatAccel = 0;
	
	yForces = [0, 0, 0];
	yRepeatAccel = 0;
	
	timeMulti = 1; // 1 is 100% 2 is 200% 0.1 is 10%
	framesToRepeat = 0;
	
	parameters = {
		mass : 1.2,
		grav : 9.8,
		//weight : mass * grav,
		
		// Drag Specific
		fluidDensity : 0.1, 
		crossArea : 100, // Will set for each entity type
		dragCo : 0.4, // Decided by shape of object, will set for each entity type
		
		// Friction Specific (all decided upon collision)
		sFMax : 0,
		sFCo : 0,
		kFCo : 0,	
	}
	
	static updLogic = function() {
		updProjectileVel();
	}
	
	static sEnter = function(_data = undefined) {
		abilitySEnter();
		// Enter the state and set the angle and set angle and initial velocity 
		// Set it through the player's vars
		
		initVel = _data[0];
		angle = _data[1];
		multi = _data[2];
		areAxesOpposite = _data[3];
		
		initPos = [persistVar.x, persistVar.y];
		projectileFrame = 0;
		lastXPos = 0;
		lastYPos = 0;
	}
	
	static updProjectileVel = function() {
		
		// x and yForces are arrays that we clear every cycle
		// Durig each frame cycle we add the acceleration of gravity and drag/friction
		// We can also add thrust forces
		
		// If we've repeated our accel enough
		// Recalculate the repeatAccel and framesToRepeat
		if framesToRepeat == 0 {
			var xNetAccel = calculateNetAccel(xForces);
			var yNetAccel = calculateNetAccel(yForces);
			
			framesToRepeat = 1/timeMulti; // Set how many times we repeat to how many times we need to how many times our time multiplier value fits into 1
			
			xRepeatAccel = xNetAccel / framesToRepeat; 
			yRepeatAccel = yNetAccel / framesToRepeat; 
		}
		
		persistVar.xVel += xRepeatAccel;
		persistVar.yVel += yRepeatAccel;
		
		
		framesToRepeat -= 1;
		
		// two options
		// if we use accel
		
		
		// To change how fast the simulation is we'd check if our framesToRepeat value is 0
		// If it is calculate the netAccel and multiply it by the 1/timeMulti which gives us the a fraction of the nextAccel value for that repeated frame
		// Store that vlaue so that we don't calculate it again and add it to the yVel
		// Then set framesToRepeat to 1/timeMulti
		// Decrement it every frame and whilst it isn't 0 repeat the addition
		
		
		// For 100 frames
		if projectileFrame < 100 {
			
			projectileFrame += 1 * multi;
			// Find the next position we're going to
			var _nextXPos = (initVel) * projectileFrame *cos(angle) * areAxesOpposite;
			var _nextYPos = (initVel) * projectileFrame * sin(angle) - (1/2)*  -persistVar.projGrav * sqr(projectileFrame);
			
			// Make the xVel the difference between the next position and the last position
			persistVar.xVel = _nextXPos - lastXPos;
			persistVar.yVel = _nextYPos - lastYPos;
			
			// Make the next position the last position, storing to be used at the start of the next frame
			lastXPos = _nextXPos;
			lastYPos = _nextYPos;
			
			// Testing for how multiple forces affect the sequence of our velocity
			// There are a few options:
			// Not scaling with multi at all which will keep the velocity value constant
			// Scaling with multi through addition, not tested but probably similar to multiplication
			// Scaling with multi through multiplication, which makes the sequence linear
			// Scaling with multi through squaring, which makes the sequence quadratic 
			// Scaling with multi through cubing, which makes the sequence cubic
		
			// We probably only need to scale with squaring, so our velocity sequence is quadratic and only has 2 differences
			
			// To turn this from m/frame to kgm/frame^2
			// Multiply by mass, divide by the current frame
			// To turn this into acceleration 
			// Divide by mass
			
			// This is speed and we're trying to get it affected by weight, so we break it down
			// The difference of speed is acceleration
			// acceleration = force/mass
			// we essentially haven't divided by mass
			// so we should divide the accel by mass to make it reliant on mass
			
			// The speed therefore becomes a result of acceleration and mass
			// The force is then also a result of acceleration and mass
			// So we can set a starting speed, and that is decelerated by
			
			// Say our acceleration from the velocity is 0.2m/frame^2
			// We divide that by our weight of 5 kg
			// 0.04/frame^2 is our new acceleration
			// The force then would be our original acceleration of 0.2kgm/frame^2
			
			// Say our acceleration is 10m/frame^2 after we addForce
			// we divide that by our weight of 5 kg
			// 2/frame ^ 2 is our new acceleration
			// Our force is 10N
		
			// mass/acceleration = force / acceleration**2
			// We can divide the acceleration by the mass to have the speed be affected by mass
			// yvel += accel/mass
		
			var _y1 = (initVel) * (multi * 1) * sin(angle) - (1/2) *  -persistVar.projGrav * sqr(multi * 1); //- (1/2) * power(multi * 1, 2);
			var _y2 = (initVel) * (multi * 2) * sin(angle) - (1/2) *  -persistVar.projGrav * sqr(multi * 2); //- (1/2) * power(multi * 2, 2);
			var _y3 = (initVel) * (multi * 3) * sin(angle) - (1/2) *  -persistVar.projGrav * sqr(multi * 3); //- (1/2) * power(multi * 3, 2);
			var _y4 = (initVel) * (multi * 4) * sin(angle) - (1/2) *  -persistVar.projGrav * sqr(multi * 4); //- (1/2) * power(multi * 4, 2);
		
			var _y12Diff = _y1 - _y2;
			var _y23Diff = _y2 - _y3;
			var _y34Diff = _y3 - _y4;
			var diffOfDIff1 = _y23Diff - _y12Diff;
			var diffOfDIff2 = _y23Diff - _y34Diff;
			var _thirdDiff = diffOfDIff1 - diffOfDIff2;
		
			// The current velocity is the initial velocity subtracted by an acceleration that scales with projectileFrame
			var _yVel = _y1 - diffOfDIff1 * (projectileFrame/multi -1);
			
			
			// Alternatively 
			// persistVar.yVel += initVel is addForce,  persistVar.yVel = initVel is impulse
			// initVel 
			// persistVar.yVel += diffOfDiff1 (which is a constant acceleration based upon our initVel, should change when initVel or multi changes)
			// en
			// OUR INITVEL IS LITERALLY initVel * multi * sin(angle) that should get taken away from by an acceleration
		
			// With a resting velocity of 0
		
			// We either addForce or setImpulse
			// addForce adds an acceleration of initVel * multi * sin(angle)
			// setImpulse and figures out how much acceleration to add to velocity to get it to initVel * multi * sin(angle)
		
			// Then we add gravity's acceleration
			// gravity would add a constant acceleration
		
			// Then we add drag or friction's acceleration
			// drag/friction would add a constant acceleration and they would have different calculations
			
			// drag would be based off the current velocity
			// D = -D * sign(vel)
			
			// The drag coefficient (cD) is a multiplier for how much drag an object experiences
			// We'll just set a drag coefficient for each throwable, there are measurements online for all kinds of shapes
			
			// fluidDensity is the density of the fluid / medium
			// crossArea is the cross-sectional area of the projectile
			
			// Drag is equali to HALF of all these terms multiplied by each other
			// D = fluidDensity * crossArea * vel**2 * 1/2 * cD
			
			// Drag is proportional to the velocity squared
			// c is the relationship between drag and velocity
			// D = c * v**2 
			
			// This means can substitute out D in our old equation with c * v**2
			// D = -c * v**2 * sign(vel)
			
			// To define c we just dividde both sides of our proportionality equation by velocity squared
			/// c = fluidDensity * crossArea * 1/2 * cD
			
			// So in long form drag force is fluidDensity multiplied by the cross-sectional area, multiplied by the drag coefficient, multiplied by velocity squared, multiplied by the opposite sign of velocity
			// D = fluidDensity * crossArea * 1/2 * cD * v**2 * sign(vel) * -1
			
			// Friction works differently
			// There are two kinds of friction
			// Static Friction is the force required to get an object to start moving along a surface,
			// it is givien by the normal force multiplied by the friction coefficient
			// It's directly proportional to the normal force because as you put more force on an object towards the surface it becomes harder to move
			// sFrictionMax = normal * cSF
			
			// To get the normal force we need to get the force our object is exerting on the object it's in contact with
			// This will be whatever forces act opposite to the axis you're colliding on
			// N = magnitude of forces acting in the direction of the object we're colliding with * -1 (weight on the x axis)
			
			// The static friction coefficient is a multiplier detailing how much the object should be affected by friction
			// It's dependent on the two objects that are in contact
			
			// Kinetic friction on the other hand is the force require to move 
			
			// So friction would be calculated as
			// sFrictionMax = normal * cSF
			// If opposingForce < sFrictionMax {
			//		frictionForce = opposingForce;
			//}
			// else {
			//		frictionForce = normal * cKF
			// }
			
			// 
			
		
			show_debug_message(string_format(persistVar.y, 4, 10));
			show_debug_message( [diffOfDIff1,
			string_format(_y1 - diffOfDIff1* (projectileFrame/multi - 1), 4, 10),
			string_format(persistVar.yVel, 4, 10),
			string_format((initVel) * (multi * 1) * sin(angle), 4, 10)
			]);
			
		}
		/*
		 initVel * cos(angle) * (i+1) - initVel * cos(angle) * i = nextYVel1
		 initVel * cos(angle) ((i+1) - i)
		 initVel * cos(angle) ((i+1) - (i+1) -1)
		 initVel * cos(angle) (-1) 
		 
		 initVel * cos(angle) * -2 
		 
		 initVel * cos(angle) * (i+2) - initVel * cos(angle) * (i+1) = nextYVel2
		 ( initVel * cos(angle) * (i+2) - initVel * cos(angle) * (i+1) ) - initVel * cos(angle) * (i+2) - initVel * cos(angle) * (i+1) = nextAccel
		 
		 i+1 = i + 1
		 i+2 = i+1 + 1 = i + 2
		 
		 i 
		 
		 ((initVel) * i * sin(angle) - (1/2) *  -persistVar.projGrav * sqr(i)) - ((initVel) * (i+1) * sin(angle) - (1/2) *  -persistVar.projGrav * sqr((i+1)));
		 initVel * sin(angle) (i)  - (1/2) * -persistVar.projGrav (sqr(i)) - i
		 initVel * 1 
		 
		 */
		
		else {
			persistVar.xVel = persistVar.xVel * persistVar.decel;
			persistVar.yVel = persistVar.yVel * persistVar.decel;
		}
		
	}
	
	static drawPath = function() {
		totalTime = 100;
		var _lastXPos = persistVar.x;
		var _lastYPos = persistVar.y;
		
		for (var i = 0; i < totalTime; i += 1 * multi) {
			var _nextXPos = initVel * i * cos(angle) * areAxesOpposite + initPos[0];
			var _nextYPos = (initVel * i * sin(angle) - (1/2) * -persistVar.projGrav * sqr(i)) + initPos[1];
			
			draw_line(_lastXPos, _lastYPos, _nextXPos, _nextYPos);
			
			_lastXPos = _nextXPos;
			_lastYPos = _nextYPos;
		}
		
		var _x1 = initVel * (multi*1) * cos(angle) * areAxesOpposite / parameters.mass;
		var _xVel = _x1;
		
		// For each force find the acceleration and add that onto our previous acceleration
		// If we have a yAccel
		// The moment we throw an object the yAccel will be the initVel + gravity + drag or friction
		// After that it's just gravity + drag or friction
		
		// Friction relies on forces so how would we know how much friction to add
		// We multiply our current net accel by the mass to get the netForce behind it
		// If 
		
		// If we're already moving and we collide and start being affected by friction instead of drag
		// The friction will oppose our applied force BUT OUR APPLIED FORCE ISN'T A FUCKING FORCE IT'S A SPEED
		// I figured it out, there will be friction because there is still a normal force
		
		var _impulseForce = (initVel) * (multi * 1) * sin(angle);
		var _gravForce = (1/2) *  persistVar.projGrav * sqr(multi * 1) * parameters.mass; // individual mass doesn't matter with gravity
		
		// These are our positions
		var _y1 = (initVel) * (multi * 1) * sin(angle) - (1/2) *  -persistVar.projGrav * sqr(multi * 1) * parameters.mass; //- (1/2) * power(multi * 1, 2); 
		var _y2 = (initVel) * (multi * 2) * sin(angle) - (1/2) *  -persistVar.projGrav * sqr(multi * 2) * parameters.mass; //- (1/2) * power(multi * 2, 2);
		var _y3 = (initVel) * (multi * 3) * sin(angle) - (1/2) *  -persistVar.projGrav * sqr(multi * 3) * parameters.mass; //- (1/2) * power(multi * 3, 2);
		
		// These are our speeds (since we already divide by mass, and we don't not want to because gravity isn't divided by mass {we can multiply it by mass})
		var _y12Diff = _y1 - _y2;
		var _y23Diff = _y2 - _y3;
		
		// This is our constant acceleration, no this our force AYY WE FOUND IT
		// We can divide it by mass (MAKE SURE MASS HAS NO INFLUENCE OVER POSITIONS, WE SHOULD MULTIPLY GRAVITY BY MASS THOGUH SO IT HAS NO EFFECT ON IT)
		var _yDiffOfDIff = (_y12Diff - _y23Diff) / parameters.mass;	
		var _yVel = _y1;
		
		_lastXPos = initPos[0];
		_lastYPos = initPos[1];
		
		for (var i = 0; i < totalTime; i += 1 * multi) {
			
			_yVel = _yVel + (_yDiffOfDIff);
			
			var _nextXPos = _lastXPos + _xVel;
			var _nextYPos = _lastYPos + _yVel;
			
			draw_line(_lastXPos, _lastYPos, _nextXPos, _nextYPos);
			
			_lastXPos = _nextXPos;
			_lastYPos = _nextYPos;
		}
	}
	
	static calculateNetAccel = function(_forces) {
		var netAccel = 0;
		
		// Find net acceleration of axis by looping through each force in the array
		for (var i = 0; i < array_length(_forces); i++) {
			netAccel += _forces[i]; // Will have influence of timeMulti and weight here (ACTUALLY WEIGHT PROBABLY JUST IN FRICTION)
		}
		
		return netAccel;
	}
}

function HeldState(_persistVar, _stateMachine, _inputHandler, _anims, _data = undefined) : AbilityState(_persistVar, _stateMachine, _inputHandler, _anims, _data = undefined) constructor {
	static name = "Held";
	static num = SH.HELD;
	holder = undefined;
	
	static sEnter = function(_data) {
		holder = _data;
	}
	
	static updLogic = function() {
		persistVar.x = holder.x;
		persistVar.y = holder.y
	}
}

function ClimbState(_persistVar, _stateMachine, _inputHandler, _anims, _data = undefined) : AbilityState(_persistVar, _stateMachine, _inputHandler, _anims, _data = undefined) constructor {
	static name = "Climb";
	static num = SH.CLIMB;
	surface = undefined; 
	slideDownVel = _data[0];
	slideDownerVel = _data[1];
	getClimbBox = _data[2]; // Maybe still bound to entity, if not turn into m
	atSurfaceBoundary = false;
	
	static sEnter = function(_data) {	
		// So that we know what side to go on
		wallDir = _data[0];
		
		// Reset jumpBuffer so that we don't buffer a jump mid-air, climb, and then jump off because of the buffer
		inputHandler.jumpBuffer = 0;
		
		// Set surface, reset surface, and add surface to colliderArray
		surface = inputHandler.surface;
		inputHandler.surface = undefined; // Avoid glitches 
		
		// Set the enity's x to the edge of the surface's x
		var _surfaceBoundary = (wallDir == 1)? surface.bbox_right : surface.bbox_left;
		
		// So that we don't conserve our previous speed, and we fall
		persistVar.xVel = _surfaceBoundary - persistVar.x;
		atSurfaceBoundary = false;
		
		persistVar.yVel = 0;
	}
	
	static sExit = function() {
		inputHandler.cdClimb = inputHandler.cdClimbMax;
	}

	static updLogic = function() {
		// Only move based on xVel once
		if atSurfaceBoundary {
			persistVar.xVel = 0;
		}
		else {
			var _surfaceBoundary = (wallDir == 1)? surface.bbox_right : surface.bbox_left;
			show_debug_message([persistVar.x, _surfaceBoundary, persistVar.xVel]);
			atSurfaceBoundary = true; 
		}
		
		if inputHandler.wallSlideHeld {
			persistVar.yVel = slideDownerVel;
		}
		else {
			persistVar.yVel = slideDownVel; 
		}
	}
	
	static checkWallJump12 = function() {
		if inputHandler.jumpInput {
			stateMachine.requestChange(SH.WALLJUMP, 1, [wallDir]);
			stateMachine.requestChange(SH.WALLJUMP, 2);
		}
	}
	
	static checkDash12 = function() {
		if inputHandler.dashInputDir != 0 {
			stateMachine.requestChange(SH.DASH, 1);
			stateMachine.requestChange(SH.DASH, 2);
		}
	}
	
	static checkRelease12 = function() {
		if !inputHandler.climbHeld {
			checkAbility1();
			checkAbility2();
		}
	}
	
	/// Check if the bottom of the surface is above us. If so, check for another surface with the current surface as an exemption, if there is a surface change surface, if not change state.
	static checkRange12 = function() {
		if surface.bbox_bottom < persistVar.y {
			var _dirFacing = (persistVar.indexFacing == 0)? 1 : -1;
			if checkSetSurface(getClimbBox(_dirFacing), surface) {			
				changeSurface();
			}
			else {
				checkAbility1();
				checkAbility2();
			}
		}
	}
	
	checkChanges = function() {
		checkWallJump12();
		checkDash12();
		checkRelease12();
		checkRange12();
	}
	
	static changeSurface = function() {
		// Set surface and reset entity surface
		surface = inputHandler.surface;
		inputHandler.surface = undefined; // Avoid glitches 
		
		// Set the enity's x to the edge of the surface's x
		var _surfaceBoundary = (wallDir == 1)? surface.bbox_right : surface.bbox_left;
		
		// So that we don't conserve our previous speed, and we fall
		persistVar.xVel = _surfaceBoundary - persistVar.x;
		atSurfaceBoundary = false;
	}
	
}

function WallJumpState(_persistVar, _stateMachine, _inputHandler, _anims, _data = undefined) : AbilityState(_persistVar, _stateMachine, _inputHandler, _anims, _data = undefined) constructor {
	static name = "Wall Jump";
	static num = SH.WALLJUMP;
	xInitVel = _data[0];
	xFramesToPeak = _data[1];
	xPeak = _data[2];
	xGrav = _data[3];
	yInitVel = _data[4];
	yFramesToPeak = _data[5];
	yPeak = _data[6];
	yGrav = _data[7];
	WJFrame = 0;
	wallDir = 0;

	static sEnter = function(_data) {
		wallDir = _data[0];
		
		persistVar.xVel = xInitVel * wallDir * -1;
		persistVar.yVel = yInitVel;
		
		WJFrame = 0;
	}
	
	static updLogic = function() {
		WJFrame++; // Increment the frame we're on
		
		if inRegion[2] {
			updGrav(yGrav, 1);
		}
		
		if inRegion[1] {
			updGrav(xGrav * wallDir * -1, 0); 
		}
	}
	
	static getAnimUpd = function() {
		var _spriteIndex = undefined;
		var _imageIndex = undefined;
		
		// Change anim if we change direction
		_spriteIndex = activeAnims[faceDir(inputHandler.xInputDir)];
		
		// Change anim if we we ascend or descend
		if(sign(persistVar.yVel) == -1) {
			_imageIndex = 1;
		}
		else {
			_imageIndex = 2;
		}
		
		return [_spriteIndex, _imageIndex, undefined];
	}
	
	/// If we try to move completely stop the parabola on the x axis and just let the player control normally
	static checkWalk1= function() {
		if inputHandler.xInputDir != 0 {
			stateMachine.requestChange(SH.WALK, 1);
		}
	}

	static checkClimb12 = function() {
		if inputHandler.climbHeld and inputHandler.surface != undefined and inputHandler.cdClimb == 0 { 
			// Check if our x value is closer to the left or right bbox boundary
			var _rightDiff = abs(inputHandler.surface.bbox_right) - abs(persistVar.x);
			var _leftDiff = abs(inputHandler.surface.bbox_left) - abs(persistVar.x);
			var _wallDir = ( abs(_rightDiff) > abs(_leftDiff))? -1 : 1;

			if inRegion[1] {
				stateMachine.requestChange(SH.CLIMB, 1, [_wallDir]);
			}
			if inRegion[2] {	
				stateMachine.requestChange(SH.CLIMB, 2, [_wallDir]);
			}
		}
	}
	
	static checkDash12 = function() {
		if inputHandler.dashInputDir != 0 {
			if inRegion[1] {stateMachine.requestChange(SH.DASH, 1);}
			if inRegion[2] {stateMachine.requestChange(SH.DASH, 2);}
		}
	}
	
	/// If we collide with something, release control over the axis we collided on
	static checkCollision12 = function() {
		if inRegion[1] and persistVar.xVel == 0 {
			checkAbility1();
		}
		if inRegion[2] and persistVar.yVel == 0 {
			checkAbility2();
		}
	}
	
	/// Once the frames of our parabola have finished, switch back to the control of other states
	static checkFrame12 = function() {
		if inRegion[1] and WJFrame + 1 == xFramesToPeak * 2 {
			checkAbility1();
		}
		if inRegion[2] and WJFrame + 1 == yFramesToPeak * 2 {
			checkAbility2();
		}
	}
	
	checkChanges = function() {
		checkWalk1();
		checkClimb12();
		checkDash12();
		checkCollision12();
		checkFrame12();
	}
}
