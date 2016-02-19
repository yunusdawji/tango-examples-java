package com.naiveroboticist.sensor;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;

import com.naiveroboticist.interfaces.IRobotReader;

public class SensorPacketReader {
	private static final int MAX_TRIES = 100;
	/**
	 * Sensor packet, payload size values
	 */
	private static final int[] PACKET_PAYLOAD_SIZES = {
		0, 0, 0, 0, 0, 0, 0, // Not used
		1, // * Bumps and Wheel Drops -  7 - 1 byte
	    1, // * Wall                     8 - 1 byte
	    1, // * Cliff Left               9 - 1 byte
	    1, // * Cliff Front Left        10 - 1 byte
	    1, // * Cliff Front Right       11 - 1 byte
	    1, // * Cliff Right             12 - 1 byte
	    1, // * Virtual Wall            13 - 1 byte
	    1, // * Low Side Driver UnderC  14 - 1 byte
	    1, // * Unused bytes            15 - 1 byte
	    1, // * Unused bytes            16 - 1 byte
	    1, // * Infrared byte           17 - 1 byte
	    1, // * Buttons                 18 - 1 byte
	    2, // * Distance                19 - 2 bytes (signed)
	    2, // * Angle                   20 - 2 bytes (signed)
	    1, // * Charging State          21 - 1 byte
	    2, // * Voltage                 22 - 2 bytes 
	    2, // * Current                 23 - 2 bytes
	    1, // * Battery Temperature     24 - 1 byte (signed)
	    2, // * Battery Charge          25   2 bytes
	    2, // * Battery Capacity        26 - 2 bytes
	    2, // * Wall Signal             27 - 2 bytes
	    2, // * Cliff Left Signal       28 - 2 bytes
	    2, // * Cliff Left Front Signal 29 - 2 bytes
	    2, // * Cliff Front Right Sign  30 - 2 bytes
	    2, // * Cliff Right Signal      31 - 2 bytes
	    1, // * Cargo Bay Digital Input 32 - 1 byte
	    2, // * Cargo Bay Analog Signal 33 - 2 bytes
	    1, // * Charging Sources Avail  34 - 1 byte
	    1, // * OI Mode                 35 - 1 byte
	    1, // * Song Number             36 - 1 byte
	    1, // * Song Playing            37 - 1 byte
	    1, // * Number of Stream Pkts   38 - 1 byte
	    2, // * Requested Velocity      39 - 2 bytes (signed)
	    2, // * Requested Radius        40 - 2 bytes (signed)
	    2, // * Requested Right Velo    41 - 2 bytes (signed)
	    2 // * Requested Left Velo     42 - 2 bytes (signed)
	};
	
	private static final byte PACKET_START = 0x13;
	private static final int LEN_IDX = 1;
	
	private ByteBuffer mPacketBuffer;
	
	public SensorPacketReader() {
		mPacketBuffer = ByteBuffer.allocateDirect(512);
	}
	
	public void clear() {
		mPacketBuffer.clear();
	}
	
	public boolean readPacket(byte[] buffer, int numBytes) throws InvalidPacketError {
		int packetStart = 0;
		
		if (numBytes == 0) {
		    return false; // Nothing to do
		}
		
		if (mPacketBuffer.position() == 0) {
			packetStart = findPacketStartInBuffer(buffer, numBytes);
		}
		
		if (packetStart == -1) {
			return false; // The start byte wasn't found
		}
		
		for (int i=packetStart; i<numBytes; i++) {
			mPacketBuffer.put(buffer[i]);
		}
				
		if (mPacketBuffer.position() < 2) {
			return false; // Haven't read the length byte yet
		}
		
		if (mPacketBuffer.get(LEN_IDX) == 0) {
			mPacketBuffer.clear();
			return false;
		}
		
		// +3 due to START byte, LENGTH byte & CHKSUM bytes
		int packetLength = mPacketBuffer.get(LEN_IDX) + 3;
		if (mPacketBuffer.position() < packetLength) {
			return false; // Haven't read the entire packet yet
		}
		
		if (! validChecksum(packetLength)) {
			mPacketBuffer.clear();
			throw new InvalidPacketError("Invalid checksum");
		}
		
		return true;
	}
	
	public String formatPacketBuffer() {
	    byte[] buff = mPacketBuffer.array();
	    int packetLength = buff[LEN_IDX] + 3;
	    StringBuffer sb = new StringBuffer();
	    for (int i=0; i<packetLength; i++) {
	        if (i > 0) {
	            sb.append(", ");
	        }
	        sb.append((int)buff[i]);
	    }
	    return sb.toString();
	}
	
	public ArrayList<Integer> getPacketValues() throws InvalidPacketError {
		ArrayList<Integer> values = new ArrayList<Integer>();
		
		int lastIndex = mPacketBuffer.get(LEN_IDX) + 2;
		
		mPacketBuffer.position(LEN_IDX + 1);
		// The -1 is for the last checksum
		while (mPacketBuffer.position() < lastIndex) {
			int sensorPacket = mPacketBuffer.get();
			if (sensorPacket < 0 || sensorPacket >= PACKET_PAYLOAD_SIZES.length) {
			    throw new InvalidPacketError("Invalid sensor value: " + sensorPacket + ": Packet position = " + mPacketBuffer.position() + " Last Index = " + lastIndex);
			}
			int numBytes = PACKET_PAYLOAD_SIZES[sensorPacket];
			if (numBytes == 1) {
				values.add(new Integer(mPacketBuffer.get()));
			} else if (numBytes == 2) {
				int value = (mPacketBuffer.get() << 8) | mPacketBuffer.get();
				values.add(new Integer(value));
			} else if (numBytes == 0) {
			    // Nothing to do.
			} else {
				throw new InvalidPacketError("Invalid payload size: " + numBytes);
			}
		}
				
		return values;
	}
	
	public void readCompletePacket(IRobotReader rrw, int timeoutMillis) throws IOException, InvalidPacketError {
	    int tries = 0;
	    mPacketBuffer.clear();
	    byte[] buffer = new byte[100];
	    
	    boolean doneReading = false;
	    while (! doneReading) {
	        tries++;
	        if (tries > MAX_TRIES) {
	            throw new InvalidPacketError("Over " + MAX_TRIES + " to read packet. Dude, something's wrong.");
	        }
	        int numBytes = rrw.read(buffer, timeoutMillis);
	        doneReading = readPacket(buffer, numBytes);
	    }
	}
		
	private boolean validChecksum(int packetLength) {
		byte sum = 0;
		
		for (int i=0; i<packetLength; i++) {
			sum += mPacketBuffer.get(i);
		}
		return (byte)(sum & (byte) 0xff) == 0;
	}
	
	private int findPacketStartInBuffer(byte[] buffer, int numBytes) {
		int packetStart = -1;
		
		for (int i=0; i<numBytes; i++) {
			if (buffer[i] == PACKET_START) {
				packetStart = i;
				break;
			}
		}
		
		return packetStart;
	}

}
