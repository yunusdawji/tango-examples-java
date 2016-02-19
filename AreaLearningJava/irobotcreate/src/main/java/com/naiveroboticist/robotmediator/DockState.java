package com.naiveroboticist.robotmediator;

/**
 * Created by yunusdawji on 2016-02-18.
 */
public class DockState extends BaseState {

    // "stop", "noop" not supported.
    private static final String[] ALLOWED_TRANSITIONS = {
            "backward"};

    /**
     * Constructs a new BaseState.
     *
     * @param commander          the object provides the implementation that actually
     *                           invokes commands on the robot.
     * @param allowedTransitions the array of allowed transitions away from
     */
    public DockState(ICommand commander, String[] allowedTransitions) {
        super(commander, allowedTransitions);
    }
}
