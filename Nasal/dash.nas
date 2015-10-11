var pedal = func {
	#space = pedal
        if (getprop("devices/status/keyboard/event/key") != 32  and getprop("/controls/engines/engine[0]/throttle") > 0){
            setprop("/controls/engines/engine[0]/throttle", getprop("/controls/engines/engine[0]/throttle") - .01);
        }
	if (getprop("devices/status/keyboard/event/key") == 32 and !getprop("devices/status/keyboard/event/pressed")){
            if (getprop("/controls/engines/engine[0]/throttle") < 1)
	        setprop("/controls/engines/engine[0]/throttle", getprop("/controls/engines/engine[0]/throttle") + .01);
            settimer(func {
               setprop("devices/status/keyboard/event/key", 0);
            }, .1);
	}
        if (getprop("fdm/jsbsim/pedal-power"))
	    settimer( func { pedal() } , .1 );
}

var powerCurve = func (v) {

    if (v == 1) {
        setprop("fdm/jsbsim/elapsed-time", 0);
        v = 0;
    } else
        setprop("fdm/jsbsim/elapsed-time", getprop("fdm/jsbsim/elapsed-time") + 1);

    gui.popupTip(getprop("fdm/jsbsim/elapsed-time"), 10);

    if (getprop("fdm/jsbsim/elapsed-time") == 60) {
        gui.popupTip("Elapsed Time = 1 minute " ~ getprop("fdm/jsbsim/elapsed-time"), 10);
    }
    if (getprop("fdm/jsbsim/elapsed-time") == 120) {
        gui.popupTip("Elapsed Time = 2 minutes " ~ getprop("fdm/jsbsim/elapsed-time"), 10);
    }
    if (getprop("fdm/jsbsim/elapsed-time") == 300) {
        gui.popupTip("Elapsed Time = 5 minutes " ~ getprop("fdm/jsbsim/elapsed-time"), 10);
    }

    if (v == 0)
        settimer( func {powerCurve(0) } , 1 );
}

var nasalInit = setlistener("/sim/signals/fdm-initialized", func{
    #aircraft.data.add("fdm/jsbsim/pedal-power");
    #aircraft.data.load();
    if (getprop("fdm/jsbsim/pedal-power"))
        pedal();
 });

############################################## rain
var weather_effects_loop = func {
    var airspeed = getprop("/velocities/airspeed-kt");

    # DaSH
    var airspeed_max = 60;

    if (airspeed > airspeed_max) {airspeed = airspeed_max;}

    airspeed = math.sqrt(airspeed/airspeed_max);

    # DaSH
    var splash_x = -0.1 - 2.0 * airspeed;
    var splash_y = 0.0;
    var splash_z = 1.0 - 1.35 * airspeed;

    setprop("/environment/aircraft-effects/splash-vector-x", splash_x);
    setprop("/environment/aircraft-effects/splash-vector-y", splash_y);
    setprop("/environment/aircraft-effects/splash-vector-z", splash_z);
}

############################################
# Global loop function
# If you need to run nasal as loop, add it in this function
############################################
var global_system_loop = func{
    weather_effects_loop();
}

var nasalInit = setlistener("/sim/signals/fdm-initialized", func{
    var dash_timer = maketimer(0.25, func{global_system_loop()});
   dash_timer.start();
});
