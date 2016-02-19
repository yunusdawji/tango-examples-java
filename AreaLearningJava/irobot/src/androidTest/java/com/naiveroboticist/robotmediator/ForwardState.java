package com.naiveroboticist.robotmediator;

/**
 * Defines the state when the iRobot Create is currently
 * moving forward.
 * 
 * @author dsieh
 *
 */
public class ForwardState extends BaseState {

    // "stop", "noop" not supported.
    private static final String[] ALLOWED_TRANSITIONS = { 
        "backward",
        "bump",
        "proximity",
        "rotate_cw",
        "rotate_ccw",
        "speed_up",
        "slow_down",
        "stop" };

    public ForwardState(ICommand commander) {
        super(commander, ALLOWED_TRANSITIONS);
    }

}
