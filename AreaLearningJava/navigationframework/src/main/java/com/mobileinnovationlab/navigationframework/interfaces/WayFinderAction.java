package com.mobileinnovationlab.navigationframework.interfaces;

import android.util.Pair;

import com.google.atap.tangoservice.TangoPoseData;
import com.mobileinnovationlab.navigationframework.ControlAction;
import com.mobileinnovationlab.navigationframework.Orientation;
import com.mobileinnovationlab.navigationframework.Triplet;

import java.util.List;

/**
 * Created by yunusdawji on 2016-02-04.
 */
public interface WayFinderAction {
    public void motionSystem(String action, Triplet distance, TangoPoseData poseData);
    public void control(List<Orientation> list, ControlAction action);
    public void currentPosition(TangoPoseData poseData, boolean isRelocalized);
    //public void uipathrender(TangoPoseData poseData , boolean updateRenderer, boolean mIsRelocalized);
}