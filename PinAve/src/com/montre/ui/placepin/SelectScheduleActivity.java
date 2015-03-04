package com.montre.ui.placepin;

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
import com.montre.data.Setting;
import com.montre.data.Share;
import com.montre.data.UserInfo;
import com.montre.data.UserLoginInfo;
import com.montre.data.Utils;
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

public class SelectScheduleActivity extends BasicUI implements OnItemSelectedListener {

	TextView tvLabel = null;
	Spinner	spDays = null;
	Button btnStartDate = null;
	Button btnStartTime = null;
	Button btnEndDate = null;
	Button btnEndTime = null;
	Spinner spRecurrence = null;
	Spinner spRepete = null;
	Spinner spMonth = null;
	LinearLayout layoutSimple = null;
	LinearLayout layoutAdvance = null;
	
	
	static final int START_TIME_DIALOG_ID = 0;
	static final int START_DATE_DIALOG_ID = 1;
	static final int END_TIME_DIALOG_ID = 2;
	static final int END_DATE_DIALOG_ID = 3;

	private int mYearStart, mMonthStart, mDayStart, mHourStart, mMinuteStart;
	private int mYearEnd, mMonthEnd, mDayEnd, mHourEnd, mMinuteEnd;
	private int mDaysIndex = 0;
	
	private String mRecurrence = "";
//	private int mRecurrenceIndex = 0;
//	private int mRepeteIndex = 0;
//	private int mMonthIndex = 0;
	
	
	
	final String[] strSpinner1 = {
            "One-Time Event", "Daily", "Weekly", "Monthly", "Yearly",
       };
	final String[] strSpinner2 = {
            "One-Time Event", "Weekly", "Monthly", "Yearly",
       };
	final String[] strSpinner3 = {
            "One-Time Event", "Monthly", "Yearly",
       };
	final String[] strSpinner4 = {
            "One-Time Event", "Yearly",
       };
	private int m_nSpinType = 0;
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.selectschedule);

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
		
		
		btnStartDate = (Button) findViewById(R.id.pickDate_start);
		btnStartDate.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				showDialog(START_DATE_DIALOG_ID);
			}
		});
		
		btnStartTime = (Button) findViewById(R.id.pickTime_start);
		btnStartTime.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				showDialog(START_TIME_DIALOG_ID);
			}
		});
		
		btnEndDate = (Button) findViewById(R.id.pickDate_end);
		btnEndDate.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				showDialog(END_DATE_DIALOG_ID);
			}
		});
		
		btnEndTime = (Button) findViewById(R.id.pickTime_end);
		btnEndTime.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				showDialog(END_TIME_DIALOG_ID);
			}
		});
		
		tvLabel = (TextView) findViewById(R.id.tv_label);
		
		layoutSimple = (LinearLayout) findViewById(R.id.layout_simple);
		layoutAdvance = (LinearLayout) findViewById(R.id.layout_advance);
		

        mDaysIndex = 0;

		Calendar c = Calendar.getInstance();
        mYearStart  	= c.get(Calendar.YEAR);
        mMonthStart		= c.get(Calendar.MONTH);
        mDayStart 		= c.get(Calendar.DAY_OF_MONTH);
        mHourStart 		= c.get(Calendar.HOUR_OF_DAY);
        mMinuteStart 	= c.get(Calendar.MINUTE);
        
        c.add(Calendar.DAY_OF_MONTH, mDaysIndex + 1);

        mYearEnd 	 	= c.get(Calendar.YEAR);
        mMonthEnd		= c.get(Calendar.MONTH);
        mDayEnd 		= c.get(Calendar.DAY_OF_MONTH);
        mHourEnd = 23;
        mMinuteEnd = 59;

        
        
        String[] strSpinner = new String[30];
        for (int i = 0; i < strSpinner.length; i++) {
			strSpinner[i] = "" + (i+1);
		}
        
        
        spDays = (Spinner) findViewById(R.id.spinner_days);
        ArrayAdapter<String> adapter = new ArrayAdapter<String>(this,
                android.R.layout.simple_spinner_item, strSpinner);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spDays.setAdapter(adapter);
        spDays.setSelection(0);

        
        spRecurrence = (Spinner) findViewById(R.id.spinner_recurrence);
       
        
        spRepete = (Spinner) findViewById(R.id.spinner_repete);
        spRepete.setAdapter(adapter);
        spRepete.setSelection(0);
        
        spMonth = (Spinner) findViewById(R.id.spinner_month);
        spMonth.setAdapter(adapter);
        spMonth.setSelection(0);

		updateDisplay();
	}

	@Override
	public void initData() {
		// TODO Auto-generated method stub
		
		if (ActivePinActivity.m_nSimple == -1 || ActivePinActivity.m_nSimple == 1) {
			tvLabel.setText("Simple");
			layoutSimple.setVisibility(View.VISIBLE);
			layoutAdvance.setVisibility(View.GONE);
		} else {
			tvLabel.setText("Advance");
			layoutSimple.setVisibility(View.GONE);
			layoutAdvance.setVisibility(View.VISIBLE);
		}
	}
	
	@Override
	public void onBackPressed() {
		// TODO Auto-generated method stub
//		super.onBackPressed();
		
		finish();
	}
	
	public boolean onCreateOptionsMenu(Menu menu) {
		super.onCreateOptionsMenu(menu);
		
		menu.add(1, 100, 1, "Simple");
		menu.add(1, 101, 2, "Advance");
		
		return true;
	}

	public boolean onOptionsItemSelected(MenuItem item) {
		super.onOptionsItemSelected(item);
		
		switch (item.getItemId()) {
		case 100:
			ActivePinActivity.m_nSimple = 1;
			tvLabel.setText("Simple");
			layoutSimple.setVisibility(View.VISIBLE);
			layoutAdvance.setVisibility(View.GONE);
			break;
		case 101:
			tvLabel.setText("Advance");
			ActivePinActivity.m_nSimple = 0;
			layoutSimple.setVisibility(View.GONE);
			layoutAdvance.setVisibility(View.VISIBLE);
			break;
				
		}
		return true;
	}
	private void updateDisplay() {
		
		spDays.setSelection(mDaysIndex);
		
		if (mYearStart > mYearEnd) {
			Const.showToastMessage("Please choose correct End date(Year)", this);
			return;
		} else if (mMonthStart > mMonthEnd) {
			Const.showToastMessage("Please choose correct End date(Month)", this);
			return;
		} else if (mDayStart > mDayEnd) {
			Const.showToastMessage("Please choose correct End date(Day)", this);
			return;
		}
		
		btnStartDate.setText(new StringBuilder().append(mMonthStart + 1).append("-").append(mDayStart).append("-").append(mYearStart));
		btnStartTime.setText(new StringBuilder().append(pad(mHourStart)).append(":").append(pad(mMinuteStart)));

		btnEndDate.setText(new StringBuilder().append(mMonthEnd + 1).append("-").append(mDayEnd).append("-").append(mYearEnd));
		btnEndTime.setText(new StringBuilder().append(pad(mHourEnd)).append(":").append(pad(mMinuteEnd)));

		int start = mMonthStart * 24 * 30 + mDayStart * 24 + mHourStart;
		int end   = mMonthEnd * 24 * 30 + mDayEnd * 24 + mHourEnd;
		int difference = end -  start;
		
		
		
	    ArrayAdapter<String> adapter;
		if (24 * 30 <= difference && difference < 24 * 365) {
	        adapter = new ArrayAdapter<String>(this,
	                android.R.layout.simple_spinner_item, strSpinner4);
	        m_nSpinType = 4;
		} else if (24 * 7 <= difference && difference < 24 * 30) {
	        adapter = new ArrayAdapter<String>(this,
	                android.R.layout.simple_spinner_item, strSpinner3);
	        m_nSpinType = 3;
		} else if (24 * 1 <= difference && difference < 24 * 7) {
	        adapter = new ArrayAdapter<String>(this,
	                android.R.layout.simple_spinner_item, strSpinner2);
	        m_nSpinType = 2;
		} else {
	        adapter = new ArrayAdapter<String>(this,
	                android.R.layout.simple_spinner_item, strSpinner1);
	        m_nSpinType = 1;
		}		
		
		adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spRecurrence.setAdapter(adapter);
		 spRecurrence.setOnItemSelectedListener(this);
		 
	}
	
	private void onUpdate(){
		
		if (ActivePinActivity.m_nSimple == -1) {
			ActivePinActivity.m_nSimple = 1;
		}
		
		
		ActivePinActivity.m_nDays = spDays.getSelectedItemPosition() + 1;
		
		ActivePinActivity.m_nStartYear = mYearStart;
		ActivePinActivity.m_nStartMonth = mMonthStart;
		ActivePinActivity.m_nStartDay = mDayStart;
		ActivePinActivity.m_nStartHour = mHourStart;
		ActivePinActivity.m_nStartMin = mMinuteStart;
		
		ActivePinActivity.m_nEndYear = mYearEnd;
		ActivePinActivity.m_nEndMonth = mMonthEnd;
		ActivePinActivity.m_nEndDay = mDayEnd;
		ActivePinActivity.m_nEndHour = mHourEnd;
		ActivePinActivity.m_nEndMin = mMinuteEnd;
		
		ActivePinActivity.m_strFrequency = mRecurrence;
		ActivePinActivity.m_nRepet	= spRepete.getSelectedItemPosition() + 1;
		ActivePinActivity.m_nEvery = spMonth.getSelectedItemPosition() + 1;
		
		finish();
	}

	
	@Override
	protected Dialog onCreateDialog(int id) {
		switch (id) {
		case START_TIME_DIALOG_ID:
			return new TimePickerDialog(this, mStartTimeSetListener, mHourStart, mMinuteStart,
					false);
		case START_DATE_DIALOG_ID:
			return new DatePickerDialog(this, mStartDateSetListener, mYearStart, mMonthStart,
					mDayStart);
		case END_TIME_DIALOG_ID:
			return new TimePickerDialog(this, mEndTimeSetListener, mHourEnd, mMinuteEnd,
					false);
		case END_DATE_DIALOG_ID:
			return new DatePickerDialog(this, mEndDateSetListener, mYearEnd, mMonthEnd,
					mDayEnd);
		}
		return null;
	}

	@Override
	protected void onPrepareDialog(int id, Dialog dialog) {
		switch (id) {
		case START_TIME_DIALOG_ID:
			((TimePickerDialog) dialog).updateTime(mHourStart, mMinuteStart);
			break;
		case START_DATE_DIALOG_ID:
			((DatePickerDialog) dialog).updateDate(mYearStart, mMonthStart, mDayStart);
			break;
		case END_TIME_DIALOG_ID:
			((TimePickerDialog) dialog).updateTime(mHourEnd, mMinuteEnd);
			break;
		case END_DATE_DIALOG_ID:
			((DatePickerDialog) dialog).updateDate(mYearEnd, mMonthEnd, mDayEnd);
			break;
		}
	}

	private DatePickerDialog.OnDateSetListener mStartDateSetListener = new DatePickerDialog.OnDateSetListener() {

		public void onDateSet(DatePicker view, int year, int monthOfYear,
				int dayOfMonth) {
			mYearStart = year;
			mMonthStart = monthOfYear;
			mDayStart = dayOfMonth;
			updateDisplay();
		}
	};

	private TimePickerDialog.OnTimeSetListener mStartTimeSetListener = new TimePickerDialog.OnTimeSetListener() {

		public void onTimeSet(TimePicker view, int hourOfDay, int minute) {
			mHourStart = hourOfDay;
			mMinuteStart = minute;
			updateDisplay();
		}
	};
	private DatePickerDialog.OnDateSetListener mEndDateSetListener = new DatePickerDialog.OnDateSetListener() {

		public void onDateSet(DatePicker view, int year, int monthOfYear,
				int dayOfMonth) {
			mYearEnd = year;
			mMonthEnd = monthOfYear;
			mDayEnd = dayOfMonth;
			updateDisplay();
		}
	};

	private TimePickerDialog.OnTimeSetListener mEndTimeSetListener = new TimePickerDialog.OnTimeSetListener() {

		public void onTimeSet(TimePicker view, int hourOfDay, int minute) {
			mHourEnd = hourOfDay;
			mMinuteEnd = minute;
			updateDisplay();
		}
	};

	private static String pad(int c) {
		if (c >= 10)
			return String.valueOf(c);
		else
			return "0" + String.valueOf(c);
	}

	@Override
	public void onItemSelected(AdapterView<?> arg0, View arg1, int arg2,
			long arg3) {
		// TODO Auto-generated method stub
		if (m_nSpinType == 1) {
			mRecurrence = strSpinner1[arg2];
		} else if (m_nSpinType == 2) {
			mRecurrence = strSpinner2[arg2];
		} else if (m_nSpinType == 3) {
			mRecurrence = strSpinner3[arg2];
		} else if (m_nSpinType == 4) {
			mRecurrence = strSpinner4[arg2];
		}
	}

	@Override
	public void onNothingSelected(AdapterView<?> arg0) {
		// TODO Auto-generated method stub
		
	}

}
