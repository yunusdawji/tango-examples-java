package com.naiveroboticist.robotmediator;

import java.io.IOException;

/**
 * This command is used to initialize the iRobot Create
 * and prepare it for accepting other commands as well as
 * start the stream of sensor data.
 * 
 * @author dsieh
 *
 */
public class StartCommand extends BaseRobotCommand {

    public StartCommand() {
    }

    @Override
    public void perform(IRobotStateManager stateManager) throws IOException {
        stateManager.getRobotMotion().initialize();
    }

}
