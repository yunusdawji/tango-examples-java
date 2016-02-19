package com.naiveroboticist.robotmediator;

import java.io.IOException;

/**
 * Interface implemented by classes that understand how to deal with
 * the iRobot Create commands.
 * 
 * @author dsieh
 *
 */
public interface ICommand {
    
    void command(IRobotCommand command) throws IOException;

}
