package com.naiveroboticist.robotmediator;

import android.content.Context;
import android.content.Intent;
import android.os.CountDownTimer;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.google.atap.tangoservice.TangoPoseData;
import com.mobileinnovationlab.navigationframework.ControlAction;
import com.mobileinnovationlab.navigationframework.Orientation;
import com.mobileinnovationlab.navigationframework.Triplet;
import com.mobileinnovationlab.navigationframework.WayFinder;
import com.mobileinnovationlab.navigationframework.interfaces.WayFinderAction;
import com.naiveroboticist.interfaces.PositionUI;

import java.util.List;

/**
 * Created by yunusdawji on 2016-02-10.
 */
public class IRobotController implements WayFinderAction {

    private WayFinder mWayFinder;
    private Context mContext;
    private PositionUI mCallback;

    private boolean isPerformingAction = false;
    private boolean isPerformingAction1 = false;

    private static final int rotationtime = 6500;
    private static final int motiontime = 500;

    private double distance = 0;

    private Object mLock = new Object();

    //lastaction
    // 0 - stationary
    // 1 - moving straight
    // 2 - moving left
    // 3 - moving right
    // 4 - rotating left
    // 5 - rotating right
    private int lastAction = 0;

    public IRobotController(Context context, Object sharedLock, PositionUI callback){
        mContext = context;
        mCallback = callback;
        mWayFinder = new WayFinder(context, false, true, this, sharedLock, false);
        mContext.startService(new Intent(mContext, IRobotCommunicationService.class));
    }

    @Override
    public void motionSystem(String action, Triplet distance, TangoPoseData poseData) {



        if((poseData.translation[0]==0.0f && poseData.translation[1]==0 &&poseData.translation[2]==0) || poseData.statusCode != TangoPoseData.POSE_VALID){
            return;
        }

        //synchronized (mLock){
        //    this.distance = distance;
        //}


        //debug
        mCallback.motionSystemCallback(action,distance.getFirst(),poseData);

        if(action.equals("go right") && !isPerformingAction  && lastAction!=3 ){
            lastAction = 3;
            goLeft();
        }
        else if(distance.getSecond() < 0.2 && distance.getSecond() >-0.2 && isPerformingAction && lastAction == 3 ){
            lastAction = 5;
            Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
            intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "rotate_cw");
            mContext.sendBroadcast(intent);

            new Handler(Looper.getMainLooper()).post(new Runnable() {

                @Override
                public void run() {
                    new CountDownTimer(rotationtime, 1000) {

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
            });
        }
        else if(action.equals("go straight") && !isPerformingAction && lastAction!=1){
            lastAction = 1;
            goStraight();
        }
       else if(distance.getSecond() < 0.2 && distance.getSecond() >-0.2 && isPerformingAction && lastAction == 2){
            Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
            intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "rotate_ccw");
            mContext.sendBroadcast(intent);
            lastAction = 4;

            new Handler(Looper.getMainLooper()).post(new Runnable() {

                @Override
                public void run() {
                    new CountDownTimer(rotationtime, 1000) {

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
            });
        }
        else if(action.equals("go left") && !isPerformingAction && lastAction!=2 ){
            lastAction = 2;
            goRight();
        }
        else if(action.equals("Keep Rotating to Left") && !isPerformingAction && lastAction!=4){
            lastAction = 4;
            rotateRight();
        }
        else if(action.equals("Keep Rotating to Right") && !isPerformingAction && lastAction!=5){
            lastAction = 5;
            rotateLeft();
        }else if(action.equals("Destination Reached") && !isPerformingAction && lastAction!=0){
            lastAction = 0;
            stop();
            dock();
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
        //mCallback.uipathrender(poseData,isRelocalized);
    }

    void goRight(){

        isPerformingAction = true;

        //get the instance and get the state manager
        Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
        intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "rotate_cw");
        mContext.sendBroadcast(intent);


        new Handler(Looper.getMainLooper()).post(new Runnable() {

            @Override
            public void run() {
                new CountDownTimer(rotationtime, 1000) {

                    public void onTick(long millisUntilFinished) {

                    }

                    public void onFinish() {
                        //get the instance and get the state manager
                        Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
                        intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "forward");
                        mContext.sendBroadcast(intent);
                        //isPerformingAction = false;
                        /*final CountDownTimer Counter1 = new CountDownTimer(motiontime, 1000) {

                            public void onTick(long millisUntilFinished) {
                                Log.d("Tick motion", "Tick");
                            }

                            public void onFinish() {
                               /*) synchronized (mLock) {
                                    Log.d("Tick motion", "Finish distance = " + distance);
                                    if (!(distance < 0.2 && distance > -0.2)) {
                                        Log.d("Tick motion", "Finish distance = " + distance);
                                        //cancel();
                                        //this.start();
                                    } else {

                                        Log.d("Tick motion", "Finish distance = " + distance);

                                        //get the instance and get the state manager
                                        Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
                                        intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "rotate_ccw");
                                        mContext.sendBroadcast(intent);


                                        new CountDownTimer(rotationtime, 1000) {

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
                                //}
                            //}
                        };
                        Counter1.start();
*/
                    }
                }.start();
            }
        });

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

        new Handler(Looper.getMainLooper()).post(new Runnable() {

            @Override
            public void run() {
                new CountDownTimer(rotationtime, 1000) {

                    public void onTick(long millisUntilFinished) {

                    }

                    public void onFinish() {
                        //get the instance and get the state manager
                        Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
                        intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "forward");
                        mContext.sendBroadcast(intent);
                        //isPerformingAction = false;

/*
                        new CountDownTimer(motiontime, 1000) {

                            public void onTick(long millisUntilFinished) {
                                Log.d("Tick motion", "Tick");
                            }

                            public void onFinish() {

                                //synchronized (mLock) {

                                    /*
                                     * Log.d("Tick motion", "Finish distance = " + distance);
                                       if (!(distance < 0.2 && distance > -0.2)) {
                                          //cancel();
                                          Log.d("Tick motion", "Finish distance = " + distance);
                                          //this.start();
                                       } else {

                                        Log.d("Tick motion", "Finish distance = " + distance);
                                        //get the instance and get the state manager
                                        Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
                                        intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "rotate_cw");
                                        mContext.sendBroadcast(intent);


                                        new CountDownTimer(rotationtime, 1000) {

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
*/
                                    //}
                                //}
                            //}
                        //}.start();

                    }
                }.start();
            }
        });

              }

    void rotateLeft() {
      isPerformingAction = true;
      Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
      intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "rotate_ccw");
      mContext.sendBroadcast(intent);
      isPerformingAction = false;
    }

    void rotateRight() {
      isPerformingAction = true;
      Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
      intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "rotate_cw");
      mContext.sendBroadcast(intent);
      isPerformingAction = false;
    }

    void stop() {
      isPerformingAction = true;
      Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
      intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "stop");
      mContext.sendBroadcast(intent);
      isPerformingAction = false;
    }

    void dock() {
        isPerformingAction = true;
        Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
        intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, "dock");
        mContext.sendBroadcast(intent);
        isPerformingAction = false;
    }
}
