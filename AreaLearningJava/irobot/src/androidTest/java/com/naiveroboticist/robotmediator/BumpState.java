package com.naiveroboticist.robotmediator;

/**
 * The state of the iRobot Create when it is currently reacting to
 * a bump on it's front sensors.
 * 
 * @author dsieh
 *
 */
public class BumpState extends BaseState {
    
    private static final String[] ALLOWED_TRANSITIONS = { "stop" }; 

    public BumpState(ICommand commander) {
        super(commander, ALLOWED_TRANSITIONS);
    }

}
