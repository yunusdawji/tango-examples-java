package com.naiveroboticist.robotmediator;

import java.io.BufferedWriter;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.Timer;
import java.util.TimerTask;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

/**
 * An Android Service to maintain communication with the telep server to
 * register and to receive commands for the iRobot Create.
 * 
 * @author dsieh
 *
 */
public class ServerCommunicationService extends Service {

    private static final String TAG = ServerCommunicationService.class.getSimpleName();
    
    private Timer timer;
    private Thread commThread = null;
    private boolean continueRunning = true;
    
    /**
     * This runnable sets up the communication with the telep server,
     * registers the robot and waits on the socket for commands for
     * the robot.
     * 
     * @author dsieh
     *
     */
    class CommunicationThread implements Runnable {
        
        private InetAddress address;
        private int port;
        
        /**
         * Constructs a new CommunicationThread.
         * 
         * @param serverAddr the address of the server
         * @param serverPort the port the server is listening on.
         */
        public CommunicationThread(InetAddress serverAddr, int serverPort) {
            address = serverAddr;
            port = serverPort;
        }
        
        @Override
        public void run() {
            Socket socket = null;
            try {
                socket = new Socket(address, port);
                InputStream input = socket.getInputStream();
                PrintWriter output = new PrintWriter(new BufferedWriter(new OutputStreamWriter(socket.getOutputStream())));

                byte[] byteBuffer = new byte[500];
                int numBytes = input.read(byteBuffer);
                String serverChallenge = new String(byteBuffer, 0, numBytes);
                String message = Dsigner.verifyServerMessage(ServerCommunicationService.this, serverChallenge);
                
                if (message == null) {
                    Log.e(TAG, "Server challenge had invalid signature");
                    return;
                }
                
                // Tell the server who we are
                String robotMessage = "robot|" + MediatorSettings.robotName(ServerCommunicationService.this);
                String signedRobotMessage = Dsigner.signRobotMessage(ServerCommunicationService.this, robotMessage);
                output.print(signedRobotMessage);
                output.flush();
                
                // Now, wait until we stop the thread
                while (continueRunning) {
                    numBytes = input.read(byteBuffer);
                    String commandMessage = new String(byteBuffer, 0, numBytes);
                    if (commandMessage != null) {
                        String command = Dsigner.verifyServerMessage(ServerCommunicationService.this, commandMessage);
                        if (command != null) {
                            broadcastRobotCommand(command);
                        } else {
                            Log.e(TAG, "Invalid command from the server: " + command);
                        }
                    }
                }
            } catch (Exception e) {
                Log.e(TAG, "Error doing socket junk", e);
            } finally {
                /*
                 * When the server connection is gone - either through normal
                 * stoppage or an error, we really want the robot to stop. So
                 * before we do anything else, let's stop the robot from doing
                 * anything else.
                 */
                broadcastRobotCommand("stop");
                
                try { 
                    if (socket != null) {
                        socket.close();
                    }
                } catch (Exception ex) {
                    Log.e(TAG, "Error closing socket", ex);
                }
            }
            Log.i(TAG, "Client socket thread done.");
            
            commThread = null;
        }
        
    }
    
    /**
     * This private method sends the command to the IRobotCommunicationService.
     * 
     * @param command the command to send to the service.
     */
    private void broadcastRobotCommand(String command) {
        Intent intent = new Intent(IRobotCommunicationService.ACTION_COMMAND_TO_ROBOT);
        intent.putExtra(IRobotBroadcastReceiver.COMMAND_NAME, command);
        sendBroadcast(intent);
    }
     
    /**
     * A runnable to continue attempting to connect to the telep server
     * as long as the commThread is null. We use this in case we lose
     * internet connection.
     */
    private TimerTask updateTask = new TimerTask() {
        @Override
        public void run() {
            if (commThread == null) {
                try {
                    commThread = new Thread(new CommunicationThread(MediatorSettings.telepHost(ServerCommunicationService.this),
                                                         (int)MediatorSettings.telepPort(ServerCommunicationService.this)));
                    commThread.start();
                } catch (UnknownHostException e) {
                    Log.e(TAG, "Error Firing up client socket thread", e);
                }
            }
        }
    };

    @Override
    public void onCreate() {
        super.onCreate();
        timer = new Timer("ServerCommunicationTimer");
        // timer.schedule(updateTask, 1000L, 10 * 1000L);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // If this flag isn't set, we'll only go through the loop
        // once. C'mon man.
        continueRunning = true;
        
        if (timer != null) {
            timer.schedule(updateTask, 1000L, 10 * 1000L);
        }
        
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public boolean onUnbind(Intent intent) {
        // Stop the timer from running
        if (timer != null) {
            timer.cancel();
        }
        
        // We want to stop the thread from running.
        continueRunning = false;
        commThread = null;
        
        return super.onUnbind(intent);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        
        if (timer != null) {
            timer.cancel();
            timer = null;
        }

        continueRunning = false;
        
    }

    @Override
    public IBinder onBind(Intent arg0) {
        // Nothing to see here. Move along.
        return null;
    }

}
