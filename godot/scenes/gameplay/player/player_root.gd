extends KinematicBody

#---CONSTANTS-------------------------------------------------------------------

const MAX_LOOK_UP_DOWN = 75.0;

#---VARIABLES-------------------------------------------------------------------

# player movement
var y_angle : float         = 0.0;
var horz_velocity : Vector2 = Vector2.ZERO;
var vert_velocity : float   = 0.0;
var max_speed : float;

# input handling
var mouse_sensitivity : float = 0.0045;

#sound handling
var footstep_timer : int;

# view bob
var bob_cam_x_offset : float;
var bob_cam_y_offset : float;

#---FUNCTIONS-------------------------------------------------------------------

func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
    return;

#----------------------------------------------------------------------

func _input(event):
    if (event is InputEventMouseMotion):
        if ($spatl_yrotator != null):
            $spatl_yrotator.rotate_y(event.relative.x * -mouse_sensitivity); 
            y_angle = $spatl_yrotator.rotation.y;
        if ($spatl_yrotator/spatl_xrotator != null):
            $spatl_yrotator/spatl_xrotator.rotate_x(event.relative.y * mouse_sensitivity); 
            $spatl_yrotator/spatl_xrotator.rotation.x = clamp($spatl_y_rotator/spatl_xrotator.rotation.x, 
                                                            deg2rad(-MAX_LOOK_UP_DOWN), 
                                                            deg2rad(MAX_LOOK_UP_DOWN)
                                                        );

    if (event is InputEventMouseButton):
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
        OS.window_fullscreen = true;
    return;

#----------------------------------------------------------------------
