package com.naiveroboticist.robotmediator;

import com.hoho.android.usbserial.driver.UsbSerialPort;
import com.naiveroboticist.interfaces.IRobotMotion;
import com.naiveroboticist.utils.ByteMethods;

import java.io.IOException;

/**
 * This class provides the high-level implementation of the commands supported
 * by the iRobot Create.
 * 
 * @author dsieh
 *
 */
public class IRobotCreateCommander extends IRobotCreateWriter implements IRobotMotion {
    // Supported commands
    private static final byte START   = (byte) 0x80;
    private static final byte SAFE    = (byte) 0x83;
    private static final byte DRIVE   = (byte) 0x89;
    private static final byte LED     = (byte) 0x8b;
    private static final byte SONG    = (byte) 0x8c;
    private static final byte PLAY    = (byte) 0x8d;
    private static final byte STREAM  = (byte) 0x94;
    
    // LED values
    private static final byte LED_ADVANCE = 0x08;
    @SuppressWarnings("unused")
    private static final byte LED_PLAY = 0x02;
    
    private static final byte LED_GREEN = 0x00;
    @SuppressWarnings("unused")
    private static final byte LED_RED = (byte) 0xff;
    
    @SuppressWarnings("unused")
    private static final byte LED_OFF = 0x00;
    private static final byte LED_FULL_INTENSITY = (byte) 0xff;
    
    // Drive straight
    private static final int DRV_FWD_RAD = 0x7fff;
    
    // Standard payloads
    private static final byte[] SONG_PAYLOAD = { 0x00, 0x01, 0x48, 0xa };
    private static final byte[] PLAY_PAYLOAD = { 0x00 };
    private static final byte[] LED_PAYLOAD = { LED_ADVANCE, LED_GREEN, LED_FULL_INTENSITY };
    private static final byte[] STREAM_PAYLOAD = { 0x02, 0x07, 0x21 };
    
    /**
     * Constructs a new commander.
     * 
     * @param port the USB/Serial port to which the iRobot Create is connected.
     */
    public IRobotCreateCommander(UsbSerialPort port) {
        super(port);
    }
    
    /**
     * Initialize the iRobot Create. Prepare it for action.
     *  
     * @throws IOException
     */
    public synchronized void iRobotInitialize() throws IOException {
        sendCommand(START);
        sendCommand(SAFE);
        sendCommand(SONG, SONG_PAYLOAD);
        sendCommand(PLAY, PLAY_PAYLOAD);
        sendCommand(STREAM, STREAM_PAYLOAD);
        sendCommand(LED, LED_PAYLOAD);
    }

    /**
     * Tells the iRobot Create to drive.
     * 
     * @param fwd the velocity at which to move. Negative values mean to
     * go backwards.
     * @param rad the angle in which to drive in radians.
     */
    public synchronized void drive(int fwd, int rad) throws IOException {
        // We send the safe command prior to the actual drive commands
        // because it's possible that we might be in something other 
        // than SAFE mode. For example; if the cliff-detection fired, 
        // that throws the create into 'passive' mode after stopping 
        // all actuators so we can't start moving until we go back into
        // 'safe' mode.
        //sendCommand(SAFE);
        if (Math.abs(rad) < 0.0001) {
            rad = DRV_FWD_RAD;
        }
        byte[] buffer = { 
                ByteMethods.uB(fwd), 
                ByteMethods.lB(fwd), 
                ByteMethods.uB(rad), 
                ByteMethods.lB(rad) 
                };
        sendCommand(DRIVE, buffer);
    }
    
    /**
     * Tells the iRobot Create to pivot at a particular speed.
     * 
     * @param vel the velocity at which to pivot. Negative values
     * indicate a clockwise rotation.
     */
    public synchronized void rotate(int vel) throws IOException {
        drive(vel, 1);
    }
    
    /**
     * Tells the iRobot Create to stop moving.
     */
    public synchronized void stop() throws IOException {
        drive(0, 0);
    }

    @Override
    public void initialize() throws IOException {
        iRobotInitialize();
    }
    
}
