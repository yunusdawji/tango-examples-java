package com.naiveroboticist.robotmediator;
import java.io.IOException;

/**
 * This command tells the iRobot Create to speed up a bit.
 * @author dsieh
 *
 */
public class SpeedUpCommand extends BaseRobotCommand {

    public SpeedUpCommand() {
    }

    @Override
    public void perform(IRobotStateManager stateManager) throws IOException {
        stateManager.incrementSpeed();
        stateManager.reIssueLastMoveCommand();
    }

}
