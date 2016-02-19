package com.naiveroboticist.robotmediator;

import java.io.IOException;

/**
 * An implementation of a command to get the iRobot Create
 * to react to a bump on it's front sensors.
 * 
 * @author dsieh
 *
 */
public class BumpCommand extends BaseRobotCommand {

    public BumpCommand() {
    }

    @Override
    public void perform(IRobotStateManager stateManager) throws IOException {
        new Thread(new Backup(stateManager)).start();
    }

}
