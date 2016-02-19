package com.naiveroboticist.robotmediator;

import java.io.IOException;

/**
 * Created by yunusdawji on 2016-02-17.
 */
public class DockCommand extends BaseRobotCommand {

    public DockCommand() {
    }

    @Override
    public void perform(IRobotStateManager stateManager) throws IOException {
        stateManager.getRobotMotion().dock();
        stateManager.resetLastMoveCommand();
    }

}

