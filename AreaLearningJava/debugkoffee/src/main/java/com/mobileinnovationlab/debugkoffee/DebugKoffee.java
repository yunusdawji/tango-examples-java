package com.mobileinnovationlab.debugkoffee;

import android.content.Context;
import android.content.Intent;
import android.util.Pair;

import com.google.atap.tangoservice.TangoPoseData;
import com.mobileinnovationlab.navigationframework.ControlAction;
import com.mobileinnovationlab.navigationframework.Orientation;
import com.mobileinnovationlab.navigationframework.WayFinder;
import com.mobileinnovationlab.navigationframework.interfaces.WayFinderAction;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by yunusdawji on 2016-02-04.
 */
public class DebugKoffee implements WayFinderAction {

    private WayFinder mWayFinder;
    private Context mContext;
    private ArrayList<Orientation> points;
    private PositionUI mCallback;

    Intent intent;


    public DebugKoffee(Context context, Object sharedLock, PositionUI callback){
        mCallback = callback;
        mWayFinder = new WayFinder(context, false, true, this, sharedLock, false);
    }

    @Override
    public void motionSystem(String action, double distance, TangoPoseData poseData) {
        //lets do a callback
        mCallback.motionSystemCallback(action, distance, poseData);
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
        mCallback.uipathrender(poseData, isRelocalized);
    }

}
