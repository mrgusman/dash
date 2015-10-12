var power_curve = func () {

    setprop("fdm/jsbsim/elapsed-time", getprop("fdm/jsbsim/elapsed-time") + .25);

    if (getprop("fdm/jsbsim/elapsed-time") == 60) {
        gui.popupTip("Elapsed Time = 1 minute " ~ getprop("fdm/jsbsim/elapsed-time"), 10);
    }
    if (getprop("fdm/jsbsim/elapsed-time") == 120) {
        gui.popupTip("Elapsed Time = 2 minutes " ~ getprop("fdm/jsbsim/elapsed-time"), 10);
    }
    if (getprop("fdm/jsbsim/elapsed-time") == 300) {
        gui.popupTip("Elapsed Time = 5 minutes " ~ getprop("fdm/jsbsim/elapsed-time"), 10);
    }

    if (getprop("fdm/jsbsim/power-curve") == 0)
         setprop("/controls/engines/engine[0]/throttle", getprop("fdm/jsbsim/human-output/healthy60m")/2378);

    if (getprop("fdm/jsbsim/power-curve") == 1)
         setprop("/controls/engines/engine[0]/throttle", getprop("fdm/jsbsim/human-output/athlete60m")/2378);

    if (getprop("fdm/jsbsim/power-curve") == 2)
         setprop("/controls/engines/engine[0]/throttle", getprop("fdm/jsbsim/human-output/healthy500m")/2378);

    if (getprop("fdm/jsbsim/power-curve") == 3)
         setprop("/controls/engines/engine[0]/throttle", getprop("fdm/jsbsim/human-output/athlete1440m")/2378);

	if (getprop("fdm/jsbsim/power-curve") == 4)
         setprop("/controls/engines/engine[0]/throttle", getprop("fdm/jsbsim/human-output/cyclist60m")/2378);

    if (getprop("fdm/jsbsim/power-curve") == 5)
         setprop("/controls/engines/engine[0]/throttle", getprop("fdm/jsbsim/human-output/cyclist27500m")/2378);

    if (getprop("fdm/jsbsim/power-curve") == 6)
         setprop("/controls/engines/engine[0]/throttle", getprop("fdm/jsbsim/human-output/cyclist27500mstep")/2378);

}

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
    if (!getprop("fdm/jsbsim/electric-power")) 
        power_curve();
}

var nasalInit = setlistener("/sim/signals/fdm-initialized", func{
    #aircraft.data.add("fdm/jsbsim/pedal-power");
    #aircraft.data.load();
    var dash_timer = maketimer(0.25, func{global_system_loop()});
    dash_timer.start();
});

