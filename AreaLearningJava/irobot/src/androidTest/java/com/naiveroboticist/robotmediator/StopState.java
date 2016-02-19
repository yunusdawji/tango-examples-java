package com.naiveroboticist.robotmediator;

/**
 * This is the state of the iRobot Create where it is
 * doing pretty much nothing (except reading sensor
 * values).
 * 
 * @author dsieh
 *
 */
public class StopState extends BaseState {
    
    // "stop", "noop" not supported.
    private static final String[] ALLOWED_TRANSITIONS = { 
        "forward", 
        "backward",
        "rotate_cw",
        "rotate_ccw",
        "speed_up",
        "slow_down"};

    public StopState(ICommand commander) {
        super(commander, ALLOWED_TRANSITIONS);
    }
    
}
