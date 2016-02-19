package com.naiveroboticist.robotmediator;

import java.io.IOException;

/**
 * An implementation of a command to get the iRobot Create
 * to move forward.
 * 
 * @author dsieh
 *
 */
public class ForwardCommand extends BaseRobotCommand {

    public ForwardCommand() {
    }

    @Override
    public void perform(IRobotStateManager stateManager) throws IOException {
        stateManager.getRobotMotion().drive(stateManager.getSpeed(), 0);
        stateManager.setLastMoveCommand("forward");
    }

}
