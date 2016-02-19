package com.naiveroboticist.robotmediator;

import java.io.IOException;

/**
 * This command tells the iRobot Create to stop what
 * it's doing.
 * 
 * @author dsieh
 *
 */
public class StopCommand extends BaseRobotCommand {

    public StopCommand() {
    }

    @Override
    public void perform(IRobotStateManager stateManager) throws IOException {
        stateManager.getRobotMotion().stop();
        stateManager.resetSpeed();
        stateManager.resetLastMoveCommand();
    }

}
