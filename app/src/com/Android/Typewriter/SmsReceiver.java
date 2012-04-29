package com.Android.Typewriter;


import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.IBinder;
import android.provider.ContactsContract.PhoneLookup;
import android.telephony.SmsMessage;
import android.util.Log;


public class SmsReceiver extends BroadcastReceiver
{
	private static final String TAG = "	SmsReceiver";

	@Override
	public void onReceive(Context context, Intent intent) 
	{
		
		Log.d("BackgroundSmsReceiver", "onReceive entered");
		
		for (Object thePdu : (Object []) intent.getExtras().get("pdus") ) {
			//Get the sms message
			SmsMessage theMessage = SmsMessage.createFromPdu((byte []) thePdu);
			//go through the list of contacts currently on the phone, and find the contact that matches with the originating address
			Cursor managedCursor = context.getContentResolver().query(Uri.withAppendedPath(PhoneLookup.CONTENT_FILTER_URI, Uri.encode(theMessage.getOriginatingAddress())),
					new String[]{PhoneLookup.DISPLAY_NAME},
					null, null, null);
			
			String sender;
			//if found, then get the name,otherwise, just use the number
			if (managedCursor.moveToFirst()) {
				sender = managedCursor.getString(managedCursor.getColumnIndex(PhoneLookup.DISPLAY_NAME));
			} else {
				sender = theMessage.getOriginatingAddress(); 
			}
			
			//create intent,format the message, and broadcast it for the usb service
			Intent msg = new Intent();
			msg.setAction("com.rancidbacon.BackgroundUsbAccessory.PRINT_MSG");
			msg.putExtra("MSG","From: "+ sender+"\nMsg: "+""+theMessage.getMessageBody()+"\n");
			context.sendBroadcast(msg);			
			
			break; // We only care about the first one.
		}
		                     
	}

}