package com.naiveroboticist.robotmediator;

import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbDeviceConnection;
import android.hardware.usb.UsbManager;
import android.os.IBinder;
import android.util.Log;

import com.hoho.android.usbserial.driver.UsbSerialDriver;
import com.hoho.android.usbserial.driver.UsbSerialPort;
import com.hoho.android.usbserial.driver.UsbSerialProber;
import com.naiveroboticist.sensor.PacketReader;

import java.io.IOException;
import java.util.List;

/**
 * This class is an Android service that maintains the communication with
 * the iRobot Create robot.
 * 
 * @author dsieh
 *
 */
public class IRobotCommunicationService extends Service implements IDeviceSetup {
    // This is used for logging
    private static final String TAG = IRobotCommunicationService.class.getSimpleName();
    
    // Defines the intent to get permission for USB/Serial from the user
    private static final String ACTION_USB_PERMISSION = "com.naiveroboticist.USB_PERMISSION";
    // Defines the intent to send an action to the Robot
    public static final String ACTION_COMMAND_TO_ROBOT = "com.naiveroboticist.COMMAND_TO_ROBOT";

    // Define the intent to request permission for USB/Serial permission
    private PendingIntent mUsbPermissionIntent = null;
    
    // Serial port members
    private UsbSerialDriver mSerialDriver = null;
    private UsbSerialPort mSerialPort = null;
    
    // High-level commands to the robot (drive, rotate, etc.)
    private IRobotCreateCommander mCommander = null;
    
    // Reads information from the USB/serial port connection to the robot
    private PacketReader mPacketReader;
    
    // Thread to issue commands based on information read from the robot
    private Thread mPacketCommanderThread;
    private PacketCommander mPacketCommander;

    public RobotStateManager getRobotStateManager() {
        return mRobotStateManager;
    }

    // The state manager for the robot.
    private RobotStateManager mRobotStateManager;
    
    // Receiver for permission to use the USB/Serial port
    private final USBBroadcastReceiver mUsbReceiver = new USBBroadcastReceiver(this);
    
    // Handles receipt of commands from the Server service.
    private final IRobotBroadcastReceiver mCommandReceiver = new IRobotBroadcastReceiver();

    /**
     * This is called when the service is initially created. See the onStartCommand
     * for what is done when the service is actually started.
     */
    @Override
    public void onCreate() {
        super.onCreate();
        
        // Register the USB/Serial permission receiver
        mUsbPermissionIntent = PendingIntent.getBroadcast(this, 0, new Intent(ACTION_USB_PERMISSION), 0);
        IntentFilter usbFilter = new IntentFilter(ACTION_USB_PERMISSION);
        registerReceiver(mUsbReceiver, usbFilter);
        
        // Register the receiver for commands from the server.
        IntentFilter cmdFilter = new IntentFilter(ACTION_COMMAND_TO_ROBOT);
        registerReceiver(mCommandReceiver, cmdFilter);

    }
    
    /**
     * This is called when the last activity unbinds from this service.
     */
    @Override
    public boolean onUnbind(Intent intent) {
        if (ACTION_COMMAND_TO_ROBOT.equals(intent.getAction())) {
            // The mediater indicated that they don't want to do this anymore.
            
            mRobotStateManager = null;
            
            // Quit reading the sensor stream if we currently are
            if (mPacketCommander != null) {
                mPacketCommander.stopProcessingSensorPackets();
                mPacketCommander = null;
            }
            mPacketReader = null; 
            
            if (mCommander != null) {
                mCommander = null;
            }
            if (mSerialPort != null) {
                try {
                    mSerialPort.close();
                } catch (IOException e) {
                    Log.e(TAG, "Error closing port");
                }            
            }
        }
        return super.onUnbind(intent);
    }

    @Override
    public void onDestroy() {
        // Clean up the receivers
        unregisterReceiver(mUsbReceiver);
        unregisterReceiver(mCommandReceiver);
        
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent arg0) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // Create the state manager. We do this here to ensure that the
        // state of the robot is at the init state.
        mRobotStateManager = new RobotStateManager();
        
        // When we start the process, make sure we set the 
        // speed from the preferences
        mRobotStateManager.setStartingSpeed(MediatorSettings.defaultSpeed(this));
        mRobotStateManager.setSpeedIncrement(MediatorSettings.speedIncrement(this));
        mRobotStateManager.setRotationSpeed(MediatorSettings.rotationSpeed(this));
        
        UsbManager manager = (UsbManager) getSystemService(Context.USB_SERVICE);
        List<UsbSerialDriver> availableDrivers = UsbSerialProber.getDefaultProber().findAllDrivers(manager);
        
        mSerialDriver = availableDrivers.get(0);
        manager.requestPermission(mSerialDriver.getDevice(), mUsbPermissionIntent);
        
        // I know this is a bit confusing; you are thinking, where
        // do we actually hook up to the serial port and start talking to 
        // the robot? Here's the deal:
        //
        // When you request permission to accessing the USB/Serial port (see above)
        // if permission is granted, the setUpTheDevice method of this class
        // will be called. This is true even if permission had been granted 
        // previously.
        
        return super.onStartCommand(intent, flags, startId);
    }
    
    /**
     * This will be called by the broadcast receiver when permission is granted to 
     * open the USB device. The call sequence is something like:
     *   - onCreate()
     *   - onStartCommand()
     *   - setUpTheDevice()
     */
    public void setUpTheDevice(UsbDevice device) {
        UsbManager manager = (UsbManager) getSystemService(Context.USB_SERVICE);
        
        UsbDeviceConnection connection = manager.openDevice(mSerialDriver.getDevice());
        if (connection != null) {
            List<UsbSerialPort> ports = mSerialDriver.getPorts();
            mSerialPort = ports.get(0);
            try {
                // Set up the serial port for communications
                mSerialPort.open(connection);
                mSerialPort.setParameters(115200, 8, 1, UsbSerialPort.PARITY_NONE);
                
                // Set up the primary command writing interface to the robot
                mCommander = new IRobotCreateCommander(mSerialPort);
                
                // Set up the state manager with the commander, then tell
                // the robot to initialize.
                mRobotStateManager.setRobotWriter(mCommander);
                mRobotStateManager.processCommand("start");
                
                // Here we tell the command receiver for this service about the
                // robot state manager so that commands sent in from other
                // Android services can be handed off to the iRobot Create.
                mCommandReceiver.setRobotStateManager(mRobotStateManager);
                
                // The following sets up the thread where we read from the
                // iRobot Create sensor stream and issue commands if the 
                // sensor values indicate we need to (e.g. bump or proximity)
                
                mPacketReader = new PacketReader(new IRobotCreateReader(mSerialPort), 5);
                
                mPacketCommander = new PacketCommander(mPacketReader, mRobotStateManager);
                mPacketCommanderThread = new Thread(mPacketCommander);
                mPacketCommanderThread.start();

                
            } catch (IOException ex) {
                Log.e(TAG, "Error communicating with port", ex);
            } catch (Exception ex) {
                Log.e(TAG, "Error setting up the device", ex);
            }
        } else {
            Log.w(TAG, "You probably need to call UsbManager.requestPermission(driver.getDevice(),... )");
        }
    }

    @Override
    public void deviceSetupError(String message) {
        Log.e(TAG, message);
    }


}
