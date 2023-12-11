state = EntityStates.base;

event_inherited();

inputHandler = {
	xInputDir : 0,
	checkWalk : function() {
		var _left = keyboard_check(vk_left) or keyboard_check(ord("A"));
	    var _right = keyboard_check(vk_right) or keyboard_check(ord("D"));

	     xInputDir = _right - _left;
	},
	
	jumpInput : false, // For now only one variable, but might seperate into multiple vars for more control
	framesToPeak : 30,
	spaceReleasedSinceJump : true,
	jumpBufferMax : 9,
	jumpBuffer : 0,
	currJumpFrame : 0,
	checkJump : function() {
		jumpInput = false;
			// Jump conditions can be temporary variables in the player data script, encapsulated in some way
			// Too much boilerplate get rid of some vars, and rename the ones we already have if  it's not clear enough
			// Only need to update them in here, will send signal to something else and that will check conditions
			// We don't always need to check the conditions but we always need to check the inputs
			// Coyote is not here since it isn't really to do with input, more context 
		if (!keyboard_check(vk_space)) {
				// (VERY IMPORTANT) Only set false when we have done a valid jump
			spaceReleasedSinceJump = true;
		}
	
		if keyboard_check_pressed(vk_space) {
			jumpBuffer = jumpBufferMax;
		} else {
			jumpBuffer -= 1;
		}

		// Counts up to 31 when holding space, resets only when space is released since we've succesfully jumped
		// if we haven't done a valid jump since we've released space it doesn't increment
		// meaning it won't increment if we're mid-jump, release space and then try to jump again, there's no air jump yet so jumping mid-air does nothing
		if !spaceReleasedSinceJump and currJumpFrame < framesToPeak + 1 {
			currJumpFrame++;
		} else if spaceReleasedSinceJump { 
			currJumpFrame = 0;
		}
		
		// Jump Input Conditions
		if (jumpBuffer > 0) {
			jumpInput = true;
		}
	},
	
	dashInput : 0, // Ranges from -1 to 1 
	dashBuffer : [0, 0], // Input Handler
	dashBufferMax : 18, // Input Handler
	checkDash : function() {
		if (keyboard_check_pressed(vk_left) or keyboard_check_pressed(ord("A"))) // and cooldown
	    {
	        // Reset the other buffer so that we don't dash if we're quickly changing directions
	        dashBuffer[1] = 0;
	        // If we press the key again whilst its buffer is above 0 we call stateTransition and switch states 
	        if dashBuffer[0] > 0 {
				dashInput  = 1;
	        }
	        else {
	            // For the first frame a directional key is pressed, make the dash buffer for the key equal to 10
	            dashBuffer[0] = dashBufferMax;
	        }
	        // If we don't press it decrement the key's buffer each frame until we reach 0
	    } else {
	        dashBuffer[0] -= 1;
	    }
	    if (keyboard_check_pressed(vk_right) or keyboard_check_pressed(ord("D"))) {
	        dashBuffer[0] = 0;
	        if dashBuffer[1] > 0 {
	            dashInput = -1;
	        }
	        else {
	            dashBuffer[1] = dashBufferMax;
	        }
	    } else {
	        dashBuffer[1] -= 1;
	    }
	},
	
	swingInput : false,
	swingObj : undefined,
	checkSwing : function() {
	    // If we're holding w and colliding with the swing object
	    // (will change to more of a collision box with you going different directions depending on your direction and position)
	    if (keyboard_check(vk_up) or keyboard_check(ord("W"))) and obj_player.place_meeting(obj_player.x, obj_player.y, obj_swing) {
	         swingInput = true;
	    }
	},
	/*  VERY IMPORTANT, RUN THIS IN THE FIRST FRAME OF SWINGING
	    swingAngle = point_direction(swingObj.x, swingObj.y, x, y);
	    x = swingObj.x + lengthdir_x(swingDistance, swingAngle);
	    y = swingObj.y + lengthdir_y(swingDistance, swingAngle);
	*/
	
	checkInputs : function() {
		xInputDir = 0;
		jumpInput = false;
		dashInput = 0;
		swingInput = false;
		
		checkWalk();
		checkJump();
		checkDash();
		checkSwing();
	},
	
}


xVel = 0;
yVel = 0;

xVelClamp = 8; // Player Data DONE

// Wanna eventually have an equation that defines what speed you accelerate to 
// and how long it takes to get to that speed
xAccel = 2.5; // Walk State
xDecel = 0.86; // Walk State


// Jump State
peak = -330;
framesToPeak = 30
initJumpVel = (2 * peak) / framesToPeak;
grav = (2 * peak) / sqr(framesToPeak);

coyoteBuffer = 0; // Player Data
coyoteMax = 9; // Player Data

// Player Data
maxHp = 100;
hp = maxHp;
attack = 50;
attackCd = true;

// Only needed inside the swing state except for collision (swing-exclusive collide function? can be done through polymorphism)
swing = undefined;
swingX = 0;
swingY = 0;
swingAngleVelocity = 0;
swingAngle = 0;
swingDistance = 100;
  
// data
isBelow = place_meeting(x, (y + 1), obj_platform);
isAbove = place_meeting(x, (y - 1), obj_platform);

// moveCamera
targetX = x - camera_get_view_width(view_camera[0]) / 2;
targetY = y - 1000;
targetX = lerp(targetX, mouse_x, 0.4);
targetY = lerp(targetY, mouse_y, 0.4);

camX = lerp(camera_get_view_x(view_camera[0]), targetX, 0.3);
camY = lerp(camera_get_view_y(view_camera[0]), targetY, 0.3);

lastDirFaced = 0;
prioStateAnims = [];

#region Old Functions
function walkUpd(_xInputDir) {
    // Alter our acceleration  depending on the situation (there should be one for aerial movement) (maybe not actually)
	
	if _xInputDir != 0 and abs(xVel) <= xVelClamp{
	    // Probably make conditions into vars for more readability
	    if abs(xVel) < 3 {
	        // If we're below an absolute velocity of 3, accelerate slower
	        xDecel = 0.999;
	        xAccel = 0.4;
	    }
	    else if sign(xVel) != _xInputDir and abs(xVel) < xVelClamp {
	        // If we're pressing a different direction than we're moving 
	        // If we're actually pointing a way
	        // If we're below the clamp
	        // Deccelerate slower so we have a little slow down and then switch directions
			// This is how i do lerp, fight me.
	        xDecel = 0.999;
	        xAccel = 0.4;
	    }
		else {
		    // Default
		    xDecel = 0.86;
		    xAccel = (xAccel < 2.5) ? xAccel + 0.05 : 2.5;
		}
	}
	else if abs(xVel) <= xVelClamp {
		// If we aren't pressing a direction
		// Slow down real fast
		xDecel = 0.83;
		xAccel = 2.5;
    } 
	else {
		xDecel = 0.95;
		xAccel = 0.05;
	}

    // Adds the acceleration based on the direction we're pressing to our previous velocity 
    // The decel variable causes what would have been linear acceleration to get lower over time plateuing at a bit above the value of our clamp
    // This makes movement feel smooth and not like you're hitting a random wall and can't go any faster
    var _nextXVel = (xVel + xAccel * 1.2 * _xInputDir) * xDecel;

    if abs(xVel) > xVelClamp {
        // If we're going above the limit and in the same direction as before
        // Don't add anything to the acceleration 
        _nextXVel = xVel * xDecel;
        xVel = _nextXVel;
    } /*else if abs(xVel) > xVelClamp and _xInputDir != sign(xVel) {
        // If we're going above the limit and not in the same direction
        // Add acceleration allowing for players to cut their dashes short
        _nextXVel = (xVel + xAccel * 1.2 * _xInputDir) * xDecel;
        xVel = _nextXVel;
    } */ 
	else {
        // Otherwise use the normal acceleration and clamp
        xVel = (abs(_nextXVel) < xVelClamp) ? _nextXVel : xVelClamp * _xInputDir;
    }
	floorXVel();
}

function swingCheck() {
    // If we're holding w and colliding with the swing object
    // (will change to more of a collision box with you going different directions depending on your direction and position)
    if (keyboard_check(vk_up) or keyboard_check(ord("W"))) and place_meeting(x, y, obj_swing) {
        // If we are below the swing
        if y > obj_swing.y {
            stateTransition(EntityStates.swing);
            // Define the swing we collided with as our swing and find the angle between it and the player
            swing = obj_swing;
            swingAngle = point_direction(swing.x, swing.y, x, y);
            x = swing.x + lengthdir_x(swingDistance, swingAngle);
            y = swing.y + lengthdir_y(swingDistance, swingAngle);
        }
    }
}

function swingUpd() {
    // Make sure we're holding up or w
    // Declared outside so we can use in scope of above if statement
    var _swingAngleAcceleration = 0;

    // Adjust acceleration based on angle
    // If we're near parallel to gravity
    if (swingAngle < 300 and swingAngle > 240) or(swingAngle < 120 and swingAngle > 60) {
        // Make the multiplier of the acceleration stronger
        // We use dcos function because we are using degrees and also
        // Cosine gives us behaviour where angles that are analagous to up and down in gamemaker
        // return a smaller result, so we'll be slowest when we're directly above or below the swing
        // Emulating real life
        _swingAngleAcceleration = -0.2 * dcos(swingAngle);
    } else {
        _swingAngleAcceleration = -0.2 * dcos(swingAngle);
    }

    // Adjust acceleration based on x and y velocity when on the first swing frame
    if swingAngleVelocity == 0 {
        _swingAngleAcceleration += xVel * 0.325;
        _swingAngleAcceleration += yVel * 0.325;
    }

    swingAngleVelocity += _swingAngleAcceleration;
    swingAngle += swingAngleVelocity;
    swingAngleVelocity *= 0.99 // Dampen velocity, eventually reaching 0

    // Calculate where our next position on the circle should be
    swingX = swing.x + lengthdir_x(swingDistance, swingAngle);
    swingY = swing.y + lengthdir_y(swingDistance, swingAngle);

    // Find the difference between our current position and future position
    // Assign that as the velocity variables so that x and y update functions handle collision
    xVel = swingX - x;
    yVel = swingY - y;

    if !(keyboard_check(vk_up) or keyboard_check(ord("W"))) {
        magnitude = sqrt(sqr(xVel) + sqr(yVel));
        /*
        magnitude = sqrt(sqr(xVel) + sqr(yVel));
        x3 = swing.x - x;
        y3 = swing.y - y;
        m1 = x3/y3;
        m2 = -1(1/m1);
        yDir = sign(yVel);
        c = y - m2 * x;
        x = 
        yVel = m2 * (x + magnitude) + c;
        */

        yVel = magnitude * 2 * sign(yVel);
        xVel = magnitude * 4 * sign(xVel);
        stateTransition(EntityStates.base);
    }
}

function checkHp() {
    if hp <= 0 {
        obj_destroyer.destroy_obj(id);
    }
}

function attackExec() {
    mouseAngle = point_direction(x, y, mouse_x, mouse_y);

    // Find the vector between the mouse and the player
    mx = mouse_x - x;
    my = mouse_y - y;

    // FInd the magnitude of that vector
    mag = sqrt(sqr(mx) + sqr(my));

    // Normalise that vector and then multiply it by 50
    // This let's us take the direction of the player to the mouse
    // But clamp that distance to 50 pixels
    fx = (mx / mag) * 50;
    fy = (my / mag) * 50;

    // Create an instance of the hit object at a 50 pixel offset from the player
    instance_create_layer(x + fx, y + fy, "Instances", obj_hit, {
        image_angle: mouseAngle - 90, // Rotate the image, not the object
        image_xscale: 0.3,
        image_yscale: 0.3,
        // The object needs the offset values, so we set them here
        fx: fx,
        fy: fy
    });

    // Reset the attack cooldown
    attackCd = false;
    alarm[0] = 30;
}

function moveCamera() {
	
	
    targetX = x - camera_get_view_width(view_camera[0]) / 1.75;
    targetY = y - camera_get_view_height(view_camera[0]) / 1.25;
	
	// Lerp between mouse and player
    targetX = lerp(targetX, mouse_x, 0.2);
    targetY = lerp(targetY, mouse_y, 0.2);

    camX = lerp(camera_get_view_x(view_camera[0]), targetX, 0.075);
    camY = lerp(camera_get_view_y(view_camera[0]), targetY, 0.15);

	


    camera_set_view_pos(view_camera[0], camX, camY);
}
#endregion
#region New Functions

/// Take the direction we want to face in and turn it into an index for our entity's anim array
facingDirection = function (_velOrDir) {
	switch (_velOrDir) {
	    case 1:
	        lastDirFaced = 0;
			return 0;
	        break;
	    case -1:
	        lastDirFaced = 1;
			return 1;
	        break;
		case 0:
			return lastDirFaced;
			break;
		case 2: 
			// Last dir is 0 for compatibility with other states
			// but we can still have multiple animations for specific states
			lastDirFaced = 0;
			return 2;
			break;
		case -2: 
			lastDirFaced = 1;
			return 3;
			break;
	}
}

updYVel = function(_yInputDir) {
	// Fall faster when you aren't continuing a jump but you're still going upwards (variable/min jump height) 
	if (inputHandler.currJumpFrame == 0 or inputHandler.currJumpFrame == 31) and sign(yVel) == -1{
	    yVel -= grav * 2;
	}
	// The only other case is _yInputDir being 1 whilst you're going down or continuing a jump, 
	// (not starting one, cuz that's handled by the jump state) but else is more optimal
	else if yVel < 25 {
		//show_debug_message("aa");
	    yVel -= grav;
	}
}

updCoyote = function() { 
	// The coyote buffer is set to a max value every time we're grounded
    // but decremented every frame we're in the air, until it reaches 0
    if coyoteBuffer > 0 {
        // Decrement it
        coyoteBuffer--;
    }
}
#endregion

// The struct that changes the player's state, calling states' enter and exit functions
stateMachine = new EntityStateMachine();

// STATES
idleState  = new IdleState(id, [spr_idle_right, spr_idle_left]);
moveState = new MoveState(id, [spr_walk_right, spr_walk_left, spr_idle_right, spr_idle_left]);
inAirState = new InAirState(id, [spr_jump_right, spr_jump_left]);
jumpState = new JumpState(id, [spr_jump_right, spr_jump_left]);
dashState = new DashState(id, [spr_idle_right, spr_idle_left]);

// INITIALISE THE STATE MACHINE
var _startingStates = [idleState, idleState, idleState];
stateMachine.init(_startingStates);