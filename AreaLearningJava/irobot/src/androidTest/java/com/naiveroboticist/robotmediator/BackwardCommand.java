package com.naiveroboticist.robotmediator;

import java.io.IOException;

/**
 * An implementation of a command to get the iRobotCreate to
 * move backward at the current speed of state manager.
 * 
 * @author dsieh
 *
 */
public class BackwardCommand extends BaseRobotCommand {

    public BackwardCommand() {
    }

    @Override
    public void perform(IRobotStateManager stateManager) throws IOException {
        stateManager.getRobotMotion().drive(-stateManager.getSpeed(), 0);
    }

}
