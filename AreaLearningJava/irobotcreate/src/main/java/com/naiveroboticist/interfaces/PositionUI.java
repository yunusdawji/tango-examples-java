package com.naiveroboticist.interfaces;

import com.google.atap.tangoservice.TangoPoseData;

/**
 * Created by yunusdawji on 2016-02-04.
 */
public interface PositionUI {

    public void uipathrender(TangoPoseData poseData, boolean mIsRelocalized);
    public void motionSystemCallback(String action, double distance, TangoPoseData poseData);
}
