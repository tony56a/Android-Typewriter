/**
 * Email Configuration activity
 * Allows users to select the gmail addresses on the device that will have new messages printed out
 */
package com.Android.Typewriter;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Properties;

import javax.mail.Folder;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Store;


import android.accounts.Account;
import android.accounts.AccountManager;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.content.DialogInterface.OnDismissListener;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.Toast;

public class ConfigActivity extends Activity {

	//SharedPref keys
	public static final String SHARED_PREF_NAME = "SHARED_PREF_NAME";
	public static final String EMAIL_ADDR_KEY = "EMAIL_ADDRESS";
	public static final String PWD_ADDR_KEY = "PASSWORD_LIST";
	private static final String ENABLED_KEY = "ENABLED_LIST";

	SharedPreferences sharedPrefs;
	Editor editor;
	Email[] emailList;
	ListAdapter emailListAdapter;
	ListView mListView;
	String[] passwordList;
	String[] enabledTempList;
	String[] addrList;
	boolean[] emailEnabled;
	
	//wrapper for email account info strings, enabled state
	private class Email{
		@Override
		public String toString() {
			return "Email [email=" + email + ", enabled=" + enabled
					+"]";
		}
		public Email(String string, boolean b,String password) {
			this.email = string;
			this.enabled = b;
			this.password = password;
		}
		public String email;
		public Boolean enabled;
		public String password;
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);
		mListView = (ListView)findViewById(R.id.listView1);

		//set behaviour of ok button, which will close the activity
		Button button = (Button)findViewById(R.id.button1);
		button.setOnClickListener(new OnClickListener(){

			public void onClick(View arg0) {
				ConfigActivity.this.finish();
			}});
	}

	
	@Override
	public void onResume(){
		super.onResume();
		setupAccounts();
	}

	private void setupAccounts() {
		//get the sharedpreference for the app
		sharedPrefs = this.getSharedPreferences(SHARED_PREF_NAME, MODE_PRIVATE);
		editor = sharedPrefs.edit();
		
		//get the list of current google accounts from the system, as well as from the sharedpreference list
		Account[] gmailAccounts = AccountManager.get(this).getAccountsByType("com.google");
		addrList = sharedPrefs.getString(EMAIL_ADDR_KEY, "").split(",");

		//if the list is not equal in length, probably indicates that the sharedperefernce list is not valid, load default values 
		//for the account list
		if(gmailAccounts.length != addrList.length){
			addrList = new String[gmailAccounts.length];
			for(int i=0; i<gmailAccounts.length;i++){
				addrList[i] = gmailAccounts[i].name;
			}
		}
		
		//otherwise, load password, enabled values from the sharedpreferences
		else{
			passwordList = new String[addrList.length];
			String[] pwdTempCopy = sharedPrefs.getString(PWD_ADDR_KEY, "").split(",");
			System.arraycopy(pwdTempCopy, 0, passwordList, 0, pwdTempCopy.length);
			enabledTempList = sharedPrefs.getString(ENABLED_KEY, "").split(",");
			emailEnabled = new boolean[addrList.length];
			for(int i = 0; i<emailEnabled.length; i++){
				emailEnabled[i] = (Integer.parseInt(enabledTempList[i]) == 1) ? true : false;
			}
		}

		//create the array of email address objects
		//if the enabled list from the sharedpreferences exists, then load those values into the objects
		emailList = new Email[addrList.length];
		if(enabledTempList != null ){
			for(int i=0; i<addrList.length;i++){
				emailList[i] = new Email(addrList[i],emailEnabled[i],passwordList[i]);
			}
		}

		//otherwise, load default values
		else{
			for(int i=0; i<addrList.length;i++){
				emailList[i] = new Email(addrList[i],false,"");
			}
		}

		//create new listadapter for the list using the email objects, and set the listview to this adapter
		emailListAdapter = new ListAdapter(this, R.layout.email_checkbox, emailList);
		mListView.setAdapter(emailListAdapter);
		emailListAdapter.notifyDataSetChanged();
	}

	@Override
	public void onPause(){
		super.onPause();
		//create lists for the email account info and enabled states 
		String usernameList = "";
		String passwordList = "";
		String enabledList = "";
		//place values into the list as long strings with string delimiters (TODO: use something better then this in the future)
		for(int i=0; i<emailList.length; i++){
			usernameList+=emailList[i].email+",";
			passwordList+=emailList[i].password+",";
			enabledList+=emailList[i].enabled ? "1," :"0,";
		}
		//store values into the sharedpreferences
		editor.putString(EMAIL_ADDR_KEY, usernameList);
		editor.putString(PWD_ADDR_KEY, passwordList);
		editor.putString(ENABLED_KEY, enabledList);
		editor.commit();
	}

	private class ListAdapter extends ArrayAdapter<Email>{

		Email[] items;
		public ListAdapter(Context context, int textViewResourceId,
				Email[] items) {
			super(context, textViewResourceId, items);
			this.items = items;
		}

		@Override
		public View getView(int position,View view,ViewGroup viewGroup){
			View v = view;
			//inflate the checkbox view
			if(v == null){
				LayoutInflater vi = (LayoutInflater)getSystemService(Context.LAYOUT_INFLATER_SERVICE);
				v = vi.inflate(R.layout.email_checkbox, null);
			}

			//fill the checkbox with relevant values from the email object for this position
			final Email item = items[position];
			if(item != null){
				final CheckBox option = (CheckBox)v.findViewById(R.id.email_checkbox);
				if(option != null){
					option.setText(item.email);
					option.setChecked(item.enabled && !item.password.equals("null"));
					//set behavior for when the checkbox is pressed
					option.setOnCheckedChangeListener(new OnCheckedChangeListener(){
						public void onCheckedChanged(CompoundButton buttonView,
								boolean isChecked) {
							//set the enabled state of the email object
							item.enabled = isChecked;
							if(isChecked){
								//if checked, then construct a dialog requesting the account password
								AlertDialog.Builder builder = new AlertDialog.Builder(ConfigActivity.this);
								LayoutInflater vi = (LayoutInflater)getSystemService(Context.LAYOUT_INFLATER_SERVICE);
								final View layout = vi.inflate(R.layout.password_dialog,null);
								builder.setView(layout);
								builder.setMessage(ConfigActivity.this.getString(R.string.password_prompt))
								.setCancelable(false)
								.setPositiveButton("Yes", new DialogInterface.OnClickListener() {
									public void onClick(DialogInterface dialog, int id) {
										//if yes, then get the password from the dialog, and begin the authemailaccoutn asynctask
										EditText passwordField = (EditText)layout.findViewById(R.id.editText1);
										String password = passwordField.getEditableText().toString();
										new AuthEmailAccount(ConfigActivity.this, item.email,password,item).execute();
									}
								})
								//otherwise,just cancel the dialog
								.setNegativeButton("No", new DialogInterface.OnClickListener() {
									public void onClick(DialogInterface dialog, int id) {
										dialog.cancel();
									}
								});
								builder.setOnCancelListener(new OnCancelListener(){
									//if the dialog is cancelled, then reset the pressed and email enabled states back to false
									public void onCancel(DialogInterface arg0) {
										if(item.password == null || item.password.equals("null")){
											option.setChecked(false);
											item.enabled = false;
										}
									}}); 
								//only show the dialog if there's no password (TODO: have a way for the user to reset the password)
								if(item.password == null || item.password.equals("null")){
									builder.show();
								}
							}

						}
					});
				}
			}
			return v;
		}

	}
	
	//asynctask to validate the email password
	public class AuthEmailAccount extends AsyncTask<Void,Void,Boolean>{

		Activity activity;
		ProgressDialog dialog;
		String username;
		String password;
		Email item;

		public AuthEmailAccount(Activity activity, String username, String password,Email item){
			this.activity = activity;
			this.username = username;
			this.password = password;
			this.item = item;
			dialog = new ProgressDialog(activity);
		}

		@Override
		protected void onPreExecute(){
			//initalize the progressdialog, to indicating to the user that the password is being authenticated
			dialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
			dialog.setMessage("Loading...");
			dialog.setOnDismissListener(new OnDismissListener() {
				public void onDismiss(DialogInterface arg0) {
					AuthEmailAccount.this.cancel(true);
				}				
			});
			dialog.show();
		}

		@Override
		protected Boolean doInBackground(Void... arg0) {
			//attempt to login into the account, return true if successful, false if an error is encounter during the process
			try{
				Properties props = System.getProperties();
				Session session = Session.getDefaultInstance(props, null);
				Store store = session.getStore("imaps");
				store.connect("imap.gmail.com", username, password);
				Folder inbox = store.getFolder("Inbox");
				inbox.open(Folder.READ_ONLY);
				return true;
			}
			catch(MessagingException e){
				item.enabled = false;
				return false;
			}
		}

		@Override
		protected void onPostExecute(Boolean result){
			//close dialog, show toast if authentication failed, otherwise, set the enabled to true, and the password 
			dialog.dismiss();
			if(!result){
				Toast.makeText(activity, R.string.authentication_failed, Toast.LENGTH_SHORT).show();
			}
			else{
				item.enabled = true;
				item.password = password;
			}
		}

	}
}
