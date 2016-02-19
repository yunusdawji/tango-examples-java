package com.naiveroboticist.robotmediator;

/**
 * The state of the iRobot Create when the proximity sensor has
 * gone off.
 * 
 * @author dsieh
 *
 */
public class ProximityState extends BaseState {

    private static final String[] ALLOWED_TRANSITIONS = { "stop" }; 

    public ProximityState(ICommand commander) {
        super(commander, ALLOWED_TRANSITIONS);
    }

}
