package com.naiveroboticist.robotmediator;

import java.io.IOException;

/**
 * A command to have the iRobot Create rotate in a clockwise
 * direction.
 * 
 * @author dsieh
 *
 */
public class RotateCwCommand extends BaseRobotCommand {

    public RotateCwCommand() {
    }

    @Override
    public void perform(IRobotStateManager stateManager) throws IOException {
        stateManager.getRobotMotion().rotate(-stateManager.getRotationSpeed());
    }

}
