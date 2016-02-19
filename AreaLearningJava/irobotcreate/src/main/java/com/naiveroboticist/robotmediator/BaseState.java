package com.naiveroboticist.robotmediator;

import java.io.IOException;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;

/**
 * Base implementation of the iRobotCreate's current state. This
 * class is implemented by each of the actual robot states and
 * defines the allowed transitions away from each of the 
 * supported states.
 * 
 * @author dsieh
 *
 */
public abstract class BaseState {
    public static final String START_STATE = "start";
    
    // Defines the list of transitions that refer back to this state.
    private static final String[] SELF_TRANSITION_COMMANDS = { "speed_up", "slow_down" };
    // Define a format to define the class name of a state.
    private static final String STATE_CLASS_NAME_FMT = "com.naiveroboticist.robotmediator.%sState";
    
    private ICommand mCommander;
    private String[] mAllowedTransitions;

    /**
     * Constructs a new BaseState.
     * 
     * @param commander the object provides the implementation that actually
     * invokes commands on the robot.
     * @param allowedTransitions the array of allowed transitions away from 
     * this state.
     */
    public BaseState(ICommand commander, String[] allowedTransitions) {
        mCommander = commander;
        mAllowedTransitions = allowedTransitions;
    }
    
    /**
     * Get the commander associated with this state.
     * 
     * @return reference to the commander associated with this state.
     */
    public ICommand getCommander() {
        return mCommander;
    }
    
    /**
     * A command to be executed by this state.
     * 
     * @param command the name of the command to be executed.
     * 
     * @return reference to the next state. If the command cannot be invoked by
     * this state, this state will be returned (no transition).
     * 
     * @throws IllegalArgumentException
     * @throws ClassNotFoundException
     * @throws NoSuchMethodException
     * @throws InstantiationException
     * @throws IllegalAccessException
     * @throws InvocationTargetException
     * @throws IOException
     */
    public BaseState command(String command) throws IllegalArgumentException, 
                                                    ClassNotFoundException, 
                                                    NoSuchMethodException, 
                                                    InstantiationException, 
                                                    IllegalAccessException, 
                                                    InvocationTargetException, 
                                                    IOException {
        
        BaseState nextState = this;
        if (supportedTransition(command)) {
            nextState = processCommand(command);
        }
        return nextState;
    }
    
    /**
     * Invokes the specified command on the iRobot Create.
     * 
     * @param command the command to be invoked.
     * 
     * @throws IOException
     * @throws InstantiationException
     * @throws IllegalAccessException
     * @throws ClassNotFoundException
     */
    protected void issueCommand(String command) throws IOException, 
                                                       InstantiationException, 
                                                       IllegalAccessException, 
                                                       ClassNotFoundException {
        
        mCommander.command(BaseRobotCommand.createCommand(command));
    }
    
    /**
     * Processes the specified command and returns the next valid state.
     * 
     * @param command the command to be invoked.
     * 
     * @return the state of the robot after the command was invoked.
     * 
     * @throws ClassNotFoundException
     * @throws NoSuchMethodException
     * @throws IllegalArgumentException
     * @throws InstantiationException
     * @throws IllegalAccessException
     * @throws InvocationTargetException
     * @throws IOException
     */
    protected BaseState processCommand(String command) throws ClassNotFoundException, 
                                                              NoSuchMethodException, 
                                                              IllegalArgumentException, 
                                                              InstantiationException, 
                                                              IllegalAccessException, 
                                                              InvocationTargetException, 
                                                              IOException {
        
        issueCommand(command);
        return nextState(command);
    }
    
    /**
     * Tests the specified transition to see if it is valid for this state.
     * 
     * @param transition the transition to verify.
     * 
     * @return true if this is a valid transition.
     */
    protected boolean supportedTransition(String transition) {
        return inList(mAllowedTransitions, transition);
    }
    
    /**
     * Determines the next state after transitioning with the specified 
     * command.
     * 
     * @param command the command causing the transition.
     * 
     * @return the next state after the transition
     * 
     * @throws ClassNotFoundException
     * @throws NoSuchMethodException
     * @throws IllegalArgumentException
     * @throws InstantiationException
     * @throws IllegalAccessException
     * @throws InvocationTargetException
     */
    protected BaseState nextState(String command) throws ClassNotFoundException, 
                                                         NoSuchMethodException, 
                                                         IllegalArgumentException, 
                                                         InstantiationException, 
                                                         IllegalAccessException, 
                                                         InvocationTargetException {
        
        BaseState state = null;
        if (START_STATE.equals(command)) {
            return new StopState(getCommander());
        } else if (inList(SELF_TRANSITION_COMMANDS, command)) {
            state = this;
        } else {
            String className = String.format(STATE_CLASS_NAME_FMT, StringUtils.camelCase(command));
            Class<?> clazz = Class.forName(className);
            Constructor<?> c = clazz.getDeclaredConstructor(ICommand.class);
            state = (BaseState) c.newInstance(getCommander());
        }
        return state;
    }
    
    
    private boolean inList(String[] list, String value) {
        boolean inThere = false;
        for (int i=0; i<list.length && ! inThere; i++) {
            if (value.equals(list[i])) {
                inThere = true;
            }
        }
        return inThere;
    }
    

}
