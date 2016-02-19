package com.naiveroboticist.robotmediator;

import java.io.IOException;

/**
 * This command tells the iRobot Create to slow down a bit.
 * 
 * @author dsieh
 *
 */
public class SlowDownCommand extends BaseRobotCommand {

    public SlowDownCommand() {
    }

    @Override
    public void perform(IRobotStateManager stateManager) throws IOException {
        stateManager.decrementSpeed();
        stateManager.reIssueLastMoveCommand();
    }

}
