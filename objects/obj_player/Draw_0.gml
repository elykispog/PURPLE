draw_self();

// Draw the interaction point
var tx = x;
var ty = y;

switch (facing) {
    case Facing.Up:    ty -= 8; break;
    case Facing.Down:  ty += 8; break;
    case Facing.Left:  tx -= 8; break;
    case Facing.Right: tx += 8; break;
}

draw_set_color(c_red);
draw_circle(tx, ty, 2, false);