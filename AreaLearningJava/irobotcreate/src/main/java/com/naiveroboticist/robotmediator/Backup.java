package com.naiveroboticist.robotmediator;

import java.io.IOException;

import android.util.Log;

/**
 * This runnable implements the logic for having the robot
 * move backward for one second then stopping.
 * 
 * @author dsieh
 *
 */
public class Backup implements Runnable {
    
    private static final String TAG = Backup.class.getName();
    
    private IRobotStateManager mRobotStateManager;
    private static IRobotCommand STOP_COMMAND = new StopCommand();
    private static IRobotCommand BACKWARD_COMMAND = new BackwardCommand();

    public Backup(IRobotStateManager robotStateManager) {
        mRobotStateManager = robotStateManager;
    }

    @Override
    public void run() {
        try {
            mRobotStateManager.getCommander().command(STOP_COMMAND);
            mRobotStateManager.getCommander().command(BACKWARD_COMMAND);
            Thread.sleep(1000);
        } catch (IOException e) {
            Log.e(TAG, "Error stopping and going backward on bump", e);
        } catch (InterruptedException e) {
            Log.e(TAG, "Error waiting for a second after bump", e);
        } finally {
            try {
                mRobotStateManager.processCommand("stop");
            } catch (Exception e) {
                Log.e(TAG, "Unable to perform the final stop", e);
            }
        }
    }

}
