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

package com.projecttango.experiments.javaarealearning;

import com.google.atap.tangoservice.Tango;
import com.google.atap.tangoservice.TangoConfig;
import com.google.atap.tangoservice.TangoPoseData;
import android.app.Activity;
import android.app.FragmentManager;
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
import com.mobileinnovationlab.debugkoffee.DebugKoffee;
import com.mobileinnovationlab.debugkoffee.PositionUI;
import com.mobileinnovationlab.navigationframework.ControlAction;
import com.mobileinnovationlab.navigationframework.Orientation;
import com.mobileinnovationlab.navigationframework.WayFinder;
import com.projecttango.tangoutils.TangoPoseUtilities;

import org.rajawali3d.math.Quaternion;
import org.rajawali3d.surface.IRajawaliSurface;
import org.rajawali3d.surface.RajawaliSurfaceView;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;


/**
 * Main Activity class for the Area Learning API Sample. Handles the connection to the Tango service
 * and propagation of Tango pose data to OpenGL and Layout views. OpenGL rendering logic is
 * delegated to the {@link AreaLearningRajawaliRenderer} class.
 */
public class AreaLearningActivity extends Activity implements View.OnClickListener,
        SetADFNameDialog.CallbackListener, SaveAdfTask.SaveAdfListener, PositionUI {

    private static final String TAG = AreaLearningActivity.class.getSimpleName();
    private static final int SECS_TO_MILLISECS = 1000;
    private Tango mTango;
    private TangoConfig mConfig;
    private TextView mTangoEventTextView;
    private TextView mStart2DeviceTranslationTextView;
    private TextView mAdf2DeviceTranslationTextView;
    private TextView mAdf2StartTranslationTextView;
    private TextView mStart2DeviceQuatTextView;
    private TextView mAdf2DeviceQuatTextView;
    private TextView mAdf2StartQuatTextView;
    private TextView mTangoServiceVersionTextView;
    private TextView mApplicationVersionTextView;
    private TextView mUUIDTextView;
    private TextView mStart2DevicePoseStatusTextView;
    private TextView mAdf2DevicePoseStatusTextView;
    private TextView mAdf2StartPoseStatusTextView;
    private TextView mStart2DevicePoseCountTextView;
    private TextView mAdf2DevicePoseCountTextView;
    private TextView mAdf2StartPoseCountTextView;
    private TextView mStart2DevicePoseDeltaTextView;
    private TextView mAdf2DevicePoseDeltaTextView;
    private TextView mAdf2StartPoseDeltaTextView;
    private TextView mAdf2DirectionTextView;

    private Button mSaveAdfButton;
    private Button mFirstPersonButton;
    private Button mThirdPersonButton;
    private Button mTopDownButton;

    private int mStart2DevicePoseCount;
    private int mAdf2DevicePoseCount;
    private int mAdf2StartPoseCount;
    private int mStart2DevicePreviousPoseStatus;
    private int mAdf2DevicePreviousPoseStatus;
    private int mAdf2StartPreviousPoseStatus;

    private double mStart2DevicePoseDelta;
    private double mAdf2DevicePoseDelta;
    private double mAdf2StartPoseDelta;
    private double mStart2DevicePreviousPoseTimeStamp;
    private double mAdf2DevicePreviousPoseTimeStamp;
    private double mAdf2StartPreviousPoseTimeStamp;

    private double mPreviousPoseTimeStamp;
    private double mTimeToNextUpdate = UPDATE_INTERVAL_MS;

    private boolean mIsRelocalized;
    private boolean mIsLearningMode;
    private boolean mIsConstantSpaceRelocalize;
    private boolean mIsDebugMode;


    private AreaLearningRajawaliRenderer mRenderer;
    private RajawaliSurfaceView mGLView;

    // Long-running task to save the ADF.
    private SaveAdfTask mSaveAdfTask;

    private String directionText;

    private TangoPoseData[] mPoses;
    private static final double UPDATE_INTERVAL_MS = 100.0;
    private static final DecimalFormat FORMAT_THREE_DECIMAL = new DecimalFormat("00.000");

    private final Object mSharedLock = new Object();
    private List<Orientation> points;

    private WayFinder mWayFinder;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_area_learning);
        Intent intent = getIntent();
        mIsLearningMode = intent.getBooleanExtra(ALStartActivity.USE_AREA_LEARNING, false);
        mIsConstantSpaceRelocalize = intent.getBooleanExtra(ALStartActivity.LOAD_ADF, false);
        mIsDebugMode = intent.getBooleanExtra(ALStartActivity.IS_DEBUG_MODE, false);

        points = new ArrayList<Orientation>();
        points.add(new Orientation(Orientation.MOTION_Y, new Pair<Float, Float>(0.00f, 4.80f),0.695f));
        points.add(new Orientation(Orientation.ROT, new Pair<Float, Float>(0.00f, 0.50f),1.100f));
        points.add(new Orientation(Orientation.MOTION_X, new Pair<Float, Float>(-9.0f, 4.80f),1.100f));
        //points.add(new Pair<String, Pair<Float, Float>>("x", new Pair<Float, Float>(-9.00f, 4.80f)));

        mRenderer = setupGLViewAndRenderer();

        setupTextViewsAndButtons(false, false);

        //mWayFinder = new WayFinder(getApplicationContext(), mIsLearningMode, mIsConstantSpaceRelocalize, this, mSharedLock, points, mIsDebugMode);
        if(!mIsDebugMode){
            DebugKoffee mDebugKofee = new DebugKoffee(getApplicationContext(), mSharedLock, this);
            mDebugKofee.control(points, new ControlAction(ControlAction.GO));
        }
    }


    /**
     * Implements SetADFNameDialog.CallbackListener.
     */
    @Override
    public void onAdfNameOk(String name, String uuid) {
        saveAdf(name);
    }

    /**
     * Implements SetADFNameDialog.CallbackListener.
     */
    @Override
    public void onAdfNameCancelled() {
        // Continue running.
    }

    @Override
    protected void onPause() {
        super.onPause();
//        mWayFinder.stop();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    /**
     * Listens for click events from any button in the view.
     */
    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.first_person_button:
                mRenderer.setFirstPersonView();
                break;
            case R.id.top_down_button:
                mRenderer.setTopDownView();
                break;
            case R.id.third_person_button:
                mRenderer.setThirdPersonView();
                break;
            case R.id.saveAdf:
                // Query the user for an ADF name and save if OK was clicked.
                showSetADFNameDialog();
                break;
            default:
                Log.w(TAG, "Unknown button click");
                return;
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        mRenderer.onTouchEvent(event);
        return true;
    }

    /**
     * Sets Rajawalisurface view and its renderer. This is ideally called only once in onCreate.
     */
    private AreaLearningRajawaliRenderer setupGLViewAndRenderer(){
        // Configure OpenGL renderer
        AreaLearningRajawaliRenderer renderer = new AreaLearningRajawaliRenderer(this);
        // OpenGL view where all of the graphics are drawn
        RajawaliSurfaceView glView = (RajawaliSurfaceView) findViewById(R.id.gl_surface_view);
        glView.setEGLContextClientVersion(2);
        glView.setRenderMode(IRajawaliSurface.RENDERMODE_CONTINUOUSLY);
        glView.setSurfaceRenderer(renderer);
        return renderer;
    }

    /**
     * Sets Texts views to display statistics of Poses being received. This also sets the buttons
     * used in the UI. Please note that this needs to be called after TangoService and Config
     * objects are initialized since we use them for the SDK related stuff like version number
     * etc.
     */
    private void setupTextViewsAndButtons(  boolean isLearningMode, boolean isLoadAdf){
        //mTangoEventTextView = (TextView) findViewById(R.id.tangoevent);

       /* mAdf2DeviceTranslationTextView = (TextView) findViewById(R.id.adf2devicePose);
        mStart2DeviceTranslationTextView = (TextView) findViewById(R.id.start2devicePose);
        mAdf2StartTranslationTextView = (TextView) findViewById(R.id.adf2startPose);
        mAdf2DeviceQuatTextView = (TextView) findViewById(R.id.adf2deviceQuat);
        mStart2DeviceQuatTextView = (TextView) findViewById(R.id.start2deviceQuat);
        mAdf2StartQuatTextView = (TextView) findViewById(R.id.adf2startQuat);

        mAdf2DevicePoseStatusTextView = (TextView) findViewById(R.id.adf2deviceStatus);
        mStart2DevicePoseStatusTextView = (TextView) findViewById(R.id.start2deviceStatus);
        mAdf2StartPoseStatusTextView = (TextView) findViewById(R.id.adf2startStatus);

        mAdf2DevicePoseCountTextView = (TextView) findViewById(R.id.adf2devicePosecount);
        mStart2DevicePoseCountTextView = (TextView) findViewById(R.id.start2devicePosecount);
        mAdf2StartPoseCountTextView = (TextView) findViewById(R.id.adf2startPosecount);
*/
        mAdf2DevicePoseDeltaTextView = (TextView) findViewById(R.id.adf2deviceDeltatime);
        //mStart2DevicePoseDeltaTextView = (TextView) findViewById(R.id.start2deviceDeltatime);
        //mAdf2StartPoseDeltaTextView = (TextView) findViewById(R.id.adf2startDeltatime);

        mFirstPersonButton = (Button) findViewById(R.id.first_person_button);
        mThirdPersonButton = (Button) findViewById(R.id.third_person_button);
        mTopDownButton = (Button) findViewById(R.id.top_down_button);

       // mTangoServiceVersionTextView = (TextView) findViewById(R.id.version);
       // mApplicationVersionTextView = (TextView) findViewById(R.id.appversion);
        mGLView = (RajawaliSurfaceView) findViewById(R.id.gl_surface_view);

        mSaveAdfButton = (Button) findViewById(R.id.saveAdf);
        mUUIDTextView = (TextView) findViewById(R.id.uuid);

        mAdf2DirectionTextView = (TextView) findViewById(R.id.adf2direction);

        // Set up button click listeners and button state.
        mFirstPersonButton.setOnClickListener(this);
        mThirdPersonButton.setOnClickListener(this);
        mTopDownButton.setOnClickListener(this);
        if (isLearningMode) {
            // Disable save ADF button until Tango relocalizes to the current ADF.
            mSaveAdfButton.setEnabled(false);
            mSaveAdfButton.setOnClickListener(this);
        } else {
            // Hide to save ADF button if leanring mode is off.
            mSaveAdfButton.setVisibility(View.GONE);
        }

        //mTangoServiceVersionTextView.setText(config.getString("tango_service_library_version"));
        PackageInfo packageInfo;
        try {
            packageInfo = this.getPackageManager().getPackageInfo(this.getPackageName(), 0);
//            mApplicationVersionTextView.setText(packageInfo.versionName);
        } catch (NameNotFoundException e) {
            e.printStackTrace();
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
     * Save the current Area Description File.
     * Performs saving on a background thread and displays a progress dialog.
     */
    private void saveAdf(String adfName) {
        mSaveAdfTask = new SaveAdfTask(this, this, mTango, adfName);
        mSaveAdfTask.execute();
    }

    /**
     * Handles failed save from mSaveAdfTask.
     */
    @Override
    public void onSaveAdfFailed(String adfName) {
        String toastMessage = String.format(
            getResources().getString(R.string.save_adf_failed_toast_format),
            adfName);
        Toast.makeText(this, toastMessage, Toast.LENGTH_LONG).show();
        mSaveAdfTask = null;
    }

    /**
     * Handles successful save from mSaveAdfTask.
     */
    @Override
    public void onSaveAdfSuccess(String adfName, String adfUuid) {
        String toastMessage = String.format(
            getResources().getString(R.string.save_adf_success_toast_format),
            adfName, adfUuid);
        Toast.makeText(this, toastMessage, Toast.LENGTH_LONG).show();
        mSaveAdfTask = null;
        finish();
    }

    /**
     * Shows a dialog for setting the ADF name.
     */
    private void showSetADFNameDialog() {
        Bundle bundle = new Bundle();
        bundle.putString("name", "New ADF");
        bundle.putString("id", ""); // UUID is generated after the ADF is saved.

        FragmentManager manager = getFragmentManager();
        SetADFNameDialog setADFNameDialog = new SetADFNameDialog();
        setADFNameDialog.setArguments(bundle);
        setADFNameDialog.show(manager, "ADFNameDialog");
    }

    /**
     * Updates the text view in UI screen with the Pose. Each pose is associated with Target and
     * Base Frame. We need to check for that pair and update our views accordingly.
     */
    private void updateTextViews(String msg, double distance, TangoPoseData poseData) {
        // Allow clicking of the save button only when Tango is localized to the current ADF.
        mSaveAdfButton.setEnabled(mIsRelocalized);
        //TangoPoseData temppose = new TangoPoseData();
        //temppose.rotation = TangoPoseUtilities.toAngles(poseData);

        //mAdf2DirectionTextView.setText(msg);

        //Quaternion temp = new Quaternion(poseData.rotation[3], poseData.rotation[0], poseData.rotation[1], poseData.rotation[2]);
        //Quaternion tempy = new Quaternion(Math.PI/2, 0, 0, 1);
        //tempy.normalize();
        //tempy.multiply(temp);


        //temp.angleBetween(tempy);
        //poseData.rotation[1] += 0.680;

        mAdf2DirectionTextView.setText(msg + TangoPoseUtilities.getQuaternionString(poseData, FORMAT_THREE_DECIMAL));

        mAdf2DevicePoseDeltaTextView.setText(Double.toString(Math.abs(distance)));

    }

    @Override
    public void uipathrender( TangoPoseData poseData, boolean mIsRelocalized) {
        final TangoPoseData temppose = TangoPoseUtilities.convertangles(poseData);
        mRenderer.updateDevicePose(poseData, mIsRelocalized);
    }

    @Override
    public void motionSystemCallback(final String action, final double distance, final TangoPoseData poseData) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                synchronized (mSharedLock) {
                    updateTextViews(action, distance, poseData);
                }
            }
        });
    }
}
