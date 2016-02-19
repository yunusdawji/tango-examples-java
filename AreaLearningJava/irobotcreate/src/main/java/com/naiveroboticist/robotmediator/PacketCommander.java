package com.naiveroboticist.robotmediator;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;

import android.util.Log;

import com.naiveroboticist.sensor.InvalidPacketError;
import com.naiveroboticist.sensor.Packet;
import com.naiveroboticist.sensor.PacketReader;

/**
 * This Runnable watches the packets being read from the iRobotCreate
 * sensor stream and invokes commands based on the sensor readings. An
 * example would be to backup when the front sensors have been bumped.
 * 
 * @author dsieh
 *
 */
public class PacketCommander implements Runnable {
    private static final String TAG = PacketCommander.class.getName();
    
    // The packet identifier for the bump sensor
    private static final byte BUMP_PKT = 0x07;
    // The packet identifier for the analog pin
    private static final byte ANALOG_PIN_PKT = 0x21;
    
    private PacketReader mPacketReader;
    private Thread mPacketReaderThread;
    private IRobotStateManager mStateManager;
    private boolean mContinueProcessing;

    /**
     * Constructs a new PacketCommander Runnable.
     * 
     * @param packetReader iRobotCreate sensor stream reader
     * @param stateManager the robot state manager
     */
    public PacketCommander(PacketReader packetReader, 
                           IRobotStateManager stateManager) {
        
        mPacketReader = packetReader;
        mPacketReaderThread = new Thread(mPacketReader);
        mStateManager = stateManager;
        mContinueProcessing = true;
    }

    @Override
    public void run() {
        // Before we start up this thread, we need to start up the 
        // reader thread
        mPacketReaderThread.start();
        // Now, let'r rip
        while (mContinueProcessing) {
            try {
                Thread.sleep(5);
            } catch (InterruptedException e1) {
                Log.e(TAG, "Error sleeping in PacketCommander loop", e1);
            }
            if (mPacketReader.numPackets() > 0) {
                try {
                    processPacket(mPacketReader.removePacket());
                } catch (Exception e) {
                    Log.e(TAG, "Error processing sensor packet", e);
                }
            }
        }
    }
    
    /**
     * Stop looping on the packet sensor reader.
     */
    public synchronized void stopProcessingSensorPackets() {
        mPacketReader.stopReading();
        mContinueProcessing = false;
    }
    
    /**
     * Processes the specified iRobotCreate sensor packet and determines
     * if a command should be run. If there is a 'bump', it takes 
     * precedence over a proximity warning.
     * 
     * The State Manager is used to mediate the actual commands.
     * 
     * @param packet the iRobotCreate sensor packet
     * @throws InvalidPacketError
     * @throws IllegalArgumentException
     * @throws ClassNotFoundException
     * @throws NoSuchMethodException
     * @throws InstantiationException
     * @throws IllegalAccessException
     * @throws InvocationTargetException
     * @throws IOException
     */
    public void processPacket(Packet packet) throws InvalidPacketError, 
                                                    IllegalArgumentException, 
                                                    ClassNotFoundException, 
                                                    NoSuchMethodException, 
                                                    InstantiationException, 
                                                    IllegalAccessException, 
                                                    InvocationTargetException, 
                                                    IOException {
        
        int bumpValue = packet.getSensorValue(BUMP_PKT);
        double proximityInInches = proximity(packet.getSensorValue(ANALOG_PIN_PKT));
        if (bumpValue > 0 && bumpValue < 4) {
            mStateManager.processCommand("bump");
        } else if (proximityInInches > 0.0 && (proximityInInches > 12.4 && proximityInInches < 16.1)) {
            mStateManager.processCommand("proximity");
        }
    }
    
    private double proximity(int rawValue) {
        double distance = -1;
        if (rawValue > 0) {
            distance = 4192.936 * Math.pow(rawValue, -0.935) - 3.937;
        }
        return distance;
    }

}
