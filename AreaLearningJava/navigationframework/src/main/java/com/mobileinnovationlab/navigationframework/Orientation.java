package com.mobileinnovationlab.navigationframework;

import android.util.Pair;

/**
 * Created by yunusdawji on 2016-02-08.
 */
public class Orientation {

    public static final String MOTION_X = "x";

    public static final String MOTION_Y = "y";

    public static final String ROT = "rot";

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Pair<Float, Float> getXy() {
        return xy;
    }

    public void setXy(Pair<Float, Float> xy) {
        this.xy = xy;
    }

    public Float getRotation() {
        return rotation;
    }

    public void setRotation(Float rotation) {
        this.rotation = rotation;
    }

    //type of the motion to be performed
    private String type;

    private Pair<Float, Float> xy;

    private Float rotation;

    public Orientation(String type, Pair<Float, Float> xy, Float rotation){
        if(MOTION_X.equals(type)){
            this.type = type;
        }
        else if(MOTION_Y.equals(type)){
            this.type = type;
        }
        else if(ROT.equals(type)){
            this.type = type;
        }

        this.xy = xy;
        this.rotation = rotation;
    }

}
