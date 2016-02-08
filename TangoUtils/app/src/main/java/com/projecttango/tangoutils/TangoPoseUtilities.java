/*
 * Copyright 2015 Google Inc. All Rights Reserved.
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
package com.projecttango.tangoutils;

import com.google.atap.tangoservice.TangoPoseData;

import java.text.DecimalFormat;

/**
 * This is a utility class to format the Pose data in a way want to display the statistics in the
 * sample applications
 */
public class TangoPoseUtilities {
    /**
     * Get translation string from a pose.
     * @param pose           Pose from which translation string is constructed.
     * @param decimalFormat  Number of decimals for each component of translation.
     * @return
     */
    public static String getTranslationString(TangoPoseData pose, DecimalFormat decimalFormat) {
        String translationString = "["
                + decimalFormat.format(pose.translation[0]) + ", "
                + decimalFormat.format(pose.translation[1]) + ", "
                + decimalFormat.format(pose.translation[2]) + "] ";
        return  translationString;
    }

    /**
     * Get quaternion string from a pose.
     * @param pose           Pose from which quaternion string is constructed.
     * @param decimalFormat  Number of decimals for each component of translation.
     * @return
     */
    public static String getQuaternionString(TangoPoseData pose, DecimalFormat decimalFormat) {
        String quaternionString ="["
                + decimalFormat.format(pose.rotation[0]) + ", "
                + decimalFormat.format(pose.rotation[1]) + ", "
                + decimalFormat.format(pose.rotation[2]) + ", "
                + decimalFormat.format(pose.rotation[3]) + "] ";
        return  quaternionString;
    }


    /** assumes q1 is a normalised quaternion */

    public static TangoPoseData convertangles(TangoPoseData q1) {
        /*double test = q1.rotation[0]*q1.rotation[1] + q1.rotation[2]*q1.rotation[3];
        double heading, attitude, bank;
        if (test > 0.499) { // singularity at north pole
            heading = 2 * Math.atan2(q1.rotation[0],q1.rotation[3]);
            attitude = Math.PI/2;
            bank = 0;
            return q1;
        }
        if (test < -0.499) { // singularity at south pole
            heading = -2 * Math.atan2(q1.rotation[0], q1.rotation[3]);
            attitude = - Math.PI/2;
            bank = 0;
            return q1;
        }
        double sqx = q1.rotation[0]*q1.rotation[0];
        double sqy = q1.rotation[1]*q1.rotation[1];
        double sqz =  q1.rotation[2]*q1.rotation[2];
        heading = Math.atan2(2 * q1.rotation[1] * q1.rotation[3] - 2 * q1.rotation[0] * q1.rotation[2], 1 - 2 * sqy - 2 * sqz);
        attitude = Math.asin(2 * test);
        bank = Math.atan2(2 * q1.rotation[0] * q1.rotation[3] - 2 * q1.rotation[1]* q1.rotation[2], 1 - 2 * sqx - 2 * sqz);

        Rotation r = new Rotation(q1.rotation[0],q1.rotation[1], q1.rotation[2], q1.rotation[3], true);

        q1.rotation[0] = heading;
        q1.rotation[1] = attitude;
        q1.rotation[2] = bank;
*/
        return q1;
    }

    public static double[] toAngles(TangoPoseData poseData) {
        double [] angles = new double[3];
        if (angles == null) {
            angles = new double[3];
        } else if (angles.length != 3) {
            throw new IllegalArgumentException("Angles array must have three elements");
        }

        double sqw = poseData.rotation[3] * poseData.rotation[3];
        double sqx = poseData.rotation[0] * poseData.rotation[0];
        double sqy = poseData.rotation[1] * poseData.rotation[1];
        double sqz = poseData.rotation[2] * poseData.rotation[2];
        double unit = sqx + sqy + sqz + sqw; // if normalized is one, otherwise
        // is correction factor
        double test = poseData.rotation[0] * poseData.rotation[1] + poseData.rotation[2] * poseData.rotation[3];
        if (test > 0.499 * unit) { // singularity at north pole
            angles[1] = (float) (2 * Math.atan2(poseData.rotation[0], poseData.rotation[3]));
            angles[2] = (float) (Math.PI * 0.5f);
            angles[0] = 0;
        } else if (test < -0.499 * unit) { // singularity at south pole
            angles[1] = -2 * Math.atan2(poseData.rotation[0], poseData.rotation[3]);
            angles[2] = -(float) (Math.PI * 0.5f);
            angles[0] = 0;
        } else {
            angles[1] = (float) Math.atan2(2 * poseData.rotation[1] * poseData.rotation[3] - 2 * poseData.rotation[0] * poseData.rotation[2], sqx - sqy - sqz + sqw); // roll or heading
            angles[2] = (float) Math.asin(2 * test / unit); // pitch or attitude
            angles[0] = (float) Math.atan2(2 * poseData.rotation[0] * poseData.rotation[1] - 2 * poseData.rotation[1] * poseData.rotation[2], -sqx + sqy - sqz + sqw); // yaw or bank
        }
        return angles;
    }

    public static TangoPoseData getAxisAngleRad (TangoPoseData axis) {
        //if (this.w > 1) this.nor(); // if w>1 acos and sqrt will produce errors, this cant happen if quaternion is normalised
        float angle = (float)(2.0 * Math.acos(axis.rotation[3]));
        double s = Math.sqrt(1 - axis.rotation[3] * axis.rotation[3]); // assuming quaternion normalised then w is less than 1, so term always positive.
        if (s < 0.000001) { // test to avoid divide by zero, s is always positive due to sqrt
        } else {
            axis.rotation[0] = (float)(axis.rotation[0] / s); // normalise axis
            axis.rotation[1] = (float)(axis.rotation[1] / s);
            axis.rotation[2]= (float)(axis.rotation[2] / s);
        }

        return axis;
    }
    /**
     * Get the status of the Pose as a string.
     * @param pose  Pose from which status string is constructed.
     * @return
     */
    public static String getStatusString(TangoPoseData pose) {
        String poseStatus;
        switch (pose.statusCode){
            case TangoPoseData.POSE_UNKNOWN:
                poseStatus = "unknown";
                break;
            case TangoPoseData.POSE_INVALID:
                poseStatus = "invalid";
                break;
            case TangoPoseData.POSE_INITIALIZING:
                poseStatus = "initializing";
                break;
            case TangoPoseData.POSE_VALID:
                poseStatus = "valid";
                break;
            default:
                poseStatus = "unknown";
        }
        return poseStatus;
    }
}
