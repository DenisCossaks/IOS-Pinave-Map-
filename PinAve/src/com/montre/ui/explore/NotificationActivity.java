package com.montre.ui.explore;

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

import com.google.android.maps.GeoPoint;
import com.montre.data.CategoryInfo;
import com.montre.data.Notification;
import com.montre.data.Setting;
import com.montre.data.Share;
import com.montre.data.UserInfo;
import com.montre.data.UserLoginInfo;
import com.montre.data.Utils;
import com.montre.etc.SelectCategoriesActivity;
import com.montre.lib.Const;
import com.montre.navigation.RouterViewGroup;
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
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.BaseExpandableListAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.ExpandableListView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.TimePicker;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.ExpandableListView.OnChildClickListener;

public class NotificationActivity extends BasicUI{

	CheckBox ckSet = null;
	Spinner spRadius = null;
	Spinner spEvery = null;
	Spinner spNotify = null;
	LinearLayout layoutSetting = null;

	final String[] strSpinnerRadius = { "1", "2", "5", "10" };
	final String[] strSpinnerEvery = { "1", "3", "5", "10", "15", "30", "60", };
	final String[] strSpinnerNotify = { "1", "2", "3", "4", "5", "6", "7", "8",
			"9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19",
			"20", "21", "22", "23", "24", };

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.notification);

		this.initViews();
		this.initData();
	}

	@Override
	public void initViews() {
		// TODO Auto-generated method stub

		Button btnSet = (Button) findViewById(R.id.btn_right);
		btnSet.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onNotifySet();
			}
		});
		
		ckSet = (CheckBox) findViewById(R.id.checkBox1);
		ckSet.setChecked(Notification.getNotify());
		ckSet.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				boolean bSet = Notification.getNotify();
				bSet = !bSet;
				Notification.setNotify(bSet);
				if (bSet) {
					layoutSetting.setVisibility(View.VISIBLE);
				} else {
					layoutSetting.setVisibility(View.GONE);
				}
			}
		});

		Button btnWithCategory = (Button) findViewById(R.id.button1);
		btnWithCategory.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onWithCategory();
			}
		});


		layoutSetting = (LinearLayout) findViewById(R.id.layout_setting);

		
		{
			spRadius = (Spinner) findViewById(R.id.spinner_radius);
			ArrayAdapter<String> adapter = new ArrayAdapter<String>(this,
					android.R.layout.simple_spinner_item, strSpinnerRadius);
			adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
			spRadius.setAdapter(adapter);

			int radius = Notification.getDistance();
			int index = 0;
			if (radius == Notification.RADIUS_1) {
				index = 0;
			} else if (radius == Notification.RADIUS_2) {
				index = 1;
			} else if (radius == Notification.RADIUS_5) {
				index = 2;
			} else if (radius == Notification.RADIUS_10) {
				index = 3;
			}
			spRadius.setSelection(index);
		}

		{
			spEvery = (Spinner) findViewById(R.id.spinner_scan);
			ArrayAdapter<String> adapter = new ArrayAdapter<String>(this,
					android.R.layout.simple_spinner_item, strSpinnerEvery);
			adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
			spEvery.setAdapter(adapter);

			int minute = Notification.getMinute();
			int index = 0;
			if (minute == Notification.MINUTE_1) {
				index = 0;
			} else if (minute == Notification.MINUTE_3) {
				index = 1;
			} else if (minute == Notification.MINUTE_5) {
				index = 2;
			} else if (minute == Notification.MINUTE_10) {
				index = 3;
			} else if (minute == Notification.MINUTE_15) {
				index = 4;
			} else if (minute == Notification.MINUTE_30) {
				index = 5;
			} else if (minute == Notification.MINUTE_60) {
				index = 6;
			}
			spEvery.setSelection(index);
		}
		
		{
			spNotify = (Spinner) findViewById(R.id.spinner_noti);
			ArrayAdapter<String> adapter = new ArrayAdapter<String>(this,
					android.R.layout.simple_spinner_item, strSpinnerNotify);
			adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
			spNotify.setAdapter(adapter);

			int noti = Notification.getDuration();
			int index = noti - 1;
			spNotify.setSelection(index);
		}

		TextView tvUnit = (TextView) findViewById(R.id.tv_unit);
		tvUnit.setText(Setting.getUnit() == Setting.UNIT_KM ? "Km" : "Mile");
		
	}

	@Override
	public void initData() {
		// TODO Auto-generated method stub

		boolean bSet = Notification.getNotify();
		if (bSet) {
			layoutSetting.setVisibility(View.VISIBLE);
		} else {
			layoutSetting.setVisibility(View.GONE);
		}
	}

	@Override
	public void onBackPressed() {
		// TODO Auto-generated method stub
		//super.onBackPressed();
		finish();
	}

	
	private void onWithCategory() {
		
		Intent intent = new Intent(NotificationActivity.this, SelectCategoriesActivity.class);
		
		intent.putExtra("mode", "Notification");
		
		startActivity(intent);
//		goNextHistory("SelectCategoriesActivity", intent);
		
	}
	
	
	private void onNotifySet() {

		if (ckSet.isChecked()) {
			int index = 0;
			
			if (!Notification.isEnableCategory())
			{
				Const.showMessage("", "Please select pin categories for notifications.", this);
				return;
			}
			
			index = spRadius.getSelectedItemPosition();
			int radius = Const.toInt(strSpinnerRadius[index]);
			Notification.setDistance(radius);
			
			index = spEvery.getSelectedItemPosition();
			int scan = Const.toInt(strSpinnerEvery[index]);
			Notification.setMinute(scan);
			
			index = spNotify.getSelectedItemPosition();
			int notify = Const.toInt(strSpinnerNotify[index]);
			Notification.setDuration(notify);
			
			
			
			//////////////////////////////////////////
			
		} else {
			
		}

		finish();
	}

}
