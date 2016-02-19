package com.naiveroboticist.robotmediator;

import java.io.IOException;

/**
 * A command to have the iRobot Create rotate in a counter-clockwise
 * direction.
 * 
 * @author dsieh
 *
 */
public class RotateCcwCommand extends BaseRobotCommand {

    public RotateCcwCommand() {
    }

    @Override
    public void perform(IRobotStateManager stateManager) throws IOException {
        stateManager.getRobotMotion().rotate(stateManager.getRotationSpeed());
    }

}
