package com.naiveroboticist.robotmediator;

import java.io.IOException;

import com.hoho.android.usbserial.driver.UsbSerialPort;
import com.naiveroboticist.interfaces.IRobotReader;

/**
 * Class to read from the robot reader. The point of the class
 * is to provide an abstraction away from the actual device being
 * read from.
 * 
 * @author dsieh
 *
 */
public class IRobotCreateReader implements IRobotReader {

    private UsbSerialPort mPort;

    /**
     * Construct a new IRobotCreateReader
     * 
     * @param port the UsbSerialPort to read from.
     */
    public IRobotCreateReader(UsbSerialPort port) {
        mPort = port;
    }

    @Override
    public int read(byte[] buffer, int timeoutMillis) throws IOException {
        return mPort.read(buffer, timeoutMillis);
    }

}
