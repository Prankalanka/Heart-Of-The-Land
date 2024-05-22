draw_self();
//draw_line(x, y, x, y - spriteHeight);
for (var i = 0; i < array_length(bugPosArray); i++) {
	draw_circle(bugPosArray[i][0], bugPosArray[i][1], 15, true);
}

//draw_rectangle(x - 100/2, y - 10, x + 100/2, y + 10, false);
