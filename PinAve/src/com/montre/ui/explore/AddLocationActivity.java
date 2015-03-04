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
import com.montre.data.CustomLocation;
import com.montre.data.Notification;
import com.montre.data.Setting;
import com.montre.data.Share;
import com.montre.data.UserInfo;
import com.montre.data.UserLoginInfo;
import com.montre.data.Utils;
import com.montre.etc.SelectCategoriesActivity;
import com.montre.etc.SelectCategoriesActivity.ResultListAdapter;
import com.montre.lib.Const;
import com.montre.navigation.RouterViewGroup;
import com.montre.pinave.R;
import com.montre.pindetail.ReviewActivity;
import com.montre.ui.basic.BasicUI;
import com.montre.util.JsonParser;

import android.app.DatePickerDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.app.TimePickerDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.view.animation.BounceInterpolator;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;
import android.widget.BaseExpandableListAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.ExpandableListView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.TimePicker;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.ExpandableListView.OnChildClickListener;

public class AddLocationActivity extends BasicUI{

	EditText etSearch = null;
	private ListView lvList = null;
	private ResultListAdapter 	adapter = null;
	
	ProgressBar progress = null;
	boolean m_bLoading = false;
	
	ArrayList<CustomLocation> lists = new ArrayList<CustomLocation>();
	
	

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.add_location);

	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		
		this.initViews();
		this.initData();
	}
	
	@Override
	public void initViews() {
		// TODO Auto-generated method stub

		Button btnCancel = (Button) findViewById(R.id.btn_search);
		btnCancel.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onCancel();
			}
		});
		
		
		etSearch = (EditText) findViewById(R.id.edit_search);
		etSearch.addTextChangedListener(new TextWatcher() {
			
			@Override
			public void onTextChanged(CharSequence s, int start, int before, int count) {
				// TODO Auto-generated method stub
				onChangeSearch(s.toString());
			}
			
			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void afterTextChanged(Editable s) {
				// TODO Auto-generated method stub
				
			}
		});
		
		progress = (ProgressBar) findViewById(R.id.progressBar1);
		progress.setVisibility(View.GONE);
		
		
	
		lvList = (ListView) findViewById(R.id.lv_explore_category);

		
		lists.clear();
		addCurrentAddress();

		boundAdapter(lists);
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

	private void onCancel()
	{
		finish();
		
	}
	
	private void addCurrentAddress() {
		
		if (Share.my_location != null) {
			CustomLocation loc = new CustomLocation(Share.my_location.getLatitude(), Share.my_location.getLongitude());
			loc.setTitle("Current Location");
			
			lists.add(0, loc);
			
			
		} else if (Const.TEST_LOCATION) {
			CustomLocation loc = new CustomLocation(Share.defaultLat, Share.defaultLng);
			loc.setTitle("Current Location");
			
			lists.add(0, loc);
		}
	}
	private void onChangeSearch(String address) {
		if (m_bLoading)
			return;
		
		m_bLoading = true;
		
		lists.clear();
		
		
		lists = JsonParser.getAddressFromText(address);
		if (lists != null) {
			addCurrentAddress();
			
			boundAdapter(lists);
		}
		
		m_bLoading = false;
		 
		
	}
	
	public void boundAdapter(ArrayList<CustomLocation> list) {
		if (list == null)
			return;
		
    	adapter = new ResultListAdapter(AddLocationActivity.this, list, lvList);
    	lvList.setAdapter(adapter);
		adapter.notifyDataSetChanged();
    }

	
	private void checkNewLocation(CustomLocation _loc) {
		
		if (_loc.getTitle().equals("Current Location")) {
			Share.my_Customlocation = null;
		} else {
			Share.my_Customlocation = new CustomLocation(_loc.getLatitude(), _loc.getLongitude());
		}
		
		finish();
	}
	
	
	public class ResultListAdapter extends BaseAdapter {
		private Context mContext = null;
		private ArrayList<CustomLocation> itemList = null;
		private ListView listView1;
		
		
		public ResultListAdapter(Context mContext, ArrayList<CustomLocation> itemList,
				ListView listView1) {
			this.mContext = mContext;
			this.listView1 = listView1;
			this.itemList = itemList;
			
		}

		@Override
		public int getCount() {
			return itemList.size();
		}

		@Override
		public Object getItem(int position) {
			return itemList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		
		@Override
		public View getView(final int position, View convertView, ViewGroup parent) {
			View view = convertView;
			ViewCache cache;
			
			if (view == null) {
				LayoutInflater inflater = LayoutInflater.from(mContext);
				view = inflater.inflate(R.layout.list_content_category, null);
				cache = new ViewCache(view);
				view.setTag(cache);
			} else {
				cache = (ViewCache) view.getTag();
			}
			
			if(itemList == null || itemList.size()==0)
				return view;
							
			final CustomLocation item = itemList.get(position);
			
			if(item == null)
				return view;
			
			ImageView ivCategory = (ImageView)view.findViewById(R.id.cell_category);
			ivCategory.setVisibility(View.GONE);
			TextView title = (TextView) view.findViewById(R.id.cell_title);
			ImageView ivArrow = (ImageView)view.findViewById(R.id.cell_arrow);
			ivArrow.setVisibility(View.GONE);
			
		
			
			String name = item.getTitle();
			title.setText(name);
			
		
			view.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					
					checkNewLocation(item);
				}
			});
			
			return view;
			
		}


	}
    
    class ViewCache {
		private View view;
//		private WebView iconWebView = null;

		public ViewCache(View view) {
			this.view = view;
		}

//		public WebView getWebView() {
//			if (iconWebView == null) {
//				iconWebView = (WebView) view
//						.findViewById(R.id.iconWebView);
//			}
//			return iconWebView;
//		}
	}
	
	

}
