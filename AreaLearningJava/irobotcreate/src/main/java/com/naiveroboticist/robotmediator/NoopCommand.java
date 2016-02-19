package com.naiveroboticist.robotmediator;

import java.io.IOException;

/**
 * A robot command that does nothing. This can be issued by the
 * telep server as a heartbeat.
 * 
 * @author dsieh
 *
 */
public class NoopCommand extends BaseRobotCommand {

    public NoopCommand() {
    }

    @Override
    public void perform(IRobotStateManager stateManager) throws IOException {
        // Do nothing; that's the point.
    }

}
