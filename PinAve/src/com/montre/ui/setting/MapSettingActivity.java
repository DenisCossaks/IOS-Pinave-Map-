package com.montre.ui.setting;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
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

import com.montre.data.Setting;
import com.montre.data.Share;
import com.montre.data.UserInfo;
import com.montre.data.UserLoginInfo;
import com.montre.data.Utils;
import com.montre.lib.Const;
import com.montre.pinave.R;
import com.montre.pindetail.ReviewActivity;
import com.montre.ui.basic.BasicUI;

import android.app.DatePickerDialog;
import android.app.Dialog;
import android.app.TimePickerDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.ArrayAdapter;
import android.widget.BaseExpandableListAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.ExpandableListView;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.TimePicker;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.ExpandableListView.OnChildClickListener;

public class MapSettingActivity extends BasicUI {

	RadioGroup mapGroup = null;
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.mapsetting);

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
		
		mapGroup = (RadioGroup) findViewById(R.id.radioGroup1);
		
		int checkedMap = Setting.getMapMode();
		if (checkedMap == Setting.MAP_STANDARD) {
			mapGroup.check(R.id.radio0);
		} else if (checkedMap == Setting.MAP_SATELLITE) {
			mapGroup.check(R.id.radio1);
		}
		
	}

	@Override
	public void initData() {
		// TODO Auto-generated method stub

	}
	
	
	private void onUpdate(){
		int checkedRadioButton = mapGroup.getCheckedRadioButtonId();
		
		if (checkedRadioButton == R.id.radio0) {
			Setting.setMapMode(Setting.MAP_STANDARD);
		} else if (checkedRadioButton == R.id.radio1) {
			Setting.setMapMode(Setting.MAP_SATELLITE);
		}
		
//		finish();
		
		onBackPressed();
	}

	
	

}
