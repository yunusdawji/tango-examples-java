package com.naiveroboticist.robotmediator;

import android.content.Context;
import android.content.Intent;
import android.os.CountDownTimer;

import com.google.atap.tangoservice.TangoPoseData;
import com.mobileinnovationlab.navigationframework.ControlAction;
import com.mobileinnovationlab.navigationframework.Orientation;
import com.mobileinnovationlab.navigationframework.WayFinder;
import com.mobileinnovationlab.navigationframework.interfaces.WayFinderAction;

import java.util.List;

/**
 * Created by yunusdawji on 2016-02-10.
 */
public class IRobotController implements WayFinderAction {

    private WayFinder mWayFinder;
    private Context mContext;

    private boolean isPerformingAction = false;

    //lastaction
    // 0 - stationary
    // 1 - moving straight
    // 2 - moving left
    // 3 - moving right
    // 4 - rotating left
    // 5 - rotating right
    private int lastAction = 0;

    public IRobotController(Context context, Object sharedLock){
        mWayFinder = new WayFinder(context, false, true, this, sharedLock, false);
        mContext.startService(new Intent(IRobotCommunicationService.class.getName()));
    }

    @Override
    public void motionSystem(String action, double distance, TangoPoseData poseData) {

        if(action.equals("go right") && !isPerformingAction ){
            lastAction = 3;
            goRight();
        }
        else if(action.equals("go straight") && !isPerformingAction && lastAction!=1){
            lastAction = 1;
            goStraight();
        }
        else if(action.equals("go left") && !isPerformingAction){
            lastAction = 2;
            goLeft();
        }
        else if(action.equals("Keep Rotating to LEFT") && !isPerformingAction && lastAction!=4){
            lastAction = 4;
            rotateLeft();
        }
        else if(action.equals("Keep Rotating to RIGHT") && !isPerformingAction && lastAction!=5){
            lastAction = 5;
            rotateRight();
        }else if(action.equals("Destination Reached") && !isPerformingAction && lastAction!=0){
            stop();
        }

    }

    @Override
    public void control(List<Orientation> list, ControlAction action) {
        if(action.getActionType().equals(ControlAction.GO)){
            mWayFinder.start(list);
        }else if(action.getActionType().equals(ControlAction.STOP)){
            mWayFinder.stop();
        }
    }

    @Override
    public void currentPosition(TangoPoseData poseData, boolean isRelocalized) {

    }

    void goRight(){

        isPerformingAction = true;

        //get the instance and get the state manager
        Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
        intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "rotate_cw");
        mContext.sendBroadcast(intent);


        new CountDownTimer(1700, 1000) {

            public void onTick(long millisUntilFinished) {

            }

            public void onFinish() {
                //get the instance and get the state manager
                Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
                intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "forward");
                mContext.sendBroadcast(intent);

                new CountDownTimer(1000, 1000) {

                    public void onTick(long millisUntilFinished) {

                    }

                    public void onFinish() {
                        //get the instance and get the state manager
                        Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
                        intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "rotate_ccw");
                        mContext.sendBroadcast(intent);


                        new CountDownTimer(1700, 1000) {

                            public void onTick(long millisUntilFinished) {

                            }

                            public void onFinish() {
                                //get the instance and get the state manager
                                Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
                                intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "stop");
                                mContext.sendBroadcast(intent);

                                isPerformingAction = false;
                            }
                        }.start();
                    }
                }.start();

            }
        }.start();
    }

    void goStraight(){
        isPerformingAction = true;
        Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
        intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "forward");
        mContext.sendBroadcast(intent);
        isPerformingAction = false;
    }

    void goLeft(){
        isPerformingAction = true;
        Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
        intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "rotate_ccw");
        mContext.sendBroadcast(intent);


        new CountDownTimer(1700, 1000) {

            public void onTick(long millisUntilFinished) {

            }

            public void onFinish() {
                //get the instance and get the state manager
                Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
                intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "forward");
                mContext.sendBroadcast(intent);

                new CountDownTimer(1000, 1000) {

                    public void onTick(long millisUntilFinished) {

                    }

                    public void onFinish() {
                        //get the instance and get the state manager
                        Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
                        intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "rotate_cw");
                        mContext.sendBroadcast(intent);


                        new CountDownTimer(1700, 1000) {

                            public void onTick(long millisUntilFinished) {

                            }

                            public void onFinish() {
                                //get the instance and get the state manager
                                Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
                                intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "stop");
                                mContext.sendBroadcast(intent);
                                isPerformingAction = false;
                            }
                        }.start();
                    }
                }.start();

            }
        }.start();

    }

    void rotateLeft(){
        isPerformingAction = true;
        Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
        intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "rotate_ccw");
        mContext.sendBroadcast(intent);
        isPerformingAction = false;
    }

    void rotateRight(){
        isPerformingAction = true;
        Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
        intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "rotate_cw");
        mContext.sendBroadcast(intent);
        isPerformingAction = false;
    }

    void stop(){
        isPerformingAction = true;
        Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
        intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "stop");
        mContext.sendBroadcast(intent);
        isPerformingAction = false;
    }
}
