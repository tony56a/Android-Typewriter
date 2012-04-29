package com.Android.Typewriter;

import java.io.FileDescriptor;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

import com.android.future.usb.UsbAccessory;
import com.android.future.usb.UsbManager;

import android.app.IntentService;
import android.app.Notification;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Handler;
import android.os.ParcelFileDescriptor;
import android.os.SystemClock;
import android.util.Log;

public class BackgroundUsbService extends IntentService {

    private String TAG = "BackgroundUsbService";

	private static final int NOTIFICATION_ID = 1;    
    
	private boolean accessoryDetached = false;

	private ParcelFileDescriptor mFileDescriptor;
	private FileInputStream mInputStream;
	private FileOutputStream mOutputStream;	

	private LinkedBlockingQueue<String> actionQueue = new LinkedBlockingQueue<String>();
	
	// We use this to catch the USB accessory detached message
	private final BroadcastReceiver mUsbReceiver = new BroadcastReceiver() {
	    public void onReceive(Context context, Intent intent) {
	        final String TAG = "mUsbReceiver";

	        Log.d(TAG,"onReceive entered");
	        
	        String action = intent.getAction(); 

	        if (UsbManager.ACTION_USB_ACCESSORY_DETACHED.equals(action)) {
	        	UsbAccessory accessory = UsbManager.getAccessory(intent);

		        Log.d(TAG,"Accessory detached");	        	
	        	
	        	// TODO: Check it's us here?
		        
		        accessoryDetached = true;
	        	
	        	unregisterReceiver(mUsbReceiver);
	        	
	            if (accessory != null) {
	                // TODO: call method to clean up and close communication with the accessory?
	            }
	        }
	        
	        Log.d(TAG,"onReceive exited");
	    }
	};
	
	
	public BackgroundUsbService() {
		super("BackgroundUsbService");
	}

	Notification createNotification(String accessoryDescription) {

		Notification notification = new Notification(android.R.drawable.ic_menu_info_details,
				"Accessory connected", System.currentTimeMillis());
		
		Context context = getApplicationContext();
		CharSequence contentTitle = "USB Accessory connected";
		CharSequence contentText = accessoryDescription + " connected";

		// This can be changed if we want to launch an activity when notification clicked
		Intent notificationIntent = new Intent();
		
		PendingIntent contentIntent = PendingIntent.getActivity(this, 0, notificationIntent, 0);

		notification.setLatestEventInfo(context, contentTitle, contentText, contentIntent);		
		
		return notification;
	}

	void writeBytes(byte[]theStringBytes) {
		/*
		  
		   Writes the supplied byte array to the output stream as one byte per USB packet.
		   
		   In addition to that functionality this acts as a convenience function
		   that catches write errors.
		    
		 */
		if (mOutputStream == null) {
			return;
		}
		
		try {
			// We send one byte per packet because the Arduino sketch doesn't
			// currently handle more than one--mainly because I don't know how
			// to get the packet length and/or to read packet data in multiple
			// passes.
			for (int i = 0; i < theStringBytes.length; i++) {
				mOutputStream.write(theStringBytes[i]);
			}
		}  catch (IOException e) {
			// We can/should ignore the "no such device" error here if it means we've disconnected.
			Log.e(TAG, "write failed", e);
		}		
	}
	
	@Override
	protected void onHandleIntent(Intent theIntent) {
		
		Log.d(TAG, "onHandleIntent entered");		
		
		// The necessary extras should've been added by `fillIn()` call in Activity.
        UsbAccessory accessory = UsbManager.getAccessory(theIntent);
        
        if (accessory != null) {
			Log.d(TAG, "Got accessory: " + accessory.getModel());
			
			// TODO: Check this order is okay or do we risk getting killed?
			startForeground(NOTIFICATION_ID, createNotification(accessory.getDescription()));

			// Register to receive detached messages
			IntentFilter filter = new IntentFilter(UsbManager.ACTION_USB_ACCESSORY_DETACHED);
			registerReceiver(mUsbReceiver, filter);

		    mFileDescriptor = UsbManager.getInstance(this).openAccessory(accessory);
		    if (mFileDescriptor != null) {
		        FileDescriptor fd = mFileDescriptor.getFileDescriptor();
		        mInputStream = new FileInputStream(fd);
		        mOutputStream = new FileOutputStream(fd);
		    }

	    	registerReceiver(receiver, new IntentFilter("com.rancidbacon.BackgroundUsbAccessory.PRINT_MSG"));
		    
		    String newAction = null;
		    
			while(true) {
				
				try {
					newAction = actionQueue.poll(1000, TimeUnit.MILLISECONDS);
				} catch (InterruptedException e) { 
		             // Restore the interrupted status
					 // See: <http://www.ibm.com/developerworks/java/library/j-jtp05236/index.html>
		             Thread.currentThread().interrupt();
		        }
				
				// TODO: Allow us to be interrupted with this immediately?
				// Check if the accessory detachment was flagged
				if (accessoryDetached) {
					break;
				}

				// In reality we'd do stuff here.
				
				if (newAction != null) {
					writeBytes(newAction.getBytes());
				}
			}		
		    
	    	unregisterReceiver(receiver);		    
		    
		    actionQueue.clear();

			// Without this clean-up code the app will work once but then
			// won't start again until it's force-quit.
			try {
				if (mFileDescriptor != null) {
					mFileDescriptor.close();
				}
			} catch (IOException e) {
			} finally {
				mFileDescriptor = null;
				accessory = null;
			}			
			
			stopForeground(true);
			
		} else {
			Log.d(TAG, "No accessory found.");
		}
		
		stopSelf();
		
		Log.d(TAG, "onHandleIntent exited");		
	}

	//Replaced the original broadcastreceiver with a generic one, so that we can send multiple types of messages through
	private BroadcastReceiver receiver = new BroadcastReceiver () {

		@Override
		public void onReceive(Context arg0, Intent arg1) {
			
			Bundle extras = arg1.getExtras();
			String toWrite = extras.getString("MSG");
			actionQueue.add(toWrite);
			

		}
	};
	
}
