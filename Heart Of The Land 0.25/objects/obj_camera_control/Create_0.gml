enum CAM_MANS {
	PLYR,
}

camMan = CAM_MANS.PLYR;

xCam = 0;
yCam = 0;

xCamClamp = 125;

xMidOffset = camera_get_view_width(view_camera[0]) / 2 ;
yMidOffset = camera_get_view_width(view_camera[0]) / 2;