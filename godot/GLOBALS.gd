#         _                        ___         ___        _       
#        | |__  _   _ _ __  _ __  / _ \  __ _ / _ \  __ _/ | __ _ 
#        | '_ \| | | | '_ \| '_ \| | | |/ _` | | | |/ _` | |/ _` |
#        | | | | |_| | |_) | | | | |_| | (_| | |_| | (_| | | (_| |
#        |_| |_|\__, | .__/|_| |_|\___/ \__, |\___/ \__, |_|\__,_|
#               |___/|_|                |___/       |___/         
#                         ...made for https://itch.io/jam/lsdjam-2023
# 
#------------------------------------------------------------------------------    
# MIT License
# 
# Copyright (c) 2023 illegalinstruction
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# 

extends Node

#--- CONSTANTS -----------------------------------------------------------------
const SCREENWIPE_MAX_TICKS : int = 60;
const FPS : float = 48.0;
const GRAVITY : float = 9.8 / FPS;
const COEFF_OF_FRICTION : float =  0.9975;
const MAX_VOLUME : int = 8;
const BGM_FADE_PER_TICK = 0.933;

const DATA_BASE     : String = "user://below_data";
const OPTIONS_PATH  : String = DATA_BASE + "-options";
const SAVEGAME_PATH : String = DATA_BASE + "-savegame";

#--- VARS ----------------------------------------------------------------------
# configuration
var sfx_vol             : int   = 3;
var music_vol           : int   = 3;
var use_joystick        : bool  = true;

# BGM management
var curr_bgm            : int   = 0;
var next_bgm            : int   = 0;
var music_fadeout_clock : int   = 0;

# other 
var ui_font             : Font  = null;

#--- FUNCTIONS -----------------------------------------------------------------

func get_music_vol_in_db():
    if (music_fadeout_clock < SCREENWIPE_MAX_TICKS):
        return linear2db((GLOBALS.music_vol / float(MAX_VOLUME)) * pow(BGM_FADE_PER_TICK,music_fadeout_clock));
    if (curr_bgm != next_bgm):
        return linear2db(0);
    return linear2db(GLOBALS.music_vol / float(MAX_VOLUME));

#-------------------------------------------------------------------------------

func get_sfx_vol_in_db():
    return linear2db(GLOBALS.sfx_vol / float(MAX_VOLUME));

#-------------------------------------------------------------------------------

func save_options_data():
    var fout : File = File.new();

    var error = fout.open(OPTIONS_PATH, fout.WRITE);
    if (error > 0):
        print_debug("could not open options file for writing! error code: " + str(error));
        return; # the show must go on...?
        
    sfx_vol = int(clamp(sfx_vol,0, MAX_VOLUME));
    fout.store_8(sfx_vol);
    music_vol = int(clamp(music_vol, 0, MAX_VOLUME));
    fout.store_8(music_vol);
    fout.store_8(use_joystick);
    fout.close();
    
    return;
    
#-------------------------------------------------------------------------------

func load_options_data():
    var fin : File = File.new();
        
    if (fin.file_exists(OPTIONS_PATH)):
        var error = fin.open(OPTIONS_PATH, fin.READ);
        if (error > 0):
            print_debug("could not open options file for reading! error code: " + str(error));
            return; 
            
        sfx_vol = fin.get_8();
        music_vol = fin.get_8();
        use_joystick = fin.get_8();
        fin.close();
    else:
        save_options_data();
    return;

#-------------------------------------------------------------------------------

func _ready():
    return;
    
