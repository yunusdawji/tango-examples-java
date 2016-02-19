package com.naiveroboticist.robotmediator;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.util.Log;

/**
 * This class is about receiving a message from the system about 
 * obtaining permission for an application to use the USB port.
 * 
 * For most of the implementations, have the activity that will be
 * accessing the serial port implement the IDeviceSetup interface,
 * then on create, new up an instance of this class passing the
 * activity. If permission is granted, this guy will notify your
 * activity when to set up your device.
 * 
 * @author dsieh
 *
 */
public class USBBroadcastReceiver extends BroadcastReceiver {
    private static final String TAG = USBBroadcastReceiver.class.getSimpleName();
    private static final String ACTION_USB_PERMISSION = "com.naiveroboticist.USB_PERMISSION";

    private IDeviceSetup mDeviceSetup;

    public USBBroadcastReceiver(IDeviceSetup deviceSetupCallback) {
        mDeviceSetup = deviceSetupCallback;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        if (ACTION_USB_PERMISSION.equals(action)) {
            synchronized (this) {
                UsbDevice device = (UsbDevice) intent.getParcelableExtra(UsbManager.EXTRA_DEVICE);
                
                if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                    if (device != null) {
                        // Call method to set up device communication
                        mDeviceSetup.setUpTheDevice(device);
                    }
                } else {
                    mDeviceSetup.deviceSetupError("Permission denied for device");
                    Log.i(TAG, "Permission denied for device" + device);
                }
            }
        } 
    }

}
