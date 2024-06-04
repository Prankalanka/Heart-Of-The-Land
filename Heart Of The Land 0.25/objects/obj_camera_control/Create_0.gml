enum CAM_MANS {
	PLYR,
}

camMan = CAM_MANS.PLYR;

xCam = camera_get_view_x(view_camera[0]);
yCam = camera_get_view_y(view_camera[0]);

targetX = 0;
targetY = 0;

xMidOffset = camera_get_view_width(view_camera[0]) / 2;
yMidOffset = camera_get_view_height(view_camera[0]) / 2;

xVel = 0;
xVelMax = 250;
yVel = 0;

camXAccel = 0;
camYAccel = 0;

bounds = [0,0,0,0];
