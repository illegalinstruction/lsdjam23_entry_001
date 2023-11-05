extends KinematicBody

#---CONSTANTS-------------------------------------------------------------------

const MAX_LOOK_UP_DOWN  : float = 75.0;
const MAX_JUMP_TIMER    : int   = 4;    

#---VARIABLES-------------------------------------------------------------------

# player movement
var horz_velocity : Vector2 = Vector2.ZERO;
var vert_velocity : float   = 0.0;
var max_speed : float;

# input handling
var mouse_sensitivity : float = 0.0;
var jump_button_timer : int = 0; # used to manage jump 'aftertouch'

#sound handling
var footstep_timer : int;

# view bob
var bob_cam_x_offset : float;
var bob_cam_y_offset : float;

#---FUNCTIONS-------------------------------------------------------------------

func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
    mouse_sensitivity = float(GLOBALS.mouse_sensitivity) / 1000.0;
    set_process(true);    
    return;

#----------------------------------------------------------------------
# note: ONLY mouselook is handled here - actuall movement 
# happens in _process()

func _input(event):
    if (GLOBALS.use_joystick):
        return;
    
    if (event is InputEventMouseMotion):
        if ($spatl_yrotator != null):
            $spatl_yrotator.rotate_y(event.relative.x * -mouse_sensitivity); 
            
        if ($spatl_yrotator/spatl_xrotator != null):
            $spatl_yrotator/spatl_xrotator.rotate_x(event.relative.y * mouse_sensitivity); 
            
            # don't let player look too far up or down
            $spatl_yrotator/spatl_xrotator.rotation.x = clamp($spatl_yrotator/spatl_xrotator.rotation.x, 
                                                            deg2rad(-MAX_LOOK_UP_DOWN), 
                                                            deg2rad(MAX_LOOK_UP_DOWN)
                                                        );

    return;

#----------------------------------------------------------------------
# movement and playing the footstep sound happens here

func _process(_ignore):
    var horz_movement_tmp   : Vector2 = Vector2.ZERO;
    var on_floor            : bool = is_on_floor();
    
    #---------------------------------
    # movement and looking: joystick
    if (GLOBALS.use_joystick):
        # left analogue ----------------                                
        var joy_tmp : Vector2 = Vector2(Input.get_joy_axis(0, JOY_ANALOG_LX), 
                                        Input.get_joy_axis(0, JOY_ANALOG_LY)
                                );
        
        # is this user-commanded input or 360 stick drift?                            
        if (joy_tmp.length() > GLOBALS.STICK_DEAD_ZONE):
            # yep - valid, prepare to move based on it     
            horz_movement_tmp = joy_tmp;    

        # right analogue ---------------                                
        joy_tmp = Vector2(Input.get_joy_axis(0, JOY_ANALOG_RX), 
                          Input.get_joy_axis(0, JOY_ANALOG_RY)
                         );

        # is this user-commanded input or 360 stick drift?                            
        if (joy_tmp.length() > GLOBALS.STICK_DEAD_ZONE):
            # yes, looking & aiming     
            $spatl_yrotator.rotate_y(deg2rad((180.0 * joy_tmp.x) / GLOBALS.TICKS_PER_SEC));   
            $spatl_yrotator/spatl_xrotator.rotate_x(deg2rad((180.0 * joy_tmp.y) / GLOBALS.TICKS_PER_SEC));   
            $spatl_yrotator/spatl_xrotator.rotation.x = clamp($spatl_yrotator/spatl_xrotator.rotation.x, 
                                                            deg2rad(-MAX_LOOK_UP_DOWN), 
                                                            deg2rad(MAX_LOOK_UP_DOWN)
                                                        );
    #---------------------------------
    # movement: keys
    else:
        # movement key input
        if (Input.is_action_pressed("GAMEPLAY_FWD")):
            horz_movement_tmp.y -= 1.0;
        if (Input.is_action_pressed("GAMEPLAY_BKWD")):
            horz_movement_tmp.y += 1.0;
        if (Input.is_action_pressed("GAMEPLAY_L")):
            horz_movement_tmp.x -= 1.0;
        if (Input.is_action_pressed("GAMEPLAY_R")):
            horz_movement_tmp.x += 1.0;

    #---------------------------------
    # are we airborne? don't let the player 
    # tweak their jump at full walking speed
    if (not on_floor):
        horz_movement_tmp *= GLOBALS.JUMP_HORZ_REDUCTION_FACTOR;
    
    # account for camera angle
    horz_movement_tmp = horz_movement_tmp.rotated($spatl_yrotator.rotation.y);
        
    # actually walk
    horz_velocity += horz_movement_tmp;
    horz_velocity = horz_velocity.limit_length(GLOBALS.MAX_WALK_SPEED);
    
    #--- jumping and falling ---------
    if (Input.is_action_pressed("GAMEPLAY_JUMP")):
        if ((on_floor) or ((jump_button_timer > 0) and (jump_button_timer < MAX_JUMP_TIMER))):
            # propelled upwards
            # the timer allows for 'aftertouch' on the jump button
            vert_velocity = GLOBALS.JUMP_INITIAL_VERT_SPEED;
        
    # combine horz and vert elements, apply 'em
    var combined_veloc : Vector3 = Vector3(horz_velocity.x, horz_velocity.y, vert_velocity);
    move_and_slide(combined_veloc, Vector3.UP, true, 4, deg2rad(45), false);
    
    # whether we're on the ground may have changed - sample it again
    on_floor = is_on_floor();
    
    if (not on_floor):
        # already airborne - don't let the player double jump
        # or aftertouch after 4 frames have elapsed
        jump_button_timer += 1;
    else:
        jump_button_timer = 0;
 
        # apply friction
        horz_velocity = horz_velocity * GLOBALS.COEFF_OF_FRICTION;
        
        # not actively walking? slow down a little quicker
        if ((horz_movement_tmp.length() == 0.0) and (on_floor)):
            horz_velocity = horz_velocity * GLOBALS.COEFF_OF_FRICTION;
            footstep_timer = 0;
            

    return;

#-------------------------------------------------------------------------------
