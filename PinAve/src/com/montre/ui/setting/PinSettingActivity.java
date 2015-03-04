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

public class PinSettingActivity extends BasicUI {

	Button btnStartDate = null;
	Button btnStartTime = null;
	Button btnEndDate = null;
	Button btnEndTime = null;
	Button btnRadius = null;
	Button btnPinNumber = null;
	Spinner spRadius;
	Spinner spPinNumber;

	ProgressBar 	progress = null;
	
	final int PROGRESS_DIALOG = 0;
	final int LOADING_OK = 1;
	final int LOADING_FAIL = 2;

	static final int START_TIME_DIALOG_ID = 0;
	static final int START_DATE_DIALOG_ID = 1;
	static final int END_TIME_DIALOG_ID = 2;
	static final int END_DATE_DIALOG_ID = 3;

	private int mYearStart, mMonthStart, mDayStart, mHourStart, mMinuteStart;
	private int mYearEnd, mMonthEnd, mDayEnd, mHourEnd, mMinuteEnd;
	private int mRadiusIndex;
	private int mPinNumberIndex;
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.pinsetting);

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
		
		
		final Calendar c = Calendar.getInstance();
        mYearStart = mYearEnd 	= c.get(Calendar.YEAR);
        mMonthStart = mMonthEnd = c.get(Calendar.MONTH);
        mDayStart = mDayEnd		= c.get(Calendar.DAY_OF_MONTH);
        mHourStart = c.get(Calendar.HOUR_OF_DAY);
        mMinuteStart = c.get(Calendar.MINUTE);
        
        mHourEnd = 23;
        mMinuteEnd = 59;
        
        int nRadius = Setting.getRadius();
        if (nRadius == Setting.RADIUS_1) {
        	mRadiusIndex = 0;
        } else if (nRadius == Setting.RADIUS_2) {
        	mRadiusIndex = 1;
        } else if (nRadius == Setting.RADIUS_5) {
        	mRadiusIndex = 2;
        } else if (nRadius == Setting.RADIUS_10) {
        	mRadiusIndex = 3;
        } else if (nRadius == Setting.RADIUS_50) {
        	mRadiusIndex = 4;
        } else if (nRadius == Setting.RADIUS_100) {
        	mRadiusIndex = 5;
        } else if (nRadius == Setting.RADIUS_200) {
        	mRadiusIndex = 6;
        } else if (nRadius == Setting.RADIUS_500) {
        	mRadiusIndex = 7;
        }
        
        int pinNumber = Setting.getNumberofPins();
        if (pinNumber == Setting.PIN_25) {
        	mPinNumberIndex = 0;
        } else if (pinNumber == Setting.PIN_50) {
        	mPinNumberIndex = 1;
        } else if (pinNumber == Setting.PIN_100) {
        	mPinNumberIndex = 2;
        } else if (pinNumber == Setting.PIN_150) {
        	mPinNumberIndex = 3;
        } else if (pinNumber == Setting.PIN_200) {
        	mPinNumberIndex = 4;
        }
        
        
        final String[] strRadiusKM = {
            "1 Km", "2 Km", "5 Km", "10 Km", "50 Km", "100 Km", "200 Km", "500 Km"
        };
        final String[] strRadiusRadius = {
            "1 Mile", "2 Mile", "5 Mile", "10 Mile", "50 Mile", "100 Mile", "200 Mile", "500 Mile"
        };
        int unit = Setting.getUnit();
        spRadius = (Spinner) findViewById(R.id.spinner1);
        ArrayAdapter<String> adapter = new ArrayAdapter<String>(this,
                android.R.layout.simple_spinner_item, unit == Setting.UNIT_KM ? strRadiusKM : strRadiusRadius);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spRadius.setAdapter(adapter);
        spRadius.setSelection(mRadiusIndex);
        
        final String[] strNumber = {
                "25", "50", "100", "150", "200"
            };
        
        spPinNumber = (Spinner) findViewById(R.id.spinner2);
        ArrayAdapter<String> adapter1 = new ArrayAdapter<String>(this,
                    android.R.layout.simple_spinner_item, strNumber);
        adapter1.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spPinNumber.setAdapter(adapter1);
        spPinNumber.setSelection(mPinNumberIndex);
            

        progress = (ProgressBar) findViewById(R.id.progressBar1);
        progress.setVisibility(View.GONE);
            
		updateDisplay();
		
	}

	@Override
	public void initData() {
		// TODO Auto-generated method stub

	}
	
	@Override
	public void onBackPressed() {
		// TODO Auto-generated method stub
//		super.onBackPressed();
		finish();
	}
	private void onUpdate(){
		int index = spRadius.getSelectedItemPosition();
		int radius = Setting.RADIUS_1;
		if (index == 0) {
			radius = Setting.RADIUS_1;
		} else if (index == 1) {
			radius = Setting.RADIUS_2;
		} else if (index == 2) {
			radius = Setting.RADIUS_5;
		} else if (index == 3) {
			radius = Setting.RADIUS_10;
		} else if (index == 4) {
			radius = Setting.RADIUS_50;
		} else if (index == 5) {
			radius = Setting.RADIUS_100;
		} else if (index == 6) {
			radius = Setting.RADIUS_200;
		} else if (index == 7) {
			radius = Setting.RADIUS_500;
		}
		Setting.setRadius(radius);
		
		index = spPinNumber.getSelectedItemPosition();
		int pinNumber = Setting.PIN_25;
		if (index == 0) {
			pinNumber = Setting.PIN_25;
		} else if (index == 1) {
			pinNumber = Setting.PIN_50;
		} else if (index == 2) {
			pinNumber = Setting.PIN_100;
		} else if (index == 3) {
			pinNumber = Setting.PIN_150;
		} else if (index == 4) {
			pinNumber = Setting.PIN_200;
		}
		Setting.setNumberofPins(pinNumber);
		
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

	private void updateDisplay() {
		
		btnStartDate.setText(new StringBuilder().append(mMonthStart + 1).append("-").append(mDayStart).append("-").append(mYearStart));
		btnStartTime.setText(new StringBuilder().append(pad(mHourStart)).append(":").append(pad(mMinuteStart)));

		btnEndDate.setText(new StringBuilder().append(mMonthEnd + 1).append("-").append(mDayEnd).append("-").append(mYearEnd));
		btnEndTime.setText(new StringBuilder().append(pad(mHourEnd)).append(":").append(pad(mMinuteEnd)));

//		int unit = Setting.getUnit();
//		String sUnit = unit == Setting.UNIT_KM ? "KM" : "Mile";
//		btnRadius.setText(mRadius + sUnit);
//		
//		btnPinNumber.setText(mPinNumber);
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

}
