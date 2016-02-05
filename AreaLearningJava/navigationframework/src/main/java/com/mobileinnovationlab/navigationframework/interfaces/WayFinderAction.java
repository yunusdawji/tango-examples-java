package com.mobileinnovationlab.navigationframework.interfaces;

import android.util.Pair;

import com.google.atap.tangoservice.TangoPoseData;
import com.mobileinnovationlab.navigationframework.ControlAction;

import java.util.List;

/**
 * Created by yunusdawji on 2016-02-04.
 */
public interface WayFinderAction {
    public void motionSystem(String action, double distance, TangoPoseData poseData);
    public void control(List<Pair<String, Pair<Float, Float>>> list, ControlAction action);
    public void currentPosition(TangoPoseData poseData, boolean isRelocalized);
    //public void uipathrender(TangoPoseData poseData , boolean updateRenderer, boolean mIsRelocalized);
}