package com.montre.ui.setting;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.xmlpull.v1.XmlPullParserException;

import com.montre.data.Share;
import com.montre.data.UserInfo;
import com.montre.data.UserLoginInfo;
import com.montre.data.Utils;
import com.montre.lib.Const;
import com.montre.pinave.R;
import com.montre.pindetail.ReviewActivity;
import com.montre.ui.basic.BasicUI;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.BaseExpandableListAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ExpandableListView;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.ExpandableListView.OnChildClickListener;


public class ProfileActivity extends BasicUI implements RadioGroup.OnCheckedChangeListener {

	EditText editFirstname = null;
	EditText editLastname = null;
	EditText editBirthday = null;
	EditText editCountry = null;
	EditText editState = null;
	EditText editCity = null;
	EditText editTimezone = null;
	EditText editPhone = null;
	EditText editPassword = null;
	EditText editConfirm = null;
	EditText editEmail = null;
    RadioGroup mRadioGroup = null;
	RadioButton rbMale = null;
	RadioButton rbFemale = null;
	int		m_nGender = 0;
	
	ProgressBar	progress = null;
	
	
	final int	PROGRESS_DIALOG = 0;
	final int 	LOADING_OK	= 1;
	final int	LOADING_FAIL = 2;
	
	UserInfo userInfo = new UserInfo();
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.profile);

		this.initViews();
		this.initData();
	}

	@Override
	public void initViews() {
		// TODO Auto-generated method stub
		
		Button btnBack = (Button) findViewById(R.id.btn_left);
    	btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onBackPressed();
			}
		});
    	
		Button btnUpdate = (Button) findViewById(R.id.btn_right);
		btnUpdate.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onUpdate();
			}
		});
		
		
		editFirstname = (EditText) findViewById(R.id.et_firstname);
		editLastname = (EditText) findViewById(R.id.et_lastname);
		editBirthday = (EditText) findViewById(R.id.et_date);
		editCountry = (EditText) findViewById(R.id.et_country);
		editState = (EditText) findViewById(R.id.et_state);
		editCity = (EditText) findViewById(R.id.et_city);
		editTimezone = (EditText) findViewById(R.id.et_timezone);
		editPhone = (EditText) findViewById(R.id.et_phone);
		editPassword = (EditText) findViewById(R.id.et_password);
		editConfirm = (EditText) findViewById(R.id.et_confirm);
		editEmail = (EditText) findViewById(R.id.et_email);

		mRadioGroup = (RadioGroup) findViewById(R.id.genderGroup);
		mRadioGroup.setOnCheckedChangeListener(this);
		rbMale = (RadioButton) findViewById(R.id.male);
		rbFemale = (RadioButton) findViewById(R.id.female);
		
		rbMale.setSelected(true);
		rbFemale.setSelected(false);
		m_nGender = 0;
		
		progress = (ProgressBar) findViewById(R.id.progressBar1);
		progress.setVisibility(View.GONE);
		
		
		userInfo = Share.g_userInfo;
	}

	@Override
	public void onCheckedChanged(RadioGroup group, int checkedId) {
		// TODO Auto-generated method stub
		
		m_nGender = checkedId;
	}
	
	@Override
	public void initData() {
		// TODO Auto-generated method stub
		
		editFirstname.setText(Const.convertString(userInfo.str_firstname));
		editLastname.setText(Const.convertString(userInfo.str_lastname));
		editBirthday.setText(Const.convertString(userInfo.str_detail_birthday));
		
		String gender = Const.convertString(userInfo.str_detail_gender);
		if (gender.equalsIgnoreCase("male")) {
			rbMale.setSelected(true);
			rbFemale.setSelected(false);
			m_nGender = 0;
		} else {
			rbMale.setSelected(false);
			rbFemale.setSelected(true);
			m_nGender = 1;
		}
		
		editCountry.setText(Const.convertString(userInfo.str_detail_country));
		editState.setText(Const.convertString(userInfo.str_detail_state));
		editCity.setText(Const.convertString(userInfo.str_detail_city));
		editTimezone.setText(Const.convertString(userInfo.str_detail_timezone));
		editPhone.setText(Const.convertString(userInfo.str_detail_phone));
		editEmail.setText(Const.convertString(UserLoginInfo.getUserName()));
		
	}
	
	private void onUpdate(){
		String strFirstName = editFirstname.getText().toString();
		String strLastName 	= editLastname.getText().toString();
		String strBirthday 	= editBirthday.getText().toString();
		String strCountry	= editCountry.getText().toString();
		String strState 	= editState.getText().toString();
		String strCity		= editCity.getText().toString();
		String strTimezone	= editTimezone.getText().toString();
		String strPhone		= editPhone.getText().toString();
		String strPassword	= editPassword.getText().toString();
		String strConfirm	= editConfirm.getText().toString();
		String strEmail		= editEmail.getText().toString();
		
		if (!strPassword.equals(strConfirm)) {
			Const.showMessage("", "Do not indentify password", ProfileActivity.this);
			return;
		}
		if (strTimezone.length() < 1) {
			Const.showMessage("", "Please choose time zone.", ProfileActivity.this);
			return;
		}
		if (strFirstName.length() < 1 || strLastName.length() < 1) {
			Const.showMessage("", "Please input name.", ProfileActivity.this);
			return;
		}
		if (strCountry.length() < 1) {
			Const.showMessage("", "Please input country.", ProfileActivity.this);
			return;
		}
		if (strCity.length() < 1) {
			Const.showMessage("", "Please input city.", ProfileActivity.this);
			return;
		}
	
		progress.setVisibility(View.VISIBLE);
		
		HttpClient httpclient = new DefaultHttpClient();
		 String url = Utils.postUpdateProfileUrl();
		 HttpPost httppost = new HttpPost(url);

		 
		 try {
		 // Add your data
		 List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();
		 nameValuePairs.add(new BasicNameValuePair("code", UserLoginInfo.getLoginCode()));
		 nameValuePairs.add(new BasicNameValuePair("firstname", strFirstName));
		 nameValuePairs.add(new BasicNameValuePair("lastname", strLastName));
		 nameValuePairs.add(new BasicNameValuePair("password", strPassword));
		 nameValuePairs.add(new BasicNameValuePair("confirm_password", strConfirm));
		 nameValuePairs.add(new BasicNameValuePair("birthday", strBirthday));
		 String gender = "";
		 gender = m_nGender == 0 ? "male" : "female";
		 nameValuePairs.add(new BasicNameValuePair("gender", gender));
		 nameValuePairs.add(new BasicNameValuePair("country", strCountry));
		 nameValuePairs.add(new BasicNameValuePair("state", strState));
		 nameValuePairs.add(new BasicNameValuePair("city", strCity));
		 nameValuePairs.add(new BasicNameValuePair("phone", strPhone));
		 nameValuePairs.add(new BasicNameValuePair("timezone", strTimezone));
		 nameValuePairs.add(new BasicNameValuePair("email", strEmail));
		 
		 httppost.setEntity(new UrlEncodedFormEntity(nameValuePairs));

		 // Execute HTTP Post Request
		 HttpResponse response = httpclient.execute(httppost);
		 String responseBody = EntityUtils.toString(response.getEntity());
		 
		 System.out.println("post review = " + responseBody);
		 
		 Const.showMessage("", "post review OK", ProfileActivity.this);
		 
		 Share.g_userInfo.str_firstname = strFirstName;
		 Share.g_userInfo.str_lastname = strLastName;
		 Share.g_userInfo.str_detail_birthday = strBirthday;
		 Share.g_userInfo.str_detail_gender = m_nGender == 0 ? "male" : "female";
		 Share.g_userInfo.str_detail_country = strCountry;
		 Share.g_userInfo.str_detail_state = strState;
		 Share.g_userInfo.str_detail_city = strCity;
		 Share.g_userInfo.str_detail_phone = strPhone;
		 
		 } catch (Exception e) {
			 e.printStackTrace();
			 
			 Const.showMessage(ProfileActivity.this);
		 }
		
		 progress.setVisibility(View.GONE);
		 
		 Const.showToastMessage("Your profile has been updated", ProfileActivity.this);
		 
		 onBackPressed();
	}

}
