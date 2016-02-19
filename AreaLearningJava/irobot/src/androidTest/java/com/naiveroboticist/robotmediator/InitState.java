package com.naiveroboticist.robotmediator;

/**
 * This is the initial state of the robot before everything
 * is ready to go.
 * 
 * @author dsieh
 *
 */
public class InitState extends BaseState {

    private static final String[] ALLOWED_TRANSITIONS = { 
        START_STATE };

    public InitState(ICommand commander) {
        super(commander, ALLOWED_TRANSITIONS);
    }

}
