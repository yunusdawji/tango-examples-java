package com.naiveroboticist.robotmediator;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.util.Base64;

/**
 * This class provides an abstraction for the settings supported
 * by the iRobotMediator application. The point is to hide all the
 * details of accessing application settings.
 * 
 * @author dsieh
 *
 */
public class MediatorSettings {
    
    public static final String TAG = MediatorSettings.class.getSimpleName();
    
    /**
     * Gets the robot private key for signing messages.
     * 
     * @param context the Android Context.
     * 
     * @return the robot private key
     * 
     * @throws Exception
     */
    public static PrivateKey robotKey(Context context) throws Exception {
        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(context);
        
        return getPrivateKey(sharedPref.getString("robot_key", null));
    }

    /**
     * The name of the robot.
     * 
     * @param context the Android Context
     * 
     * @return the name of the robot.
     */
    public static String robotName(Context context) {
        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(context);
        
        return sharedPref.getString("robot_name", null);
    }

    /**
     * The server public key for verifying server messages.
     * 
     * @param context the Android Context
     * 
     * @return the server public key
     * 
     * @throws Exception
     */
    public static PublicKey serverKey(Context context) throws Exception {
        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(context);
        
        return getPublicKey(sharedPref.getString("telep_key", null));
    }

    /**
     * The internet address of the telep host. This is the source of the robot
     * commands from the human controller.
     * 
     * @param context the Android Context
     * 
     * @return the internet address of the telep host.
     * 
     * @throws UnknownHostException
     */
    public static InetAddress telepHost(Context context) throws UnknownHostException {
        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(context);
        
        return InetAddress.getByName(sharedPref.getString("telep_host", null));
    }

    /**
     * The internet port of the telep host.
     * 
     * @param context the Android Context
     * 
     * @return the internet port of the telep host
     */
    public static long telepPort(Context context) {
        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(context);
        
        String portString = sharedPref.getString("telep_port", "0");
        
        return Long.parseLong(portString);
    }
    
    /**
     * The default speed for linear motion.
     * 
     * @param context the Android Context
     * 
     * @return the default speed for linear motion.
     */
    public static int defaultSpeed(Context context) {
        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(context);

        String defaultSpeed = sharedPref.getString("default_speed", "100");
        
        return Integer.parseInt(defaultSpeed);
    }
    
    /**
     * The speed increment to use when the user requests the robot to speed up.
     * 
     * @param context the Android Context
     * 
     * @return the speed increment.
     */
    public static int speedIncrement(Context context) {
        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(context);

        String speedIncrement = sharedPref.getString("speed_increment", "100");
        
        return Integer.parseInt(speedIncrement);
    }
    
    /**
     * The speed to use for robot pivots.
     * 
     * @param context the Android Context
     * 
     * @return the speed to use for robot pivots
     */
    public static int rotationSpeed(Context context) {
        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(context);

        String rotationSpeed = sharedPref.getString("rotation_speed", "100");
        
        return Integer.parseInt(rotationSpeed);
    }
    
    private static PrivateKey getPrivateKey(String thePrivateKey) throws Exception {
        PrivateKey privateKey = null;
        String pvtKey = thePrivateKey.replaceAll("(-+BEGIN PRIVATE KEY-+\\r?\\n|-+END PRIVATE KEY-+\\r?\\n?)", "");
        
    
        byte[] keyBytes = Base64.decode(pvtKey, Base64.DEFAULT);
    
        // generate private key
        PKCS8EncodedKeySpec spec = new PKCS8EncodedKeySpec(keyBytes);
        KeyFactory keyFactory = KeyFactory.getInstance("RSA");
        privateKey = keyFactory.generatePrivate(spec);
        
        return privateKey;
    }
    
    private static PublicKey getPublicKey(String thePublicKey) throws Exception {
        PublicKey publicKey = null;
        String pubKey = thePublicKey.replaceAll("(-+BEGIN PUBLIC KEY-+\\r?\\n|-+END PUBLIC KEY-+\\r?\\n?)", "");

        byte[] keyBytes = Base64.decode(pubKey, Base64.DEFAULT);

        // generate public key
        X509EncodedKeySpec spec = new X509EncodedKeySpec(keyBytes);
        KeyFactory keyFactory = KeyFactory.getInstance("RSA");
        publicKey = keyFactory.generatePublic(spec);
        
        return publicKey;
    }
}
