package com.naiveroboticist.robotmediator;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;

import com.naiveroboticist.interfaces.IRobotMotion;

/**
 * The interface definition for a state manager for the 
 * iRobot Create.
 * 
 * @author dsieh
 *
 */
public interface IRobotStateManager {

    /**
     * Gets the robot motion interface implementation.
     * 
     * @return the robot motion implementation.
     */
    IRobotMotion getRobotMotion();
    
    /**
     * Resets the current linear velocity back to the application
     * initial settings.
     */
    void resetSpeed();
    
    /**
     * Returns the current speed for the iRobot Create.
     * 
     * @return the current speed.
     */
    int getSpeed();
    
    /**
     * Returns the current rotation speed for the iRobot Create.
     * 
     * @return the current rotation speed.
     */
    int getRotationSpeed();
    
    /**
     * Decrement the current speed by the speed increment.
     */
    void decrementSpeed();
    
    /**
     * Increment the current speed by the speed increment.
     */
    void incrementSpeed();
    
    /**
     * Clears the last move command.
     */
    void resetLastMoveCommand();
    
    /**
     * Sets the last move command.
     * 
     * @param command the new move command.
     */
    void setLastMoveCommand(String command);
    
    /**
     * Re-sends the last move command to the iRobot Create.
     * 
     * @throws IOException
     */
    void reIssueLastMoveCommand() throws IOException;
    
    /**
     * Gets the commander.
     * 
     * @return the commander.
     */
    ICommand getCommander();
    
    /**
     * Processes the specified command.
     * 
     * @param command the command to process.
     * @throws IllegalArgumentException
     * @throws ClassNotFoundException
     * @throws NoSuchMethodException
     * @throws InstantiationException
     * @throws IllegalAccessException
     * @throws InvocationTargetException
     * @throws IOException
     */
    void processCommand(String command) throws IllegalArgumentException, 
                                               ClassNotFoundException, 
                                               NoSuchMethodException, 
                                               InstantiationException, 
                                               IllegalAccessException, 
                                               InvocationTargetException, 
                                               IOException;
}
