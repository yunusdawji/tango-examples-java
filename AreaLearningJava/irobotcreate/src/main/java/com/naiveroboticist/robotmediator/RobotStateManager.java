package com.naiveroboticist.robotmediator;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;

import com.naiveroboticist.interfaces.IRobotMotion;

import android.util.Log;

/**
 * This class is a state machine used to manage the state of the
 * iRobot Create at any point in time.
 * 
 * @author dsieh
 *
 */
public class RobotStateManager implements ICommand, IRobotStateManager {
    private static final String TAG = RobotStateManager.class.getName();
    private static final int STARTING_SPEED = 100; // mm/s
    private static final int SPEED_INCREMENT = 10; // mm/s
    private static final int ROTATION_SPEED = 100; // mm/s

    private int mSpeed = STARTING_SPEED;
    private int mRotationSpeed = ROTATION_SPEED;
    private int mSpeedIncrement = SPEED_INCREMENT;
    private int mStartingSpeed = STARTING_SPEED;
    private String mLastMoveCommand;
    
    private IRobotMotion mRobotMotion;

    private BaseState mCurrentState; 

    /**
     * Construct a new RobotStateManager instance.
     */
    public RobotStateManager() {
        mCurrentState = new InitState(this);
    }
    
    /**
     * Sets the robot writer on the state manager.
     * 
     * @param robotMotion the robot writer.
     */
    public void setRobotWriter(IRobotMotion robotMotion) {
        mRobotMotion = robotMotion;
    }
    
    /**
     * Gets the starting speed.
     * 
     * @return the starting speed.
     */
    public int getStartingSpeed() {
        return mStartingSpeed;
    }
    
    /**
     * Sets the starting speed. As a side effect, the current
     * speed is also set to the starting speed.
     * 
     * @param startingSpeed the starting speed to use.
     */
    public void setStartingSpeed(int startingSpeed) {
        mStartingSpeed = startingSpeed;
        mSpeed = startingSpeed;
    }
    
    /**
     * Gets the current speed.
     * 
     * @return the current speed.
     */
    public int getSpeed() {
        return mSpeed;
    }
    
    /**
     * Sets the current speed.
     * 
     * @param speed the speed to set as current.
     */
    public void setSpeed(int speed) {
        mSpeed = speed;
    }
    
    /**
     * Gets the current rotation speed.
     * 
     * @return the current rotation speed.
     */
    public int getRotationSpeed() {
        return 15;
    }
    
    /**
     * Sets the current rotation speed.
     * 
     * @param rotationSpeed the new current rotation speed.
     */
    public void setRotationSpeed(int rotationSpeed) {
        mRotationSpeed = rotationSpeed;
    }
    
    /**
     * Gets the current speed increment.
     * 
     * @return the current speed increment.
     */
    public int getSpeedIncrement() {
        return mSpeedIncrement;
    }
    
    /**
     * Sets the current speed increment.
     * 
     * @param speedIncrement the new current speed increment.
     */
    public void setSpeedIncrement(int speedIncrement) {
        mSpeedIncrement = speedIncrement;
    }

    /**
     * Processes a specified command. The actual effect of the command
     * will be determined by the current state of the robot. The current
     * state of the robot may be changed as a result of the command.
     * 
     * @param command the command to process
     */
    public void processCommand(String command) throws IllegalArgumentException, 
                                                      ClassNotFoundException, 
                                                      NoSuchMethodException, 
                                                      InstantiationException, 
                                                      IllegalAccessException, 
                                                      InvocationTargetException, 
                                                      IOException {
        
        mCurrentState = mCurrentState.command(command);
    }
    
    /**
     * Gets the commander.
     * 
     * @return the commander.
     */
    public ICommand getCommander() {
        return mCurrentState.getCommander();
    }

    @Override
    public void command(IRobotCommand command) throws IOException {
        command.perform(this);
    }

    @Override
    public IRobotMotion getRobotMotion() {
        return mRobotMotion;
    }

    @Override
    public void resetSpeed() {
        mSpeed = mStartingSpeed;
    }

    @Override
    public void resetLastMoveCommand() {
        mLastMoveCommand = null;        
    }

    @Override
    public void setLastMoveCommand(String command) {
        mLastMoveCommand = command;
    }

    @Override
    public void decrementSpeed() {
        mSpeed -= mSpeedIncrement;
        if (mSpeed < 0) {
            mSpeed = mSpeedIncrement;
        }
    }

    @Override
    public void reIssueLastMoveCommand() throws IOException {
        if (mLastMoveCommand != null) {
            try {
                command(BaseRobotCommand.createCommand(mLastMoveCommand));
            } catch (InstantiationException e) {
                reIssueCommandError(e);
            } catch (IllegalAccessException e) {
                reIssueCommandError(e);
            } catch (ClassNotFoundException e) {
                reIssueCommandError(e);
            }
        }
    }

    @Override
    public void incrementSpeed() {
        mSpeed += mSpeedIncrement;
    }
    
    private void reIssueCommandError(Throwable ex) {
        Log.e(TAG, "Error reissuing last move command", ex);
    }

}
