package com.naiveroboticist.robotmediator;

import android.hardware.usb.UsbDevice;

/**
 * Interface to be implemented to deal with the aftermath when
 * the application has been approved to use the UsbDevice.
 * 
 * @author dsieh
 *
 */
public interface IDeviceSetup {
    
    /**
     * Perform the necessary initialization after the UsbDevice
     * has been approved for use by the application.
     * 
     * @param device the USB device.
     */
    void setUpTheDevice(UsbDevice device);
    
    /**
     * Handle the errors issued when setting up the device.
     * 
     * @param message the message to handle.
     */
    void deviceSetupError(String message);

}
