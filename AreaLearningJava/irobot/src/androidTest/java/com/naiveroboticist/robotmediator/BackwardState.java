package com.naiveroboticist.robotmediator;

/**
 * Defines the state in which the iRobot Create is moving backwards.
 * 
 * @author dsieh
 *
 */
public class BackwardState extends BaseState {

    // "stop", "noop" not supported.
    private static final String[] ALLOWED_TRANSITIONS = { 
        "forward",
        "rotate_cw",
        "rotate_ccw",
        "speed_up",
        "slow_down",
        "stop" };

    public BackwardState(ICommand commander) {
        super(commander, ALLOWED_TRANSITIONS);
    }

}
