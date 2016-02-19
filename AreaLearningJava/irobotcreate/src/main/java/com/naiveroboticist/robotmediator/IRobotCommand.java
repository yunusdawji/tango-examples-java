package com.naiveroboticist.robotmediator;

import java.io.IOException;

/**
 * Implement this interface to perform iRobot Create commands.
 * 
 * @author dsieh
 *
 */
public interface IRobotCommand {

    /**
     * Performs the iRobot Create command in the context of the 
     * robot state manager.
     * 
     * @param stateManager the robot's current state
     * 
     * @throws IOException
     */
    void perform(IRobotStateManager stateManager) throws IOException;
}
