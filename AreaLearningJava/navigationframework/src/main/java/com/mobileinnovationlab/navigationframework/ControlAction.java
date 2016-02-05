package com.mobileinnovationlab.navigationframework;

/**
 * Created by yunusdawji on 2016-02-04.
 */
public class ControlAction {

    public final static String GO = "go";
    public final static String STOP = "stop";

    public String getActionType() {
        return actionType;
    }

    public void setActionType(String actionType) {
        this.actionType = actionType;
    }

    private String actionType;

    public ControlAction(String action){
        if (action.equals(GO)){
            actionType = GO;
        }else if (action.equals(STOP)){
            actionType = STOP;
        }
    }



}
