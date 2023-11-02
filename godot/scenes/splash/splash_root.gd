extends Node2D

#--------------------------------------------------------------

var anim_clock : int            = 0;
const SPLASH_01_START           = 0;
const SPLASH_01_END             = 40;
const SPLASH_02_START           = 70;
const SPLASH_02_END             = 110;
const SPLASH_03_START           = 140;
const SPLASH_03_END             = 180;
const SPLASH_OVERLAY_START      = 210;
const SPLASH_OVERLAY_END        = 250;

#--------------------------------------------------------------

func _ready():
    $Splash01.modulate      = Color(1,1,1,0); 
    $Splash02.modulate      = Color(1,1,1,0); 
    $Splash03.modulate      = Color(1,1,1,0); 
    $black_overlay.modulate = Color(1,1,1,0); 
    anim_clock = 0;
    return;

#--------------------------------------------------------------

func _process(_ignore):
    var alpha_amount : float;
    var tmp : Color;
    anim_clock += 1;
    
    if (anim_clock >= SPLASH_01_START):
        alpha_amount = 1.0 / (float(SPLASH_01_END - SPLASH_01_START));
        tmp = $Splash01.modulate;
        tmp.a += alpha_amount;
        tmp.a = clamp(tmp.a,0.0,1.0);
        $Splash01.modulate = tmp;
    if (anim_clock >= SPLASH_02_START):
        alpha_amount = 1.0 / (float(SPLASH_02_END - SPLASH_02_START));
        tmp = $Splash02.modulate;
        tmp.a += alpha_amount;
        tmp.a = clamp(tmp.a,0.0,1.0);
        $Splash02.modulate = tmp;
    if (anim_clock >= SPLASH_03_START):
        alpha_amount = 1.0 / (float(SPLASH_03_END - SPLASH_03_START));
        tmp = $Splash03.modulate;
        tmp.a += alpha_amount;
        tmp.a = clamp(tmp.a,0.0,1.0);
        $Splash03.modulate = tmp;
    if (anim_clock >= SPLASH_OVERLAY_START):
        alpha_amount = 1.0 / (float(SPLASH_OVERLAY_END - SPLASH_OVERLAY_START));
        tmp = $black_overlay.modulate;
        tmp.a += alpha_amount;
        tmp.a = clamp(tmp.a,0.0,1.0);
        $black_overlay.modulate = tmp;

    if (anim_clock >= SPLASH_OVERLAY_END):
        get_tree().change_scene("res://scenes/mainmenu/mainmenu_root.tscn");
        queue_free();
        
    return;
