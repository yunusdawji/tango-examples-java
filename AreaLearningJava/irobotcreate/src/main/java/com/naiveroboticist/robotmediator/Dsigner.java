package com.naiveroboticist.robotmediator;

import java.security.Signature;
import java.util.StringTokenizer;

import android.content.Context;
import android.util.Base64;

/**
 * This class implements methods to verify messages with digital signatures
 * and to sign messages with digital signatures.
 * 
 * @author dsieh
 *
 */
public class Dsigner {
    
    @SuppressWarnings("unused")
    private static final String TAG = Dsigner.class.getSimpleName();
    
    /**
     * Verify that the specified signed message has a valid signature. The public
     * key to use is obtained from the application settings.
     * 
     * @param context the current Android context.
     * @param signedMessage the message to be verified.
     * 
     * @return the message if it has a valid signature; null if not
     * 
     * @throws Exception
     */
    public static String verifyServerMessage(Context context, 
                                             String signedMessage) throws Exception {
        
        String message = null;
        boolean valid = false;

        Signature s = Signature.getInstance("SHA256withRSA");
        s.initVerify(MediatorSettings.serverKey(context));
        
        // Break the server message into it's component parts
        byte[] msgSignature = null;
        StringTokenizer tokenizer = new StringTokenizer(signedMessage, "|");
        message = tokenizer.nextToken();
        msgSignature = Base64.decode(tokenizer.nextToken(), Base64.DEFAULT);

        s.update(message.getBytes());

        valid = s.verify(msgSignature);

        return (valid) ? message : null;
    }
    
    /**
     * Signs the specified message with the robot's private key. The
     * private key is obtained from the application settings.
     * 
     * @param context the Android application context.
     * @param message The message to be signed.
     * 
     * @return the signed message
     * 
     * @throws Exception
     */
    public static String signRobotMessage(Context context, 
                                          String message) throws Exception {
        
        String signedMessage = null;

        Signature s = Signature.getInstance("SHA256withRSA");
        s.initSign(MediatorSettings.robotKey(context));

        s.update(message.getBytes());

        String signature = Base64.encodeToString(s.sign(), Base64.NO_WRAP);
        
        signedMessage = message + "|" + signature;

        return signedMessage;
    }

}
