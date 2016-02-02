/*
 * Copyright 2014 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.mobileinnovationlab.navigationframework;

import android.app.Activity;
import android.app.FragmentManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Bundle;
import android.util.Log;
import android.util.Pair;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.google.atap.tangoservice.Tango;
import com.google.atap.tangoservice.Tango.OnTangoUpdateListener;
import com.google.atap.tangoservice.TangoConfig;
import com.google.atap.tangoservice.TangoCoordinateFramePair;
import com.google.atap.tangoservice.TangoErrorException;
import com.google.atap.tangoservice.TangoEvent;
import com.google.atap.tangoservice.TangoInvalidException;
import com.google.atap.tangoservice.TangoOutOfDateException;
import com.google.atap.tangoservice.TangoPoseData;
import com.google.atap.tangoservice.TangoXyzIjData;
import com.projecttango.tangoutils.TangoPoseUtilities;


import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;

/**
 * Main Activity class for the Area Learning API Sample. Handles the connection to the Tango service
 * and propagation of Tango pose data to OpenGL and Layout views. OpenGL rendering logic is
 * delegated to the {@link AreaLearningRajawaliRenderer} class.
 */
public class WayFinder {

    public interface WayFinderAction {
        public void control(String action, TangoPoseData[] data);
    }

    private static final int SECS_TO_MILLISECS = 1000;
    private Tango mTango;
    private TangoConfig mConfig;

    private int mStart2DevicePreviousPoseStatus;
    private int mAdf2DevicePreviousPoseStatus;
    private int mAdf2StartPreviousPoseStatus;

    private double mStart2DevicePreviousPoseTimeStamp;
    private double mAdf2DevicePreviousPoseTimeStamp;
    private double mAdf2StartPreviousPoseTimeStamp;

    private double mPreviousPoseTimeStamp;
    private double mTimeToNextUpdate = UPDATE_INTERVAL_MS;

    private boolean mIsRelocalized;
    private boolean mIsLearningMode;
    private boolean mIsConstantSpaceRelocalize;

    private String directionText;

    private TangoPoseData[] mPoses;
    private static final double UPDATE_INTERVAL_MS = 100.0;
    private static final DecimalFormat FORMAT_THREE_DECIMAL = new DecimalFormat("00.000");

    private Object mSharedLock;
    private List<Pair<String, Pair<Float, Float>>> points;

    private Context mContext;

    private int mStart2DevicePoseCount = 0;
    private int mAdf2DevicePoseCount = 0;
    private int mAdf2StartPoseCount = 0;
    private double mAdf2DevicePoseDelta = 0;
    private double mAdf2StartPoseDelta = 0;
    private double mStart2DevicePoseDelta = 0;

    private WayFinderAction mCallback;

    public WayFinder(Context context, boolean arealearning, boolean loadadf, WayFinderAction callback, Object sharedLock){
        mContext = context;
        init(arealearning,loadadf,callback,sharedLock);
    }


    protected void init(boolean arealearning, boolean loadadf, WayFinderAction callback, Object sharedLock) {
        mIsLearningMode = arealearning;
        mIsConstantSpaceRelocalize = loadadf;

        // Instantiate the Tango service
        mTango = new Tango(mContext);
        mIsRelocalized = false;
        mConfig = setTangoConfig(mTango, mIsLearningMode, mIsConstantSpaceRelocalize);


        points = new ArrayList<Pair<String, Pair<Float, Float>>>();
        points.add(new Pair<String, Pair<Float, Float>>("y", new Pair<Float, Float>(0.00f, 2.00f)));
        points.add(new Pair<String, Pair<Float, Float>>("x", new Pair<Float, Float>(2.00f, 2.00f)));

        // Reset pose data and start counting from resume.
        initializePoseData();

        // Clear the relocalization state: we don't know where the device has been since our app was paused.
        mIsRelocalized = false;

        mSharedLock = sharedLock;

        // Re-attach listeners.
        try {
            setUpTangoListeners();
        } catch (TangoErrorException e) {
            Toast.makeText(mContext, R.string.tango_error, Toast.LENGTH_SHORT).show();
        } catch (SecurityException e) {
            Toast.makeText(mContext, R.string.no_permissions, Toast.LENGTH_SHORT).show();
        }

        // Connect to the tango service (start receiving pose updates).
        try {
            mTango.connect(mConfig);
        } catch (TangoOutOfDateException e) {
            Toast.makeText(mContext, R.string.tango_out_of_date_exception, Toast.LENGTH_SHORT).show();
        } catch (TangoErrorException e) {
            Toast.makeText(mContext, R.string.tango_error, Toast.LENGTH_SHORT).show();
        } catch (TangoInvalidException e) {
            Toast.makeText(mContext, R.string.tango_invalid, Toast.LENGTH_SHORT).show();
        }

        mCallback = callback;

    }

    /**
     * Initializes pose data we keep track of. To be done
     */
    private void initializePoseData() {
        mPoses = new TangoPoseData[3];
        mStart2DevicePoseCount = 0;
        mAdf2DevicePoseCount = 0;
        mAdf2StartPoseCount = 0;
    }


    public void stop(){
        try {
            mTango.disconnect();
        } catch (TangoErrorException e) {
            Toast.makeText(mContext, R.string.tango_error, Toast.LENGTH_SHORT).show();
        }
    }


    /**
     * Sets up the tango configuration object. Make sure mTango object is initialized before
     * making this call.
     */
    private TangoConfig setTangoConfig(Tango tango, boolean isLearningMode, boolean isLoadAdf) {
        TangoConfig config = new TangoConfig();
        config = tango.getConfig(TangoConfig.CONFIG_TYPE_CURRENT);
        // Check if learning mode
        if (isLearningMode) {
            // Set learning mode to config.
            config.putBoolean(TangoConfig.KEY_BOOLEAN_LEARNINGMODE, true);

        }
        // Check for Load ADF/Constant Space relocalization mode
        if (isLoadAdf) {
            ArrayList<String> fullUUIDList = new ArrayList<String>();
            // Returns a list of ADFs with their UUIDs
            fullUUIDList = tango.listAreaDescriptions();
            // Load the latest ADF if ADFs are found.
            if (fullUUIDList.size() > 0) {
                config.putString(TangoConfig.KEY_STRING_AREADESCRIPTION,
                        fullUUIDList.get(fullUUIDList.size() - 1));
            }
        }
        return config;
    }

    /**
     * Set up the callback listeners for the Tango service, then begin using the Motion
     * Tracking API. This is called in response to the user clicking the 'Start' Button.
     */
    private void setUpTangoListeners() {

        // Set Tango Listeners for Poses Device wrt Start of Service, Device wrt
        // ADF and Start of Service wrt ADF
        ArrayList<TangoCoordinateFramePair> framePairs = new ArrayList<TangoCoordinateFramePair>();
        framePairs.add(new TangoCoordinateFramePair(
                TangoPoseData.COORDINATE_FRAME_START_OF_SERVICE,
                TangoPoseData.COORDINATE_FRAME_DEVICE));
        framePairs.add(new TangoCoordinateFramePair(
                TangoPoseData.COORDINATE_FRAME_AREA_DESCRIPTION,
                TangoPoseData.COORDINATE_FRAME_DEVICE));
        framePairs.add(new TangoCoordinateFramePair(
                TangoPoseData.COORDINATE_FRAME_AREA_DESCRIPTION,
                TangoPoseData.COORDINATE_FRAME_START_OF_SERVICE));

        mTango.connectListener(framePairs, new OnTangoUpdateListener() {
            @Override
            public void onXyzIjAvailable(TangoXyzIjData xyzij) {
                // Not using XyzIj data for this sample
            }

            // Listen to Tango Events
            @Override
            public void onTangoEvent(final TangoEvent event) {
                /*runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        // Update the debug UI with information about this event.
                        mTangoEventTextView.setText(event.eventKey + ": " + event.eventValue);

                        // When saving an ADF, update the progress bar UI.
                        if (event.eventType == TangoEvent.EVENT_AREA_LEARNING &&
                                TangoEvent.KEY_AREA_DESCRIPTION_SAVE_PROGRESS.equals(event.eventKey)) {
                            int progressPercent = (int)(Double.parseDouble(event.eventValue) * 100);
                            if (mSaveAdfTask != null) {
                                mSaveAdfTask.publishProgress(progressPercent);
                            }
                        }
                    }
                });*/
            }

            @Override
            public void onPoseAvailable(TangoPoseData pose) {
                boolean updateRenderer = false;
                // Make sure to have atomic access to Tango Data so that
                // UI loop doesn't interfere while Pose call back is updating
                // the data.
                synchronized (mSharedLock) {
                    // Check for Device wrt ADF pose, Device wrt Start of Service pose,
                    // Start of Service wrt ADF pose(This pose determines if device
                    // the is relocalized or not).
                    if (pose.baseFrame == TangoPoseData.COORDINATE_FRAME_AREA_DESCRIPTION
                            && pose.targetFrame == TangoPoseData.COORDINATE_FRAME_DEVICE) {
                        mPoses[0] = pose;
                        if (mAdf2DevicePreviousPoseStatus != pose.statusCode) {
                            // Set the count to zero when status code changes.
                            mAdf2DevicePoseCount = 0;
                        }
                        mAdf2DevicePreviousPoseStatus = pose.statusCode;
                        mAdf2DevicePoseCount++;
                        // Calculate time difference between current and last available Device wrt
                        // ADF pose.
                        mAdf2DevicePoseDelta = (pose.timestamp - mAdf2DevicePreviousPoseTimeStamp)
                                * SECS_TO_MILLISECS;
                        mAdf2DevicePreviousPoseTimeStamp = pose.timestamp;
                        if (mIsRelocalized) {
                            updateRenderer = true;
                        }


                        if(points.get(0).first.equals("y")) {
                            //lets do something with it
                            Pair<Float, Float> pair = points.get(0).second;
                            if (pair.first.doubleValue() - pose.translation[0] > .2) {
                                //go left
                                directionText = "go right";
                            } else if (pair.first.doubleValue() - pose.translation[0] < -0.2) {
                                //go right
                                directionText = "go left";
                            }
                            else {
                                //go right
                                directionText = "";
                            }

                            if (pair.second.doubleValue() - pose.translation[1] <= 0) {
                                //rotate
                                //points.remove(0);
                            }
                        }


                        /*if(points.get(0).first.equals("x")) {
                            //lets do something with it
                            Pair<Float, Float> pair = points.get(0).second;
                            if (pair.second.doubleValue() - pose.translation[0] > .2) {
                                //go left
                                directionText = "go right";
                            } else if (pair.second.doubleValue() - pose.translation[0] < -0.2) {
                                //go right
                                directionText = "go left";
                            }
                            else {
                                //go right
                                directionText = "";
                            }

                            if (pair.first.doubleValue() - pose.translation[1] <= 0) {
                                //rotate
                                points.remove(0);
                                if(points.size()==0)
                                    directionText = "Destination Reached";
                            }
                        }*/

                    } else if (pose.baseFrame == TangoPoseData.COORDINATE_FRAME_START_OF_SERVICE
                            && pose.targetFrame == TangoPoseData.COORDINATE_FRAME_DEVICE) {
                        mPoses[1] = pose;
                        if (mStart2DevicePreviousPoseStatus != pose.statusCode) {
                            // Set the count to zero when status code changes.
                            mStart2DevicePoseCount = 0;
                        }
                        mStart2DevicePreviousPoseStatus = pose.statusCode;
                        mStart2DevicePoseCount++;
                        // Calculate time difference between current and last available Device wrt
                        // SS pose.
                        mStart2DevicePoseDelta = (pose.timestamp - mStart2DevicePreviousPoseTimeStamp)
                                * SECS_TO_MILLISECS;
                        mStart2DevicePreviousPoseTimeStamp = pose.timestamp;
                        if (!mIsRelocalized) {
                            updateRenderer = true;
                        }
                        //mAdf2DirectionTextView.setText("go left");
                        //directionText = "go right";

                    } else if (pose.baseFrame == TangoPoseData.COORDINATE_FRAME_AREA_DESCRIPTION
                            && pose.targetFrame == TangoPoseData.COORDINATE_FRAME_START_OF_SERVICE) {
                        mPoses[2] = pose;
                        if (mAdf2StartPreviousPoseStatus != pose.statusCode) {
                            // Set the count to zero when status code changes.
                            mAdf2StartPoseCount = 0;
                        }
                        mAdf2StartPreviousPoseStatus = pose.statusCode;
                        mAdf2StartPoseCount++;
                        // Calculate time difference between current and last available SS wrt ADF
                        // pose.
                        mAdf2StartPoseDelta = (pose.timestamp - mAdf2StartPreviousPoseTimeStamp)
                                * SECS_TO_MILLISECS;
                        mAdf2StartPreviousPoseTimeStamp = pose.timestamp;
                        if (pose.statusCode == TangoPoseData.POSE_VALID) {
                            mIsRelocalized = true;
                            // Set the color to green
                        } else {
                            mIsRelocalized = false;
                            // Set the color blue
                        }
                        //mAdf2DirectionTextView.setText("go left");
                        //directionText = "go right";
                    }
                }

                final double deltaTime = (pose.timestamp - mPreviousPoseTimeStamp) * SECS_TO_MILLISECS;
                mPreviousPoseTimeStamp = pose.timestamp;
                mTimeToNextUpdate -= deltaTime;

                if (mTimeToNextUpdate < 0.0) {
                    mTimeToNextUpdate = UPDATE_INTERVAL_MS;

//                    runOnUiThread(new Runnable() {
//                        @Override
//                        public void run() {
//                            synchronized (mSharedLock) {
//                                updateTextViews();
//                            }//                       }
//                    });
                    //callback to send data
                    mCallback.control(directionText, mPoses);
                }

                if (updateRenderer) {
                    //mRenderer.updateDevicePose(pose, mIsRelocalized);
                }
            }

            @Override
            public void onFrameAvailable(int cameraId) {
                // We are not using onFrameAvailable for this application.
            }
        });
    }

}