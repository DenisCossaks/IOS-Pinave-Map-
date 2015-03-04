package com.montre.etc;

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
import com.montre.data.SearchOption;
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
import com.montre.ui.explore.ExploreActivity;

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

public class SearchOptionActivity extends BasicUI{

	Spinner spRadius = null;
	Spinner spActive = null;

	final String[] strSpinnerActive = { "now", "today", "this week", "this month"};
	final String[] strSpinnerRadius = { "1", "2", "5", "10", "50", "100", "200", "500" };

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.search_option);

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
				onSearchOptionSet();
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


		{
			spRadius = (Spinner) findViewById(R.id.spinner_radius);
			ArrayAdapter<String> adapter = new ArrayAdapter<String>(this,
					android.R.layout.simple_spinner_item, strSpinnerRadius);
			adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
			spRadius.setAdapter(adapter);

			int radius = Setting.getRadius();
			int index = 0;
			if (radius == Setting.RADIUS_1) {
				index = 0;
			} else if (radius == Setting.RADIUS_2) {
				index = 1;
			} else if (radius == Setting.RADIUS_5) {
				index = 2;
			} else if (radius == Setting.RADIUS_10) {
				index = 3;
			} else if (radius == Setting.RADIUS_50) {
				index = 4;
			} else if (radius == Setting.RADIUS_100) {
				index = 5;
			} else if (radius == Setting.RADIUS_200) {
				index = 6;
			} else if (radius == Setting.RADIUS_200) {
				index = 7;
			}
			spRadius.setSelection(index);
		}

		{
			spActive = (Spinner) findViewById(R.id.spinner_scan);
			ArrayAdapter<String> adapter = new ArrayAdapter<String>(this,
					android.R.layout.simple_spinner_item, strSpinnerActive);
			adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
			spActive.setAdapter(adapter);
		}
		
		TextView tvUnit = (TextView) findViewById(R.id.tv_unit);
		tvUnit.setText(Setting.getUnit() == Setting.UNIT_KM ? "Km" : "Mile");
		
	}

	@Override
	public void initData() {
		// TODO Auto-generated method stub

	}

	@Override
	public void onBackPressed() {
		// TODO Auto-generated method stub
		//super.onBackPressed();
		ExploreActivity.m_bRefresh = false;
		
		finish();
	}

	
	private void onWithCategory() {
		
		Intent intent = new Intent(SearchOptionActivity.this, SelectCategoriesActivity.class);
		
		intent.putExtra("mode", "SearchOption");
		
		startActivity(intent);
//		goNextHistory("SelectCategoriesActivity", intent);
		
	}
	
	
	private void onSearchOptionSet() {

			int index = 0;
			
			if (!SearchOption.isEnableCategory()) {
				Const.showMessage("", "Please select pin categories for search pin.", this);
				return;
			}
			
			index = spRadius.getSelectedItemPosition();
			int radius = Const.toInt(strSpinnerRadius[index]);
			Setting.setRadius(radius);
			
//			index = spActive.getSelectedItemPosition();
//			int scan = Const.toInt(strSpinnerActive[index]);
//			Notification.setMinute(scan);
			
			ExploreActivity.m_bRefresh = false;
			
		finish();
	}

}
