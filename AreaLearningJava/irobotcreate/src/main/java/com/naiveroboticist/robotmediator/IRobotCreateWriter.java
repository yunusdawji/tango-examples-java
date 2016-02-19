package com.naiveroboticist.robotmediator;

import java.io.IOException;
import java.nio.ByteBuffer;

import com.hoho.android.usbserial.driver.UsbSerialPort;
import com.naiveroboticist.interfaces.IRobotWriter;

/**
 * An abstraction used to handle the raw writing to the iRobot Create.
 * 
 * @author dsieh
 *
 */
public class IRobotCreateWriter implements IRobotWriter {
    private UsbSerialPort mPort;
    
    /**
     * Constructs a new IRobotCreateWriter instance.
     * 
     * @param port the USB/Serial port.
     */
    public IRobotCreateWriter(UsbSerialPort port) {
        mPort = port;
    }

    @Override
    public void sendCommand(byte command) throws IOException {
        byte[] buffer = { command };
        sendCommand(buffer);
    }
    
    @Override
    public void sendCommand(byte command, byte[] payload) throws IOException {
        ByteBuffer buffer = ByteBuffer.allocate(payload.length + 1);
        buffer.put(command);
        buffer.put(payload);
        sendCommand(buffer.array());
    }
    
    @Override
    public void sendCommand(byte[] buffer) throws IOException {
        mPort.write(buffer, 100);
    }

}
