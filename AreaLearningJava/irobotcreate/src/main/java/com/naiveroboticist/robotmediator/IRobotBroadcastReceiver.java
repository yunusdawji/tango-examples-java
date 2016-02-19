package com.naiveroboticist.robotmediator;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

/**
 * Implementation of an Android BroadcastReceiver that receives robot
 * command messages from other activities in the application.
 * 
 * You have to remember to set the robot state manager on this class 
 * after you have established a connection to the iRobot Create.
 * 
 * @author dsieh
 *
 */
public class IRobotBroadcastReceiver extends BroadcastReceiver {
    
    private static final String TAG = IRobotBroadcastReceiver.class.getName();
    // The command tag supported by this broadcast receiver.
    public static final String COMMAND_NAME = "com.naiveroboticist.COMMAND_NAME";
    
    private IRobotStateManager mRobotStateManager;

    /**
     * Constructs a new IRobotBroadcastReceiver instance.
     */
    public IRobotBroadcastReceiver() {
    }
    
    /**
     * Sets the robot state manager on the receiver.
     * 
     * @param robotStateManager the robot state manager.
     */
    public void setRobotStateManager(RobotStateManager robotStateManager) {
        mRobotStateManager = robotStateManager;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        if (IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT.equals(action)) {
            String command = intent.getStringExtra(COMMAND_NAME);
            try {
                if (mRobotStateManager != null) {
                    mRobotStateManager.processCommand(command);
                } else {
                    Log.w(TAG, "RobotStateManager is not yet configured");
                }
            } catch (Exception e) {
                Log.e(TAG, "Error issuing robot command: " + command, e);
            }
        }
    }

}
