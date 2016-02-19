package com.naiveroboticist.robotmediator;

import java.io.IOException;

/**
 * This command is invoked when the proximity sensor says we are
 * too close to something.
 * 
 * @author dsieh
 *
 */
public class ProximityCommand extends BaseRobotCommand {

    public ProximityCommand() {
    }

    @Override
    public void perform(IRobotStateManager stateManager) throws IOException {
        new Thread(new Backup(stateManager)).start();
    }

}
