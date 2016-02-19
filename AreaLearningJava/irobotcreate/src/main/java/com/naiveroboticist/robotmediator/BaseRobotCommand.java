package com.naiveroboticist.robotmediator;

/**
 * Base class for all iRobot Create commands.
 * 
 * @author dsieh
 *
 */
public abstract class BaseRobotCommand implements IRobotCommand {

    // The string format to construct a Commmand class from a command name.
    private static final String CMD_CLASS_NAME_FMT = "com.naiveroboticist.robotmediator.%sCommand";

    /**
     * Constructs a new BaseRobotCommand.
     */
    public BaseRobotCommand() {
    }

    /**
     * Create the command object associated with the specified command string.
     * 
     * @param command the name of the command.
     * 
     * @return reference to the instantiated command object.
     * 
     * @throws InstantiationException
     * @throws IllegalAccessException
     * @throws ClassNotFoundException
     */
    public static IRobotCommand createCommand(String command) throws InstantiationException, 
                                                                     IllegalAccessException, 
                                                                     ClassNotFoundException {
        
        String className = String.format(CMD_CLASS_NAME_FMT, StringUtils.camelCase(command));
        Class<?> clazz = Class.forName(className);
        return (IRobotCommand) clazz.newInstance();
    }

}
